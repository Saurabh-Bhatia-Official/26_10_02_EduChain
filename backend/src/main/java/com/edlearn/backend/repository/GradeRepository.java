package com.edlearn.backend.repository;

import com.edlearn.backend.model.GradeEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface GradeRepository extends JpaRepository<GradeEntity, UUID> {

    Optional<GradeEntity> findBySubmissionId(UUID submissionId);

    @Query("SELECT g FROM GradeEntity g WHERE g.submission.assignment.id = :assignmentId")
    List<GradeEntity> findByAssignmentId(@Param("assignmentId") UUID assignmentId);

    @Query("SELECT g FROM GradeEntity g WHERE g.submission.student.id = :studentId ORDER BY g.gradedAt DESC")
    List<GradeEntity> findByStudentId(@Param("studentId") UUID studentId);
}
