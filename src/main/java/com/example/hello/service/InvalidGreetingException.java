package com.example.hello.service;

import com.example.hello.web.dto.FieldErrors;

public class InvalidGreetingException extends RuntimeException {

    private final FieldErrors fieldErrors;

    public InvalidGreetingException(FieldErrors fieldErrors) {
        super("Greeting validation failed");
        this.fieldErrors = fieldErrors;
    }

    public FieldErrors getFieldErrors() {
        return fieldErrors;
    }
}
