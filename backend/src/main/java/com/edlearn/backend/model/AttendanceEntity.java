package com.edlearn.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "attendance", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"live_class_id", "user_id"})
})
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class AttendanceEntity {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "live_class_id", nullable = false)
    private LiveClassEntity liveClass;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;

    @Column(length = 30)
    private String status = "PRESENT"; // PRESENT, ABSENT, LATE, EXCUSED

    @Column(name = "join_time")
    private LocalDateTime joinTime;

    @Column(name = "leave_time")
    private LocalDateTime leaveTime;

    @Column(name = "duration_minutes")
    private int durationMinutes = 0;

    public AttendanceEntity() {}

    public AttendanceEntity(LiveClassEntity liveClass, UserEntity user, String status, LocalDateTime joinTime) {
        this.liveClass = liveClass;
        this.user = user;
        this.status = status;
        this.joinTime = joinTime;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public LiveClassEntity getLiveClass() { return liveClass; }
    public void setLiveClass(LiveClassEntity liveClass) { this.liveClass = liveClass; }

    public UserEntity getUser() { return user; }
    public void setUser(UserEntity user) { this.user = user; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getJoinTime() { return joinTime; }
    public void setJoinTime(LocalDateTime joinTime) { this.joinTime = joinTime; }

    public LocalDateTime getLeaveTime() { return leaveTime; }
    public void setLeaveTime(LocalDateTime leaveTime) { this.leaveTime = leaveTime; }

    public int getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(int durationMinutes) { this.durationMinutes = durationMinutes; }
}
