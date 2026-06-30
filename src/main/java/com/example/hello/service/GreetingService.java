package com.example.hello.service;

import com.example.hello.entity.Greeting;
import com.example.hello.repository.GreetingRepository;
import com.example.hello.web.dto.FieldErrors;
import com.example.hello.web.dto.GreetingForm;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validator;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@ApplicationScoped
@Transactional
public class GreetingService {

    private final GreetingRepository repository;
    private final Validator validator;

    @Inject
    public GreetingService(GreetingRepository repository, Validator validator) {
        this.repository = repository;
        this.validator = validator;
    }

    GreetingService() {
        this(null, null);
    }

    public Greeting create(GreetingForm form) {
        Set<ConstraintViolation<GreetingForm>> violations = validator.validate(form);
        if (!violations.isEmpty()) {
            Map<String, String> errors = new LinkedHashMap<>();
            for (ConstraintViolation<GreetingForm> v : violations) {
                errors.putIfAbsent(v.getPropertyPath().toString(), v.getMessage());
            }
            throw new InvalidGreetingException(FieldErrors.of(errors));
        }

        Greeting greeting = new Greeting(form.getName().trim(), form.getMessage().trim());
        return repository.save(greeting);
    }

    public List<Greeting> listAll() {
        return repository.findAllNewestFirst();
    }
}
