package com.edlearn.backend.repository;

import com.edlearn.backend.model.EnrollmentEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface EnrollmentRepository extends JpaRepository<EnrollmentEntity, UUID> {
    List<EnrollmentEntity> findByStudentId(UUID studentId);
    List<EnrollmentEntity> findByCourseId(UUID courseId);
    List<EnrollmentEntity> findByBatchId(UUID batchId);
    Optional<EnrollmentEntity> findByStudentIdAndCourseIdAndBatchId(UUID studentId, UUID courseId, UUID batchId);
    boolean existsByStudentIdAndCourseId(UUID studentId, UUID courseId);
    boolean existsByStudentIdAndBatchId(UUID studentId, UUID batchId);
    long countByBatchId(UUID batchId);
    long countByCourseId(UUID courseId);
    long countByStudentId(UUID studentId);
}
