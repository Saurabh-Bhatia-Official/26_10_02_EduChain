package com.edlearn.backend.repository;

import com.edlearn.backend.model.BatchEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface BatchRepository extends JpaRepository<BatchEntity, UUID> {
    List<BatchEntity> findByCourseIdOrderByCreatedAtDesc(UUID courseId);
    List<BatchEntity> findByInstituteCodeIgnoreCaseOrderByCreatedAtDesc(String instituteCode);
}
