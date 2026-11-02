package com.edlearn.backend.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.edlearn.backend.model.StoredFileEntity;
import com.edlearn.backend.repository.StoredFileRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.*;

@Service
public class CloudinaryService {

    private static final Logger log = LoggerFactory.getLogger(CloudinaryService.class);

    private final Cloudinary cloudinary;
    private final StoredFileRepository storedFileRepository;

    public CloudinaryService(Cloudinary cloudinary, StoredFileRepository storedFileRepository) {
        this.cloudinary = cloudinary;
        this.storedFileRepository = storedFileRepository;
    }

    public StoredFileEntity uploadFile(MultipartFile file, String folder, String uploadedBy) throws IOException {
        String originalFilename = file.getOriginalFilename() != null ? file.getOriginalFilename() : "file";
        String cleanFolder = (folder != null && !folder.isBlank()) ? folder.trim() : "edlearn/uploads";

        Map<?, ?> uploadResult = cloudinary.uploader().upload(file.getBytes(), ObjectUtils.asMap(
                "folder", cleanFolder,
                "resource_type", "auto",
                "use_filename", true,
                "unique_filename", true
        ));

        String publicId = (String) uploadResult.get("public_id");
        String secureUrl = (String) uploadResult.get("secure_url");
        String format = (String) uploadResult.get("format");
        Long bytes = uploadResult.get("bytes") instanceof Number ? ((Number) uploadResult.get("bytes")).longValue() : file.getSize();

        StoredFileEntity storedFile = new StoredFileEntity();
        storedFile.setFileKey(publicId);
        storedFile.setFileName(originalFilename);
        storedFile.setContentType(file.getContentType() != null ? file.getContentType() : "image/" + format);
        storedFile.setFileSize(bytes);
        storedFile.setBucketName("cloudinary");
        storedFile.setFileUrl(secureUrl);
        storedFile.setUploadedBy(uploadedBy != null ? uploadedBy : "user");

        return storedFileRepository.save(storedFile);
    }

    public Map<String, Object> deleteFile(String publicId) {
        Map<String, Object> res = new HashMap<>();
        try {
            Map<?, ?> result = cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
            storedFileRepository.findByFileKey(publicId).ifPresent(storedFileRepository::delete);
            res.put("success", true);
            res.put("result", result.get("result"));
        } catch (Exception e) {
            res.put("success", false);
            res.put("error", e.getMessage());
        }
        return res;
    }

    public Map<String, Object> testConnection() {
        Map<String, Object> info = new LinkedHashMap<>();
        info.put("provider", "Cloudinary Media Cloud");
        info.put("cloudName", cloudinary.config.cloudName);
        info.put("status", "CONNECTED");
        info.put("success", true);
        return info;
    }
}
