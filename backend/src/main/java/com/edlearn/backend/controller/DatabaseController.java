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
        Optional<UserEntity> actorOpt = accessService.resolveOptional(request);
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
            if (actorOpt.isPresent() && "admin".equalsIgnoreCase(actorOpt.get().getRole())) {
                UserEntity actor = actorOpt.get();
                health.put("instituteCount", actor.getInstituteCode() == null ? 0 : 1);
                health.put("userCount", userRepository.countByInstituteCodeIgnoreCase(actor.getInstituteCode()));
                health.put("storedFilesCount", storedFileRepository.findByUploadedBy(actor.getId().toString()).size());
            } else {
                health.put("instituteCount", instituteRepository.count());
                health.put("userCount", userRepository.count());
                health.put("storedFilesCount", storedFileRepository.count());
            }
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
        List<InstituteEntity> institutes = actor.getInstituteCode() == null
                ? instituteRepository.findAll()
                : instituteRepository.findByInstituteCodeIgnoreCase(actor.getInstituteCode()).map(List::of).orElseGet(instituteRepository::findAll);
        console.put("institutes", institutes);

        List<UserEntity> users = actor.getInstituteCode() == null
                ? userRepository.findAll()
                : userRepository.findByInstituteCodeIgnoreCase(actor.getInstituteCode());
        if (users.isEmpty()) {
            users = userRepository.findAll();
        }
        console.put("users", users);

        List<com.edlearn.backend.model.StoredFileEntity> files = storedFileRepository.findByUploadedBy(actor.getId().toString());
        if (files.isEmpty()) {
            files = storedFileRepository.findAll();
        }
        console.put("storedFiles", files);
        return ResponseEntity.ok(console);
    }

    @GetMapping("/institutes")
    public ResponseEntity<List<InstituteEntity>> getAllInstitutes(HttpServletRequest request) {
        UserEntity actor = accessService.require(request, "admin");
        List<InstituteEntity> institutes = actor.getInstituteCode() == null
                ? instituteRepository.findAll()
                : instituteRepository.findByInstituteCodeIgnoreCase(actor.getInstituteCode()).map(List::of).orElseGet(instituteRepository::findAll);
        return ResponseEntity.ok(institutes);
    }

    @GetMapping("/users")
    public ResponseEntity<List<UserEntity>> getAllUsers(HttpServletRequest request, @RequestParam(required = false) String role) {
        UserEntity actor = accessService.require(request, "admin");
        if (role != null && !role.isBlank()) {
            List<UserEntity> byRole = actor.getInstituteCode() != null
                    ? userRepository.findByInstituteCodeIgnoreCaseAndRoleIgnoreCase(actor.getInstituteCode(), role)
                    : List.of();
            if (byRole.isEmpty()) {
                byRole = userRepository.findByRoleIgnoreCase(role);
            }
            return ResponseEntity.ok(byRole);
        }
        List<UserEntity> all = actor.getInstituteCode() != null
                ? userRepository.findByInstituteCodeIgnoreCase(actor.getInstituteCode())
                : List.of();
        if (all.isEmpty()) {
            all = userRepository.findAll();
        }
        return ResponseEntity.ok(all);
    }
}
