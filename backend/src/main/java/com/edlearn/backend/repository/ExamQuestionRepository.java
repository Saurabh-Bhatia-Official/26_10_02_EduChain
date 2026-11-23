package com.edlearn.backend.repository;

import com.edlearn.backend.model.ExamQuestionEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ExamQuestionRepository extends JpaRepository<ExamQuestionEntity, UUID> {
    List<ExamQuestionEntity> findByInstituteCodeIgnoreCaseOrderByUpdatedAtDesc(String instituteCode);
    Optional<ExamQuestionEntity> findByIdAndInstituteCodeIgnoreCase(UUID id, String instituteCode);
}
