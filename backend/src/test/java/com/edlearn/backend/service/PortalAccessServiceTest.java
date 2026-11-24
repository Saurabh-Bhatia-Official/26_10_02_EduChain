package com.edlearn.backend.service;

import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.web.server.ResponseStatusException;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class PortalAccessServiceTest {
    private final PortalTokenService tokenService = new PortalTokenService();
    private UserRepository userRepository;
    private PortalAccessService accessService;
    private UserEntity student;

    @BeforeEach
    void setUp() {
        org.springframework.test.util.ReflectionTestUtils.setField(tokenService, "configuredSecret", "test-only-signing-secret-with-32-bytes");
        tokenService.initialize();
        userRepository = mock(UserRepository.class);
        accessService = new PortalAccessService(tokenService, userRepository);
        student = new UserEntity();
        student.setId(UUID.randomUUID());
        student.setRole("student");
        student.setStatus("Active");
        when(userRepository.findById(student.getId())).thenReturn(Optional.of(student));
    }

    @Test
    void acceptsValidTokenForAllowedRole() {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader("Authorization", "Bearer " + tokenService.issue(student));

        assertSame(student, accessService.require(request, "student"));
    }

    @Test
    void rejectsForgedTokensAndWrongRoles() {
        MockHttpServletRequest forged = new MockHttpServletRequest();
        forged.addHeader("Authorization", "Bearer jwt-admin-fake");
        assertEquals(401, assertThrows(ResponseStatusException.class,
                () -> accessService.require(forged, "admin")).getStatusCode().value());

        MockHttpServletRequest wrongRole = new MockHttpServletRequest();
        wrongRole.addHeader("Authorization", "Bearer " + tokenService.issue(student));
        assertEquals(403, assertThrows(ResponseStatusException.class,
                () -> accessService.require(wrongRole, "admin")).getStatusCode().value());
    }
}
