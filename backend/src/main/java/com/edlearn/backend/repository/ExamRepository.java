package com.edlearn.backend.repository;

import com.edlearn.backend.model.ExamEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ExamRepository extends JpaRepository<ExamEntity, UUID> {
    List<ExamEntity> findByInstituteCodeIgnoreCaseOrderByCreatedAtDesc(String instituteCode);
    List<ExamEntity> findByInstituteCodeIgnoreCaseAndStatusIgnoreCaseOrderByCreatedAtDesc(String instituteCode, String status);
}
