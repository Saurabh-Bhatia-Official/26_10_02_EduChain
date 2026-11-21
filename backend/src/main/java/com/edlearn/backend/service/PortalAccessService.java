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
        if (!role.equals(claims.role())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authentication role is no longer valid.");
        }
        if (!"active".equalsIgnoreCase(user.getStatus())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "This account is not active.");
        }
        if (allowedRoles.length > 0 && Arrays.stream(allowedRoles).noneMatch(role::equals)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Your account cannot access this operation.");
        }
        return user;
    }
}
