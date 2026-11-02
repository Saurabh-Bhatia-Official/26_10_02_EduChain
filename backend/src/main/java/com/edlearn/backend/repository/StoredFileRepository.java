package com.edlearn.backend.repository;

import com.edlearn.backend.model.StoredFileEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StoredFileRepository extends JpaRepository<StoredFileEntity, Long> {
    Optional<StoredFileEntity> findByFileKey(String fileKey);
    List<StoredFileEntity> findByUploadedBy(String uploadedBy);
}
