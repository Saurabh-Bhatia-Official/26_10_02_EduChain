package com.edlearn.backend.service;

import com.edlearn.backend.dto.PortalRequests.AnnouncementRequest;
import com.edlearn.backend.dto.PortalRequests.DecisionRequest;
import com.edlearn.backend.dto.PortalRequests.LeaveRequest;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@EnabledIfEnvironmentVariable(named = "TEST_DATABASE_URL", matches = "jdbc:postgresql://.+")
class PortalModuleServiceIntegrationTest {
    @Autowired private PortalModuleService modules;
    @Autowired private UserRepository users;

    private UserEntity admin;
    private UserEntity teacher;
    private UserEntity student;

    @BeforeEach
    void setUp() {
        String instituteCode = "PORTAL-" + UUID.randomUUID().toString().substring(0, 8);
        admin = saveUser("admin", instituteCode, "Admin");
        teacher = saveUser("teacher", instituteCode, "Teacher");
        student = saveUser("student", instituteCode, "Student");
        student.setAssignedTeacher(teacher);
        users.save(student);
    }

    @Test
    void announcementAudienceAndReadStatusAreRoleScoped() {
        Map<String, Object> announcement = modules.createAnnouncement(admin, new AnnouncementRequest(
                "Exam schedule", "The exam schedule is published.", "STUDENTS",
                LocalDate.now(), LocalDate.now().plusDays(7), true));
        UUID id = UUID.fromString(announcement.get("id").toString());

        assertEquals(1, modules.announcements(student).size());
        assertTrue(modules.announcements(teacher).isEmpty());
        assertEquals(1, modules.unreadNotificationCount(student));
        modules.markAnnouncementRead(student, id);
        assertEquals(Boolean.TRUE, modules.announcements(student).get(0).get("read"));
        assertEquals(0, modules.unreadNotificationCount(student));

        modules.updateAnnouncement(admin, id, new AnnouncementRequest(
                "Updated schedule", "The revised schedule is available.", "TEACHERS",
                LocalDate.now(), null, true));
        assertTrue(modules.announcements(student).isEmpty());
        assertEquals(1, modules.announcements(teacher).size());
        assertEquals(0, modules.unreadNotificationCount(student));
        assertEquals(1, modules.unreadNotificationCount(teacher));
        modules.deleteAnnouncement(admin, id);
        assertTrue(modules.announcements(teacher).isEmpty());
        assertEquals(0, modules.unreadNotificationCount(teacher));
    }

    @Test
    void studentAndTeacherLeaveApprovalsPersistHistoryAndNotifyApplicants() {
        LeaveRequest leave = new LeaveRequest("Medical", LocalDate.now().plusDays(2),
                LocalDate.now().plusDays(3), "Medical appointment", null);
        Map<String, Object> created = modules.submitLeave(student, leave);
        UUID studentLeaveId = UUID.fromString(created.get("id").toString());

        assertEquals(1, modules.unreadNotificationCount(teacher));
        assertEquals("PENDING", modules.leaves(teacher, null, null, null, null, null).get(0).get("status"));
        assertEquals(409, assertThrows(ResponseStatusException.class,
                () -> modules.submitLeave(student, leave)).getStatusCode().value());

        Map<String, Object> teacherReview = modules.decideLeave(teacher, studentLeaveId,
                new DecisionRequest("APPROVED", "Teacher reviewed"));
        assertEquals("WAITING_ADMIN", teacherReview.get("status"));
        assertEquals(1, modules.unreadNotificationCount(admin));

        Map<String, Object> adminReview = modules.decideLeave(admin, studentLeaveId,
                new DecisionRequest("APPROVED", "Admin reviewed"));
        assertEquals("APPROVED", adminReview.get("status"));
        List<Map<String, Object>> studentHistory = modules.leaves(student, null, null, null, null, null);
        assertEquals(2, ((List<?>) studentHistory.get(0).get("approvalHistory")).size());
        assertEquals(2, modules.unreadNotificationCount(student));

        Map<String, Object> teacherLeave = modules.submitLeave(teacher, new LeaveRequest(
                "Personal", LocalDate.now().plusDays(5), LocalDate.now().plusDays(5), "Personal matter", null));
        UUID teacherLeaveId = UUID.fromString(teacherLeave.get("id").toString());
        List<Map<String, Object>> teacherFiltered = modules.leaves(admin, null, "teacher", null, null, null);
        assertEquals(1, teacherFiltered.size());
        assertEquals("teacher", ((Map<?, ?>) teacherFiltered.stream()
                .filter(row -> teacherLeaveId.toString().equals(row.get("id").toString()))
                .findFirst().orElseThrow().get("applicant")).get("role"));

        Map<String, Object> finalDecision = modules.decideLeave(admin, teacherLeaveId,
                new DecisionRequest("REJECTED", "Coverage unavailable"));
        assertEquals("REJECTED", finalDecision.get("status"));
        assertEquals(2, modules.unreadNotificationCount(teacher));
    }

    @Test
    void teachersCannotReviewAnotherStudentsApplication() {
        UserEntity otherTeacher = saveUser("teacher", admin.getInstituteCode(), "Other Teacher");
        Map<String, Object> created = modules.submitLeave(student, new LeaveRequest("Personal",
                LocalDate.now().plusDays(10), LocalDate.now().plusDays(10), "Family matter", null));
        UUID id = UUID.fromString(created.get("id").toString());

        assertEquals(403, assertThrows(ResponseStatusException.class,
                () -> modules.decideLeave(otherTeacher, id, new DecisionRequest("APPROVED", "")))
                .getStatusCode().value());
    }

    private UserEntity saveUser(String role, String instituteCode, String name) {
        UserEntity user = new UserEntity();
        user.setUserId(role + "-" + UUID.randomUUID());
        user.setRole(role);
        user.setInstituteCode(instituteCode);
        user.setInstituteName("Test Institute");
        user.setName(name);
        user.setEmail(UUID.randomUUID() + "@test.example");
        user.setPassword("unused-test-password");
        user.setStatus("Active");
        return users.save(user);
    }
}
