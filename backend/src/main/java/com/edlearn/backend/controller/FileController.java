package com.edlearn.backend.controller;

import com.edlearn.backend.model.StoredFileEntity;
import com.edlearn.backend.repository.StoredFileRepository;
import com.edlearn.backend.service.CloudinaryService;
import com.edlearn.backend.service.PortalAccessService;
import com.edlearn.backend.model.UserEntity;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.*;
import java.util.Locale;
import java.util.Set;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/files")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class FileController {
    private static final long MAX_UPLOAD_BYTES = 25L * 1024 * 1024;
    private static final Set<String> ALLOWED_EXTENSIONS = Set.of("pdf", "png", "jpg", "jpeg", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "zip");

    private final CloudinaryService cloudinaryService;
    private final StoredFileRepository storedFileRepository;
    private final PortalAccessService accessService;

    public FileController(CloudinaryService cloudinaryService,
                          StoredFileRepository storedFileRepository,
                          PortalAccessService accessService) {
        this.cloudinaryService = cloudinaryService;
        this.storedFileRepository = storedFileRepository;
        this.accessService = accessService;
    }

    @PostMapping("/upload")
    public ResponseEntity<Map<String, Object>> uploadFile(
            HttpServletRequest request,
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "folder", defaultValue = "edlearn/uploads") String folder,
            @RequestParam(value = "uploadedBy", defaultValue = "user") String uploadedBy) {

        UserEntity actor = accessService.require(request, "admin", "teacher", "student");
        String filename = Objects.toString(file.getOriginalFilename(), "");
        String extension = filename.contains(".") ? filename.substring(filename.lastIndexOf('.') + 1).toLowerCase(Locale.ROOT) : "";
        if (file.isEmpty() || file.getSize() > MAX_UPLOAD_BYTES || !ALLOWED_EXTENSIONS.contains(extension)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Upload a supported document up to 25 MB.");
        }

        Map<String, Object> response = new LinkedHashMap<>();
        try {
            StoredFileEntity saved = cloudinaryService.uploadFile(file, "edlearn/uploads/" + actor.getId(), actor.getId().toString());
            response.put("success", true);
            response.put("provider", "Cloudinary");
            response.put("message", "File successfully uploaded to Cloudinary Media Cloud");
            response.put("fileKey", saved.getFileKey());
            response.put("fileName", saved.getFileName());
            response.put("fileUrl", saved.getFileUrl());
            response.put("fileSize", saved.getFileSize());
            response.put("contentType", saved.getContentType());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "File upload failed. Check the configured storage service and try again.");
            return ResponseEntity.internalServerError().body(response);
        }
    }

    @DeleteMapping("/delete")
    public ResponseEntity<Map<String, Object>> deleteFile(HttpServletRequest request, @RequestParam("key") String fileKey) {
        UserEntity actor = accessService.require(request, "admin", "teacher", "student");
        StoredFileEntity stored = storedFileRepository.findByFileKey(fileKey)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "File not found."));
        if (!"admin".equalsIgnoreCase(actor.getRole()) && !actor.getId().toString().equals(stored.getUploadedBy())) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "File not found.");
        }
        Map<String, Object> res = cloudinaryService.deleteFile(stored.getFileKey());
        return ResponseEntity.ok(res);
    }

    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> getStorageInfo(HttpServletRequest request) {
        accessService.require(request, "admin");
        Map<String, Object> info = new LinkedHashMap<>();
        info.put("cloudinary", cloudinaryService.testConnection());
        return ResponseEntity.ok(info);
    }

    @GetMapping("/list")
    public ResponseEntity<List<StoredFileEntity>> listStoredFiles(HttpServletRequest request) {
        UserEntity actor = accessService.require(request, "admin");
        return ResponseEntity.ok(storedFileRepository.findByUploadedBy(actor.getId().toString()));
    }
}
