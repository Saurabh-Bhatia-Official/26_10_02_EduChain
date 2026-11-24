package com.edlearn.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;

public final class PortalRequests {
    private PortalRequests() {}

    public record AnnouncementRequest(
            @NotBlank @Size(max = 200) String title,
            @NotBlank @Size(max = 10000) String description,
            @NotBlank String audience,
            @NotNull LocalDate announcementDate,
            LocalDate expiresAt,
            boolean published) {}

    public record LeaveRequest(
            @NotBlank @Size(max = 60) String leaveType,
            @NotNull LocalDate startDate,
            @NotNull LocalDate endDate,
            @NotBlank @Size(max = 2000) String reason,
            @Size(max = 1000) String documentUrl) {}

    public record DecisionRequest(@NotBlank String decision, @Size(max = 1000) String remark) {}
    public record TeacherAssignmentRequest(@NotBlank String teacherId) {}
}
