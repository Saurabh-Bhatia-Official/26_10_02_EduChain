package com.edlearn.backend.model;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

class UserEntityPasswordJsonTest {
    private final ObjectMapper objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule());

    @Test
    void acceptsPasswordOnInputButNeverSerializesIt() throws Exception {
        UserEntity input = objectMapper.readValue(
                "{\"email\":\"student@example.edu\",\"password\":\"initial-secret\"}",
                UserEntity.class);

        assertEquals("initial-secret", input.getPassword());

        input.setPassword("$2a$10$hashed-password");
        String response = objectMapper.writeValueAsString(input);
        assertFalse(response.contains("password"));
        assertFalse(response.contains("$2a$10$hashed-password"));
    }
}
