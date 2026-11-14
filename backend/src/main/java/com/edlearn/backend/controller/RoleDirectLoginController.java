package com.edlearn.backend.controller;

import com.edlearn.backend.dto.ApiResponse;
import com.edlearn.backend.dto.LoginRequest;
import com.edlearn.backend.dto.RegisterRequests.InstituteRegisterRequest;
import com.edlearn.backend.service.AuthService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class RoleDirectLoginController {

    private final AuthService authService;

    public RoleDirectLoginController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping(value = "/api/institutes/login", consumes = {MediaType.APPLICATION_JSON_VALUE, MediaType.ALL_VALUE})
    public ResponseEntity<ApiResponse> instituteLoginDirect(@RequestBody LoginRequest req) {
        return ResponseEntity.ok(authService.loginInstitute(req));
    }

    @PostMapping(value = "/api/institutes/register", consumes = {MediaType.APPLICATION_JSON_VALUE, MediaType.ALL_VALUE})
    public ResponseEntity<ApiResponse> instituteRegisterDirect(@RequestBody InstituteRegisterRequest req) {
        return ResponseEntity.ok(authService.registerInstitute(req));
    }

    @PostMapping(value = "/api/admin/login", consumes = {MediaType.APPLICATION_JSON_VALUE, MediaType.ALL_VALUE})
    public ResponseEntity<ApiResponse> adminLoginDirect(@RequestBody LoginRequest req) {
        return ResponseEntity.ok(authService.loginAdmin(req));
    }
}
