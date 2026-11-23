package com.edlearn.backend.repository;

import com.edlearn.backend.model.LiveClassEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface LiveClassRepository extends JpaRepository<LiveClassEntity, UUID> {

    List<LiveClassEntity> findByClassroomIdOrderByStartTimeDesc(UUID classroomId);

    List<LiveClassEntity> findByClassroomIdAndStatusOrderByStartTimeAsc(UUID classroomId, String status);

    @Query("SELECT lc FROM LiveClassEntity lc WHERE lc.classroom.id = :classroomId AND lc.endTime >= :now AND lc.status != 'CANCELLED' ORDER BY lc.startTime ASC")
    List<LiveClassEntity> findUpcomingByClassroomId(@Param("classroomId") UUID classroomId, @Param("now") LocalDateTime now);

    @Query("SELECT DISTINCT lc FROM LiveClassEntity lc JOIN ClassroomMemberEntity cm ON cm.classroom.id = lc.classroom.id " +
           "WHERE cm.user.id = :userId AND cm.status = 'ACTIVE' AND lc.endTime >= :now AND lc.status != 'CANCELLED' " +
           "ORDER BY lc.startTime ASC")
    List<LiveClassEntity> findUpcomingByUserId(@Param("userId") UUID userId, @Param("now") LocalDateTime now);
}
