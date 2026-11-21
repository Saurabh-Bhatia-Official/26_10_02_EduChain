package com.edlearn.backend.repository;

import com.edlearn.backend.model.PortalNotificationEntity;
import com.edlearn.backend.model.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface PortalNotificationRepository extends JpaRepository<PortalNotificationEntity, UUID> {
    List<PortalNotificationEntity> findTop50ByUserOrderByCreatedAtDesc(UserEntity user);
    long countByUserAndReadAtIsNull(UserEntity user);
    List<PortalNotificationEntity> findByUserAndTargetTypeAndTargetIdAndReadAtIsNull(
            UserEntity user, String targetType, String targetId);
    void deleteByTargetTypeAndTargetId(String targetType, String targetId);
}
