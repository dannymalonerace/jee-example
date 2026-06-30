package com.example.hello.service;

import com.example.hello.entity.Greeting;
import com.example.hello.repository.GreetingRepository;
import com.example.hello.web.dto.GreetingForm;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GreetingServiceTest {

    @Mock
    GreetingRepository repository;

    static ValidatorFactory validatorFactory;
    static Validator validator;

    @BeforeAll
    static void initValidator() {
        validatorFactory = Validation.buildDefaultValidatorFactory();
        validator = validatorFactory.getValidator();
    }

    @AfterAll
    static void closeValidator() {
        validatorFactory.close();
    }

    @Test
    void create_persists_a_valid_greeting_and_trims_input() {
        GreetingService service = new GreetingService(repository, validator);
        when(repository.save(any(Greeting.class))).thenAnswer(i -> i.getArgument(0));

        Greeting result = service.create(new GreetingForm("  Ada  ", "  hello world  "));

        ArgumentCaptor<Greeting> captor = ArgumentCaptor.forClass(Greeting.class);
        verify(repository).save(captor.capture());
        assertThat(captor.getValue().getName()).isEqualTo("Ada");
        assertThat(captor.getValue().getMessage()).isEqualTo("hello world");
        assertThat(result.getName()).isEqualTo("Ada");
    }

    @Test
    void create_rejects_blank_name() {
        GreetingService service = new GreetingService(repository, validator);

        assertThatThrownBy(() -> service.create(new GreetingForm("  ", "hi")))
                .isInstanceOf(InvalidGreetingException.class)
                .satisfies(ex -> {
                    InvalidGreetingException ige = (InvalidGreetingException) ex;
                    assertThat(ige.getFieldErrors().has("name")).isTrue();
                });

        verify(repository, never()).save(any());
    }

    @Test
    void create_rejects_blank_message() {
        GreetingService service = new GreetingService(repository, validator);

        assertThatThrownBy(() -> service.create(new GreetingForm("Bob", "")))
                .isInstanceOf(InvalidGreetingException.class)
                .satisfies(ex -> assertThat(((InvalidGreetingException) ex).getFieldErrors().has("message")).isTrue());

        verify(repository, never()).save(any());
    }

    @Test
    void create_rejects_oversize_message() {
        GreetingService service = new GreetingService(repository, validator);
        String big = "x".repeat(501);

        assertThatThrownBy(() -> service.create(new GreetingForm("Bob", big)))
                .isInstanceOf(InvalidGreetingException.class);

        verify(repository, never()).save(any());
    }

    @Test
    void listAll_delegates_to_repository() {
        GreetingService service = new GreetingService(repository, validator);
        Greeting g = new Greeting("Ada", "hi");
        when(repository.findAllNewestFirst()).thenReturn(List.of(g));

        List<Greeting> all = service.listAll();

        assertThat(all).containsExactly(g);
    }
}
