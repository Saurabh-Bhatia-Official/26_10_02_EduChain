package com.edlearn.backend.repository;

import com.edlearn.backend.model.ClassroomMemberEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ClassroomMemberRepository extends JpaRepository<ClassroomMemberEntity, UUID> {

    Optional<ClassroomMemberEntity> findByClassroomIdAndUserId(UUID classroomId, UUID userId);

    List<ClassroomMemberEntity> findByClassroomIdOrderByRoleAscEnrolledAtAsc(UUID classroomId);

    List<ClassroomMemberEntity> findByClassroomIdAndStatus(UUID classroomId, String status);

    List<ClassroomMemberEntity> findByUserIdAndStatus(UUID userId, String status);

    @Query("SELECT COUNT(cm) FROM ClassroomMemberEntity cm WHERE cm.classroom.id = :classroomId AND cm.status = 'ACTIVE' AND cm.role = 'STUDENT'")
    long countActiveStudents(@Param("classroomId") UUID classroomId);

    boolean existsByClassroomIdAndUserIdAndStatus(UUID classroomId, UUID userId, String status);
}
