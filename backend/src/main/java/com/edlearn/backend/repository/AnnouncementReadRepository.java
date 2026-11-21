package com.edlearn.backend.repository;

import com.edlearn.backend.model.AnnouncementEntity;
import com.edlearn.backend.model.AnnouncementReadEntity;
import com.edlearn.backend.model.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface AnnouncementReadRepository extends JpaRepository<AnnouncementReadEntity, Long> {
    boolean existsByAnnouncementAndUser(AnnouncementEntity announcement, UserEntity user);
    Optional<AnnouncementReadEntity> findByAnnouncementAndUser(AnnouncementEntity announcement, UserEntity user);
    void deleteByAnnouncement(AnnouncementEntity announcement);
}
