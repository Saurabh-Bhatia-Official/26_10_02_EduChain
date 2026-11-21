package com.edlearn.backend.service;

import com.edlearn.backend.model.UserEntity;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.UUID;

@Component
public class PortalTokenService {
    private static final long TOKEN_LIFETIME_SECONDS = 12 * 60 * 60;

    @Value("${edlearn.auth.secret:}")
    private String configuredSecret;

    private byte[] secret;

    @PostConstruct
    void initialize() {
        if (configuredSecret != null && !configuredSecret.isBlank()) {
            secret = configuredSecret.getBytes(StandardCharsets.UTF_8);
            if (secret.length < 32) {
                throw new IllegalStateException("EDLEARN_AUTH_SECRET must contain at least 32 bytes.");
            }
        } else {
            secret = new byte[32];
            new SecureRandom().nextBytes(secret);
        }
    }

    public String issue(UserEntity user) {
        String payload = user.getId() + "|" + user.getRole().toLowerCase() + "|"
                + (System.currentTimeMillis() / 1000 + TOKEN_LIFETIME_SECONDS);
        String encodedPayload = Base64.getUrlEncoder().withoutPadding()
                .encodeToString(payload.getBytes(StandardCharsets.UTF_8));
        return encodedPayload + "." + Base64.getUrlEncoder().withoutPadding()
                .encodeToString(sign(encodedPayload));
    }

    public Claims verify(String token) {
        if (token == null) {
            throw new IllegalArgumentException("Authentication is required.");
        }
        String[] parts = token.split("\\.", -1);
        if (parts.length != 2 || !MessageDigest.isEqual(sign(parts[0]), decode(parts[1]))) {
            throw new IllegalArgumentException("Invalid authentication token.");
        }
        try {
            String[] claims = new String(Base64.getUrlDecoder().decode(parts[0]), StandardCharsets.UTF_8).split("\\|", -1);
            if (claims.length != 3 || Long.parseLong(claims[2]) <= System.currentTimeMillis() / 1000) {
                throw new IllegalArgumentException("Authentication token has expired.");
            }
            return new Claims(UUID.fromString(claims[0]), claims[1]);
        } catch (IllegalArgumentException ex) {
            throw ex;
        } catch (RuntimeException ex) {
            throw new IllegalArgumentException("Invalid authentication token.", ex);
        }
    }

    private byte[] sign(String value) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret, "HmacSHA256"));
            return mac.doFinal(value.getBytes(StandardCharsets.UTF_8));
        } catch (Exception ex) {
            throw new IllegalStateException("Could not sign authentication token.", ex);
        }
    }

    private byte[] decode(String value) {
        try {
            return Base64.getUrlDecoder().decode(value);
        } catch (IllegalArgumentException ex) {
            return new byte[0];
        }
    }

    public record Claims(UUID userId, String role) {}
}
