package com.example.convert;

import java.io.IOException;

public enum Description {
    SELECTED_BY_RULE;

    public String toValue() {
        switch (this) {
            case SELECTED_BY_RULE: return "selected by rule";
        }
        return null;
    }

    public static Description forValue(String value) throws IOException {
        if (value.equals("selected by rule")) return SELECTED_BY_RULE;
        throw new IOException("Cannot deserialize Description");
    }
}
