package com.edlearn.backend.repository;

import com.edlearn.backend.model.ClassroomEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ClassroomRepository extends JpaRepository<ClassroomEntity, UUID> {

    Optional<ClassroomEntity> findByInvitationCodeIgnoreCase(String invitationCode);

    List<ClassroomEntity> findByCreatorIdAndIsArchivedFalseOrderByCreatedAtDesc(UUID creatorId);

    @Query("SELECT c FROM ClassroomEntity c WHERE c.isPublic = true AND c.isArchived = false ORDER BY c.createdAt DESC")
    List<ClassroomEntity> findPublicClassrooms();

    @Query("SELECT c FROM ClassroomEntity c WHERE c.isPublic = true AND c.isArchived = false AND " +
           "(LOWER(c.name) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           " LOWER(c.subject) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           " LOWER(c.description) LIKE LOWER(CONCAT('%', :query, '%'))) ORDER BY c.createdAt DESC")
    List<ClassroomEntity> searchPublicClassrooms(@Param("query") String query);

    @Query("SELECT cm.classroom FROM ClassroomMemberEntity cm WHERE cm.user.id = :userId AND cm.classroom.isArchived = false ORDER BY cm.enrolledAt DESC")
    List<ClassroomEntity> findAllClassroomsByUserId(@Param("userId") UUID userId);
}
