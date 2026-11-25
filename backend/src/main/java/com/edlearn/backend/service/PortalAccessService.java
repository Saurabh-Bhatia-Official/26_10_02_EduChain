package com.edlearn.backend.service;

import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.Arrays;
import java.util.Locale;

@Service
public class PortalAccessService {
    private final PortalTokenService tokenService;
    private final UserRepository userRepository;

    public PortalAccessService(PortalTokenService tokenService, UserRepository userRepository) {
        this.tokenService = tokenService;
        this.userRepository = userRepository;
    }

    public UserEntity require(HttpServletRequest request, String... allowedRoles) {
        String header = request.getHeader("Authorization");
        if (header == null || !header.startsWith("Bearer ")) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authentication is required.");
        }
        PortalTokenService.Claims claims;
        try {
            claims = tokenService.verify(header.substring(7));
        } catch (IllegalArgumentException ex) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, ex.getMessage());
        }
        UserEntity user = userRepository.findById(claims.userId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Account no longer exists."));
        String role = user.getRole() == null ? "" : user.getRole().toLowerCase(Locale.ROOT);
        boolean roleMatchesClaims = role.equals(claims.role()) ||
                (isInstructorRole(role) && isInstructorRole(claims.role()));
        if (!roleMatchesClaims) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authentication role is no longer valid.");
        }
        if (!"active".equalsIgnoreCase(user.getStatus())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "This account is not active.");
        }
        if (allowedRoles.length > 0) {
            boolean matched = Arrays.stream(allowedRoles).anyMatch(allowed ->
                allowed.equalsIgnoreCase(role) ||
                (isInstructorRole(allowed) && isInstructorRole(role))
            );
            if (!matched) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Your account cannot access this operation.");
            }
        }
        return user;
    }

    private boolean isInstructorRole(String r) {
        return "teacher".equalsIgnoreCase(r) || "instructor".equalsIgnoreCase(r);
    }

    public java.util.Optional<UserEntity> resolveOptional(HttpServletRequest request) {
        String header = request.getHeader("Authorization");
        if (header == null || !header.startsWith("Bearer ")) {
            return java.util.Optional.empty();
        }
        try {
            PortalTokenService.Claims claims = tokenService.verify(header.substring(7));
            return userRepository.findById(claims.userId());
        } catch (Exception ex) {
            return java.util.Optional.empty();
        }
    }
}
