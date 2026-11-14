package com.edlearn.backend.controller;

import com.edlearn.backend.dto.ApiResponse;
import com.edlearn.backend.dto.LoginRequest;
import com.edlearn.backend.dto.RegisterRequests.*;
import com.edlearn.backend.service.AuthService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping(value = {"/institute/login", "/institutes/login"}, consumes = {MediaType.APPLICATION_JSON_VALUE, MediaType.ALL_VALUE})
    public ResponseEntity<ApiResponse> loginInstitute(@RequestBody LoginRequest req) {
        return ResponseEntity.ok(authService.loginInstitute(req));
    }

    @PostMapping(value = "/admin/login", consumes = {MediaType.APPLICATION_JSON_VALUE, MediaType.ALL_VALUE})
    public ResponseEntity<ApiResponse> loginAdmin(@RequestBody LoginRequest req) {
        return ResponseEntity.ok(authService.loginAdmin(req));
    }

    @PostMapping(value = "/login", consumes = {MediaType.APPLICATION_JSON_VALUE, MediaType.ALL_VALUE})
    public ResponseEntity<ApiResponse> loginRole(@RequestBody LoginRequest req) {
        if ("institute".equalsIgnoreCase(req.getRole())) {
            return ResponseEntity.ok(authService.loginInstitute(req));
        }
        if ("admin".equalsIgnoreCase(req.getRole())) {
            return ResponseEntity.ok(authService.loginAdmin(req));
        }
        return ResponseEntity.ok(authService.loginRole(req));
    }

    @PostMapping(value = "/register/institute", consumes = {MediaType.APPLICATION_JSON_VALUE, MediaType.ALL_VALUE})
    public ResponseEntity<ApiResponse> registerInstitute(@RequestBody InstituteRegisterRequest req) {
        return ResponseEntity.ok(authService.registerInstitute(req));
    }

    @PostMapping(value = "/register/student", consumes = {MediaType.APPLICATION_JSON_VALUE, MediaType.ALL_VALUE})
    public ResponseEntity<ApiResponse> registerStudent(@RequestBody StudentRegisterRequest req) {
        return ResponseEntity.ok(authService.registerStudent(req));
    }

    @PostMapping(value = "/register/teacher", consumes = {MediaType.APPLICATION_JSON_VALUE, MediaType.ALL_VALUE})
    public ResponseEntity<ApiResponse> registerTeacher(@RequestBody TeacherRegisterRequest req) {
        return ResponseEntity.ok(authService.registerTeacher(req));
    }

    @PostMapping(value = "/forgot-password", consumes = {MediaType.APPLICATION_JSON_VALUE, MediaType.ALL_VALUE})
    public ResponseEntity<ApiResponse> forgotPassword(@RequestBody Map<String, String> body) {
        return ResponseEntity.ok(authService.forgotPassword(body));
    }
}
