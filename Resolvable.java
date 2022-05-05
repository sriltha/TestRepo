package com.example.convert;

import java.io.IOException;

public enum Resolvable {
    RESOLVED, RESOLVED_CONSTRAINT, UNRESOLVED;

    public String toValue() {
        switch (this) {
            case RESOLVED: return "RESOLVED";
            case RESOLVED_CONSTRAINT: return "RESOLVED_CONSTRAINT";
            case UNRESOLVED: return "UNRESOLVED";
        }
        return null;
    }

    public static Resolvable forValue(String value) throws IOException {
        if (value.equals("RESOLVED")) return RESOLVED;
        if (value.equals("RESOLVED_CONSTRAINT")) return RESOLVED_CONSTRAINT;
        if (value.equals("UNRESOLVED")) return UNRESOLVED;
        throw new IOException("Cannot deserialize Resolvable");
    }
}
