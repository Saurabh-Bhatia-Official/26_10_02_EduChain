package com.edlearn.backend.repository;

import com.edlearn.backend.model.ExamQuestionVersionEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface ExamQuestionVersionRepository extends JpaRepository<ExamQuestionVersionEntity, UUID> {
    List<ExamQuestionVersionEntity> findByQuestionIdOrderByVersionNumberDesc(UUID questionId);
}
