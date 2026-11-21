package com.edlearn.backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "announcement_reads", uniqueConstraints = @UniqueConstraint(
        name = "uk_announcement_read_user", columnNames = {"announcement_id", "user_id"}))
public class AnnouncementReadEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "announcement_id", nullable = false)
    private AnnouncementEntity announcement;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;

    @Column(name = "read_at", nullable = false)
    private LocalDateTime readAt = LocalDateTime.now();

    public AnnouncementReadEntity() {}
    public AnnouncementReadEntity(AnnouncementEntity announcement, UserEntity user) {
        this.announcement = announcement;
        this.user = user;
    }
}
