package com.edlearn.backend.repository;

import com.edlearn.backend.model.ExamAttemptEntity;
import com.edlearn.backend.model.ExamEntity;
import com.edlearn.backend.model.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ExamAttemptRepository extends JpaRepository<ExamAttemptEntity, UUID> {
    Optional<ExamAttemptEntity> findByExamAndStudent(ExamEntity exam, UserEntity student);
    boolean existsByExamAndStudent(ExamEntity exam, UserEntity student);
    List<ExamAttemptEntity> findByExamOrderBySubmittedAtDesc(ExamEntity exam);
    List<ExamAttemptEntity> findByStudentOrderByCreatedAtDesc(UserEntity student);
}
