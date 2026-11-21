package com.edlearn.backend.controller;

import com.edlearn.backend.model.StoredFileEntity;
import com.edlearn.backend.repository.StoredFileRepository;
import com.edlearn.backend.service.CloudinaryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.*;

@RestController
@RequestMapping("/api/files")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class FileController {

    private final CloudinaryService cloudinaryService;
    private final StoredFileRepository storedFileRepository;

    public FileController(CloudinaryService cloudinaryService,
                          StoredFileRepository storedFileRepository) {
        this.cloudinaryService = cloudinaryService;
        this.storedFileRepository = storedFileRepository;
    }

    @PostMapping("/upload")
    public ResponseEntity<Map<String, Object>> uploadFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "folder", defaultValue = "edlearn/uploads") String folder,
            @RequestParam(value = "uploadedBy", defaultValue = "user") String uploadedBy) {

        Map<String, Object> response = new LinkedHashMap<>();
        try {
            StoredFileEntity saved = cloudinaryService.uploadFile(file, folder, uploadedBy);
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
            response.put("message", "Cloudinary upload failed: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    @DeleteMapping("/delete")
    public ResponseEntity<Map<String, Object>> deleteFile(@RequestParam("key") String fileKey) {
        Map<String, Object> res = cloudinaryService.deleteFile(fileKey);
        return ResponseEntity.ok(res);
    }

    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> getStorageInfo() {
        Map<String, Object> info = new LinkedHashMap<>();
        info.put("cloudinary", cloudinaryService.testConnection());
        return ResponseEntity.ok(info);
    }

    @GetMapping("/list")
    public ResponseEntity<List<StoredFileEntity>> listStoredFiles() {
        return ResponseEntity.ok(storedFileRepository.findAll());
    }
}
