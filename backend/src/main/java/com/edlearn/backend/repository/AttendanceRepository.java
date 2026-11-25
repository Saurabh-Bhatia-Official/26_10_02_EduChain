package com.edlearn.backend.repository;

import com.edlearn.backend.model.AttendanceEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AttendanceRepository extends JpaRepository<AttendanceEntity, UUID> {

    Optional<AttendanceEntity> findByLiveClassIdAndUserId(UUID liveClassId, UUID userId);

    List<AttendanceEntity> findByLiveClassIdOrderByJoinTimeAsc(UUID liveClassId);

    List<AttendanceEntity> findByUserIdOrderByJoinTimeDesc(UUID userId);

    long countByLiveClassIdAndStatus(UUID liveClassId, String status);
}
