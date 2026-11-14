package com.edlearn.backend.controller;

import com.edlearn.backend.model.InstituteEntity;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.InstituteRepository;
import com.edlearn.backend.repository.StoredFileRepository;
import com.edlearn.backend.repository.UserRepository;
import com.edlearn.backend.service.CloudinaryService;
import com.edlearn.backend.service.S3StorageService;
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
    private final S3StorageService s3StorageService;
    private final CloudinaryService cloudinaryService;

    public DatabaseController(JdbcTemplate jdbcTemplate,
                              InstituteRepository instituteRepository,
                              UserRepository userRepository,
                              StoredFileRepository storedFileRepository,
                              S3StorageService s3StorageService,
                              CloudinaryService cloudinaryService) {
        this.jdbcTemplate = jdbcTemplate;
        this.instituteRepository = instituteRepository;
        this.userRepository = userRepository;
        this.storedFileRepository = storedFileRepository;
        this.s3StorageService = s3StorageService;
        this.cloudinaryService = cloudinaryService;
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> getDatabaseHealth() {
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
            health.put("provider", dbProduct.toLowerCase().contains("h2") ? "Embedded PostgreSQL-Compatible Engine (H2)" : "PostgreSQL Database Server (" + dbProduct + " " + dbVersion + ")");
            health.put("databaseProduct", dbProduct);
            health.put("databaseName", catalog);
            health.put("databaseUser", currentUser);
            health.put("databaseVersion", dbVersion);
            health.put("jdbcUrl", url);
            health.put("h2WebConsole", dbProduct.toLowerCase().contains("h2") ? "http://localhost:5000/h2-console" : "PostgreSQL Database connected on port 5432");
            health.put("instituteCount", instituteRepository.count());
            health.put("userCount", userRepository.count());
            health.put("storedFilesCount", storedFileRepository.count());
            health.put("s3Storage", s3StorageService.testConnection());
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
    public ResponseEntity<Map<String, Object>> getDatabaseConsole() {
        Map<String, Object> console = new LinkedHashMap<>();
        console.put("overview", getDatabaseHealth().getBody());
        console.put("institutes", instituteRepository.findAll());
        console.put("users", userRepository.findAll());
        console.put("storedFiles", storedFileRepository.findAll());
        return ResponseEntity.ok(console);
    }

    @GetMapping("/institutes")
    public ResponseEntity<List<InstituteEntity>> getAllInstitutes() {
        return ResponseEntity.ok(instituteRepository.findAll());
    }

    @GetMapping("/users")
    public ResponseEntity<List<UserEntity>> getAllUsers(@RequestParam(required = false) String role) {
        if (role != null && !role.isBlank()) {
            return ResponseEntity.ok(userRepository.findByInstituteCodeIgnoreCaseAndRoleIgnoreCase("INST-2025", role));
        }
        return ResponseEntity.ok(userRepository.findAll());
    }
}
