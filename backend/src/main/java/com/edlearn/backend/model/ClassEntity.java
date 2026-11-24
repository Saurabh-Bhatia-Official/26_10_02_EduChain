package com.edlearn.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "classes")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class ClassEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "instructor_id")
    private UserEntity instructor;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "course_id")
    private CourseEntity course;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "batch_id")
    private BatchEntity batch;

    @Column(name = "title")
    private String title;

    private String subject;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "class_date")
    private String classDate; // YYYY-MM-DD

    @Column(name = "start_time")
    private String startTime; // HH:mm or ISO

    @Column(name = "end_time")
    private String endTime; // HH:mm or ISO

    @Column(name = "duration_minutes")
    private Integer durationMinutes = 60;

    @Column(name = "google_meet_url", length = 500)
    private String googleMeetUrl;

    @Column(name = "thumbnail_url", length = 1000)
    private String thumbnailUrl;

    @Column(length = 50)
    private String status = "Upcoming"; // Upcoming, Live, Completed, Cancelled

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    public ClassEntity() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UserEntity getInstructor() { return instructor; }
    public void setInstructor(UserEntity instructor) { this.instructor = instructor; }

    public CourseEntity getCourse() { return course; }
    public void setCourse(CourseEntity course) { this.course = course; }

    public BatchEntity getBatch() { return batch; }
    public void setBatch(BatchEntity batch) { this.batch = batch; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getClassDate() { return classDate; }
    public void setClassDate(String classDate) { this.classDate = classDate; }

    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }

    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }

    public Integer getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(Integer durationMinutes) { this.durationMinutes = durationMinutes; }

    public String getGoogleMeetUrl() { return googleMeetUrl; }
    public void setGoogleMeetUrl(String googleMeetUrl) { this.googleMeetUrl = googleMeetUrl; }

    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
