package com.edlearn.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "assignments")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class AssignmentEntity {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "classroom_id", nullable = true)
    private ClassroomEntity classroom;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "course_id")
    private CourseEntity course;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "batch_id")
    private BatchEntity batch;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "instructor_id")
    private UserEntity instructor;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(columnDefinition = "TEXT")
    private String instructions;

    @Column(name = "attachment_url", length = 1000)
    private String attachmentUrl;

    @Column(name = "start_date")
    private LocalDateTime startDate;

    @Column(name = "due_date")
    private LocalDateTime dueDate;

    @Column(name = "points_possible")
    private int pointsPossible = 100;

    @Column(name = "maximum_marks")
    private Integer maximumMarks = 100;

    @Column(length = 100)
    private String topic = "General";

    @Column(name = "allow_late_submissions")
    private boolean allowLateSubmissions = true;

    @Column(name = "allow_resubmission")
    private boolean allowResubmission = false;

    @Column(name = "allowed_file_types")
    private String allowedFileTypes = "PDF, DOC, DOCX, JPG, PNG";

    @Column(length = 30)
    private String status = "PUBLISHED"; // DRAFT, PUBLISHED, SCHEDULED

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "created_by", nullable = true)
    private UserEntity createdBy;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    public AssignmentEntity() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public ClassroomEntity getClassroom() { return classroom; }
    public void setClassroom(ClassroomEntity classroom) { this.classroom = classroom; }

    public CourseEntity getCourse() { return course; }
    public void setCourse(CourseEntity course) { this.course = course; }

    public BatchEntity getBatch() { return batch; }
    public void setBatch(BatchEntity batch) { this.batch = batch; }

    public UserEntity getInstructor() { return instructor != null ? instructor : createdBy; }
    public void setInstructor(UserEntity instructor) {
        this.instructor = instructor;
        if (this.createdBy == null) this.createdBy = instructor;
    }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getInstructions() { return instructions; }
    public void setInstructions(String instructions) { this.instructions = instructions; }

    public String getAttachmentUrl() { return attachmentUrl; }
    public void setAttachmentUrl(String attachmentUrl) { this.attachmentUrl = attachmentUrl; }

    public LocalDateTime getStartDate() { return startDate; }
    public void setStartDate(LocalDateTime startDate) { this.startDate = startDate; }

    public LocalDateTime getDueDate() { return dueDate; }
    public void setDueDate(LocalDateTime dueDate) { this.dueDate = dueDate; }

    public int getPointsPossible() { return pointsPossible > 0 ? pointsPossible : (maximumMarks != null ? maximumMarks : 100); }
    public void setPointsPossible(int pointsPossible) {
        this.pointsPossible = pointsPossible;
        this.maximumMarks = pointsPossible;
    }

    public Integer getMaximumMarks() { return maximumMarks != null ? maximumMarks : pointsPossible; }
    public void setMaximumMarks(Integer maximumMarks) {
        this.maximumMarks = maximumMarks;
        if (maximumMarks != null) this.pointsPossible = maximumMarks;
    }

    public String getTopic() { return topic; }
    public void setTopic(String topic) { this.topic = topic; }

    public boolean isAllowLateSubmissions() { return allowLateSubmissions; }
    public void setAllowLateSubmissions(boolean allowLateSubmissions) { this.allowLateSubmissions = allowLateSubmissions; }

    public boolean isAllowResubmission() { return allowResubmission; }
    public void setAllowResubmission(boolean allowResubmission) { this.allowResubmission = allowResubmission; }

    public String getAllowedFileTypes() { return allowedFileTypes; }
    public void setAllowedFileTypes(String allowedFileTypes) { this.allowedFileTypes = allowedFileTypes; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public UserEntity getCreatedBy() { return createdBy != null ? createdBy : instructor; }
    public void setCreatedBy(UserEntity createdBy) {
        this.createdBy = createdBy;
        if (this.instructor == null) this.instructor = createdBy;
    }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
