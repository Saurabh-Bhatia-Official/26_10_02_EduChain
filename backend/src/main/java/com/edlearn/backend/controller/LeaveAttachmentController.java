package com.edlearn.backend.controller;

import com.edlearn.backend.model.StoredFileEntity;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.service.CloudinaryService;
import com.edlearn.backend.service.PortalAccessService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.util.Map;
import java.util.Locale;
import java.util.Set;

@RestController
@RequestMapping("/api/portal/leave-attachments")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class LeaveAttachmentController {
    private static final long MAX_FILE_SIZE = 10L * 1024 * 1024;
    private static final Set<String> ALLOWED_TYPES = Set.of("application/pdf", "image/jpeg", "image/png");

    private final PortalAccessService accessService;
    private final CloudinaryService cloudinaryService;

    public LeaveAttachmentController(PortalAccessService accessService, CloudinaryService cloudinaryService) {
        this.accessService = accessService;
        this.cloudinaryService = cloudinaryService;
    }

    @PostMapping
    public Map<String, Object> upload(HttpServletRequest request, @RequestParam("file") MultipartFile file) throws IOException {
        UserEntity user = accessService.require(request, "student", "teacher");
        String contentType = file.getContentType();
        if (file.isEmpty() || file.getSize() > MAX_FILE_SIZE || contentType == null
                || !ALLOWED_TYPES.contains(contentType.toLowerCase(Locale.ROOT))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Upload a PDF, JPEG, or PNG file up to 10 MB.");
        }
        StoredFileEntity stored = cloudinaryService.uploadFile(file, "edlearn/leave-documents", user.getId().toString());
        return Map.of("fileUrl", stored.getFileUrl(), "fileName", stored.getFileName());
    }
}
