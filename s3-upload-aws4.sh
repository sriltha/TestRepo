#!/bin/sh -u

# To the extent possible under law, Viktor Szakats
# has waived all copyright and related or neighboring rights to this
# script.
# CC0 - https://creativecommons.org/publicdomain/zero/1.0/

# Upload a file to Amazon AWS S3 using Signature Version 4
#
# docs:
#   https://docs.aws.amazon.com/general/latest/gr/sigv4-create-canonical-request.html
#   https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-query-string-auth.html
#
# requires:
#   curl, openssl 1.x or newer, GNU sed, LF EOLs in this file
#
# FIXME: Signature will fail when using certain special characters or
#        space in the filename to be uploaded.

fileLocal="${1:-example-local-file.ext}"
bucket="${2:-example-bucket}"
region="${3:-}"
storageClass="${4:-STANDARD}"  # or 'REDUCED_REDUNDANCY'

my_openssl() {
  if [ -f /usr/local/opt/openssl@1.1/bin/openssl ]; then
    /usr/local/opt/openssl@1.1/bin/openssl "$@"
  elif [ -f /usr/local/opt/openssl/bin/openssl ]; then
    /usr/local/opt/openssl/bin/openssl "$@"
  else
    openssl "$@"
  fi
}

my_sed() {
  if which gsed > /dev/null 2>&1; then
    gsed "$@"
  else
    sed "$@"
  fi
}

awsStringSign4() {
  kSecret="AWS4$1"
  kDate=$(printf         '%s' "$2" | my_openssl dgst -sha256 -hex -mac HMAC -macopt "key:${kSecret}"     2>/dev/null | my_sed 's/^.* //')
  kRegion=$(printf       '%s' "$3" | my_openssl dgst -sha256 -hex -mac HMAC -macopt "hexkey:${kDate}"    2>/dev/null | my_sed 's/^.* //')
  kService=$(printf      '%s' "$4" | my_openssl dgst -sha256 -hex -mac HMAC -macopt "hexkey:${kRegion}"  2>/dev/null | my_sed 's/^.* //')
  kSigning=$(printf 'aws4_request' | my_openssl dgst -sha256 -hex -mac HMAC -macopt "hexkey:${kService}" 2>/dev/null | my_sed 's/^.* //')
  signedString=$(printf  '%s' "$5" | my_openssl dgst -sha256 -hex -mac HMAC -macopt "hexkey:${kSigning}" 2>/dev/null | my_sed 's/^.* //')
  printf '%s' "${signedString}"
}

iniGet() {
  # based on: https://stackoverflow.com/questions/22550265/read-certain-key-from-certain-section-of-ini-file-sed-awk#comment34321563_22550640
  printf '%s' "$(my_sed -n -E "/\[$2\]/,/\[.*\]/{/$3/s/(.*)=[ \\t]*(.*)/\2/p}" "$1")"
}

# Initialize access keys

if [ -z "${AWS_CONFIG_FILE:-}" ]; then
  if [ -z "${AWS_ACCESS_KEY:-}" ]; then
    echo 'AWS_CONFIG_FILE or AWS_ACCESS_KEY/AWS_SECRET_KEY envvars not set.'
    exit 1
  else
    awsAccess="${AWS_ACCESS_KEY}"
    awsSecret="${AWS_SECRET_KEY}"
    awsRegion='us-east-1'
  fi
else
  awsProfile='default'

  # Read standard aws-cli configuration file
  # pointed to by the envvar AWS_CONFIG_FILE
  awsAccess="$(iniGet "${AWS_CONFIG_FILE}" "${awsProfile}" 'aws_access_key_id')"
  awsSecret="$(iniGet "${AWS_CONFIG_FILE}" "${awsProfile}" 'aws_secret_access_key')"
  awsRegion="$(iniGet "${AWS_CONFIG_FILE}" "${awsProfile}" 'region')"
fi

# Initialize defaults

fileRemote="${fileLocal}"

if [ -z "${region}" ]; then
  region="${awsRegion}"
fi

echo "Uploading" "${fileLocal}" "->" "${bucket}" "${region}" "${storageClass}"
echo "| $(uname) | $(my_openssl version) | $(my_sed --version | head -1) |"

# Initialize helper variables

httpReq='PUT'
authType='AWS4-HMAC-SHA256'
service='s3'
baseUrl=".${service}.amazonaws.com"
dateValueS=$(date -u +'%Y%m%d')
dateValueL=$(date -u +'%Y%m%dT%H%M%SZ')
if hash file 2>/dev/null; then
  contentType="$(file --brief --mime-type "${fileLocal}")"
else
  contentType='application/octet-stream'
fi

# 0. Hash the file to be uploaded

if [ -f "${fileLocal}" ]; then
  payloadHash=$(my_openssl dgst -sha256 -hex < "${fileLocal}" 2>/dev/null | my_sed 's/^.* //')
else
  echo "File not found: '${fileLocal}'"
  exit 1
fi

# 1. Create canonical request

# NOTE: order significant in ${headerList} and ${canonicalRequest}

headerList='content-type;host;x-amz-content-sha256;x-amz-date;x-amz-server-side-encryption;x-amz-storage-class'

canonicalRequest="\
${httpReq}
/${fileRemote}

content-type:${contentType}
host:${bucket}${baseUrl}
x-amz-content-sha256:${payloadHash}
x-amz-date:${dateValueL}
x-amz-server-side-encryption:AES256
x-amz-storage-class:${storageClass}

${headerList}
${payloadHash}"

# Hash it

canonicalRequestHash=$(printf '%s' "${canonicalRequest}" | my_openssl dgst -sha256 -hex 2>/dev/null | my_sed 's/^.* //')

# 2. Create string to sign

stringToSign="\
${authType}
${dateValueL}
${dateValueS}/${region}/${service}/aws4_request
${canonicalRequestHash}"

# 3. Sign the string

signature=$(awsStringSign4 "${awsSecret}" "${dateValueS}" "${region}" "${service}" "${stringToSign}")

# Upload

curl --silent --location --proto-redir =https --request "${httpReq}" --upload-file "${fileLocal}" \
  --header "Content-Type: ${contentType}" \
  --header "Host: ${bucket}${baseUrl}" \
  --header "X-Amz-Content-SHA256: ${payloadHash}" \
  --header "X-Amz-Date: ${dateValueL}" \
  --header "X-Amz-Server-Side-Encryption: AES256" \
  --header "X-Amz-Storage-Class: ${storageClass}" \
  --header "Authorization: ${authType} Credential=${awsAccess}/${dateValueS}/${region}/${service}/aws4_request, SignedHeaders=${headerList}, Signature=${signature}" \
  "https://${bucket}${baseUrl}/${fileRemote}"
