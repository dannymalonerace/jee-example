package com.example.hello.web.dto;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

public final class FieldErrors {

    private final Map<String, String> errors;

    private FieldErrors(Map<String, String> errors) {
        this.errors = Collections.unmodifiableMap(new LinkedHashMap<>(errors));
    }

    public static FieldErrors of(Map<String, String> errors) {
        return new FieldErrors(errors);
    }

    public static FieldErrors empty() {
        return new FieldErrors(Collections.emptyMap());
    }

    public boolean hasErrors() {
        return !errors.isEmpty();
    }

    public boolean has(String field) {
        return errors.containsKey(field);
    }

    public String get(String field) {
        return errors.get(field);
    }

    public Map<String, String> asMap() {
        return errors;
    }
}
