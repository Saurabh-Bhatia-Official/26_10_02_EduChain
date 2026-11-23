package com.edlearn.backend.controller;

import com.edlearn.backend.model.InstituteEntity;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.InstituteRepository;
import com.edlearn.backend.repository.StoredFileRepository;
import com.edlearn.backend.repository.UserRepository;
import com.edlearn.backend.service.CloudinaryService;
import com.edlearn.backend.service.PortalAccessService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/db")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class DatabaseController {

    private final JdbcTemplate jdbcTemplate;
    private final InstituteRepository instituteRepository;
    private final UserRepository userRepository;
    private final StoredFileRepository storedFileRepository;
    private final CloudinaryService cloudinaryService;
    private final PortalAccessService accessService;

    public DatabaseController(JdbcTemplate jdbcTemplate,
                              InstituteRepository instituteRepository,
                              UserRepository userRepository,
                              StoredFileRepository storedFileRepository,
                              CloudinaryService cloudinaryService,
                              PortalAccessService accessService) {
        this.jdbcTemplate = jdbcTemplate;
        this.instituteRepository = instituteRepository;
        this.userRepository = userRepository;
        this.storedFileRepository = storedFileRepository;
        this.cloudinaryService = cloudinaryService;
        this.accessService = accessService;
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> getDatabaseHealth(HttpServletRequest request) {
        UserEntity actor = accessService.require(request, "admin");
        Map<String, Object> health = new LinkedHashMap<>();
        try {
            String dbProduct = "Unknown";
            String dbVersion = "Unknown";
            String currentUser = "sa";
            String catalog = "edlearndb";
            String url = "";

            if (jdbcTemplate.getDataSource() != null) {
                try (java.sql.Connection conn = jdbcTemplate.getDataSource().getConnection()) {
                    java.sql.DatabaseMetaData meta = conn.getMetaData();
                    dbProduct = meta.getDatabaseProductName();
                    dbVersion = meta.getDatabaseProductVersion();
                    currentUser = meta.getUserName();
                    url = meta.getURL();
                    catalog = conn.getCatalog() != null ? conn.getCatalog() : "edlearndb";
                }
            }

            health.put("databaseStatus", "UP");
            health.put("provider", dbProduct);
            health.put("databaseProduct", dbProduct);
            health.put("databaseName", catalog);
            health.put("databaseUser", currentUser);
            health.put("databaseVersion", dbVersion);
            health.put("jdbcUrl", url);
            health.put("instituteCount", actor.getInstituteCode() == null ? 0 : 1);
            health.put("userCount", userRepository.countByInstituteCodeIgnoreCase(actor.getInstituteCode()));
            health.put("storedFilesCount", storedFileRepository.findByUploadedBy(actor.getId().toString()).size());
            health.put("cloudinary", cloudinaryService.testConnection());
            health.put("status", "CONNECTED");
            return ResponseEntity.ok(health);
        } catch (Exception e) {
            health.put("databaseStatus", "DOWN");
            health.put("error", e.getMessage());
            return ResponseEntity.status(500).body(health);
        }
    }

    @GetMapping("/console")
    public ResponseEntity<Map<String, Object>> getDatabaseConsole(HttpServletRequest request) {
        UserEntity actor = accessService.require(request, "admin");
        Map<String, Object> console = new LinkedHashMap<>();
        console.put("overview", getDatabaseHealth(request).getBody());
        console.put("institutes", actor.getInstituteCode() == null ? List.of()
                : instituteRepository.findByInstituteCodeIgnoreCase(actor.getInstituteCode()).stream().toList());
        console.put("users", userRepository.findByInstituteCodeIgnoreCase(actor.getInstituteCode()));
        console.put("storedFiles", storedFileRepository.findByUploadedBy(actor.getId().toString()));
        return ResponseEntity.ok(console);
    }

    @GetMapping("/institutes")
    public ResponseEntity<List<InstituteEntity>> getAllInstitutes(HttpServletRequest request) {
        UserEntity actor = accessService.require(request, "admin");
        List<InstituteEntity> institutes = actor.getInstituteCode() == null ? List.of()
                : instituteRepository.findByInstituteCodeIgnoreCase(actor.getInstituteCode()).stream().toList();
        return ResponseEntity.ok(institutes);
    }

    @GetMapping("/users")
    public ResponseEntity<List<UserEntity>> getAllUsers(HttpServletRequest request, @RequestParam(required = false) String role) {
        UserEntity actor = accessService.require(request, "admin");
        if (actor.getInstituteCode() == null || actor.getInstituteCode().isBlank()) return ResponseEntity.ok(List.of());
        if (role != null && !role.isBlank()) {
            return ResponseEntity.ok(userRepository.findByInstituteCodeIgnoreCaseAndRoleIgnoreCase(actor.getInstituteCode(), role));
        }
        return ResponseEntity.ok(userRepository.findByInstituteCodeIgnoreCase(actor.getInstituteCode()));
    }
}
