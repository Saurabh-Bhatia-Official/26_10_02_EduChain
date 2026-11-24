package com.edlearn.backend.repository;

import com.edlearn.backend.model.StudentProfileEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface StudentProfileRepository extends JpaRepository<StudentProfileEntity, UUID> {
    Optional<StudentProfileEntity> findByUserId(UUID userId);
    List<StudentProfileEntity> findByBatchId(UUID batchId);
    void deleteByUserId(UUID userId);
}
