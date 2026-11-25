package com.edlearn.backend.repository;

import com.edlearn.backend.model.AnnouncementEntity;
import com.edlearn.backend.model.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface AnnouncementRepository extends JpaRepository<AnnouncementEntity, UUID> {
    List<AnnouncementEntity> findByPublisher_InstituteCodeIgnoreCaseOrderByAnnouncementDateDescCreatedAtDesc(String instituteCode);
}
