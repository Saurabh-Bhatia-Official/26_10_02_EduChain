package com.edlearn.backend;

import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.UserRepository;
import com.edlearn.backend.service.ClassroomService;
import com.edlearn.backend.service.AssignmentService;
import com.edlearn.backend.service.LiveClassService;
import com.edlearn.backend.service.CommentService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@EnabledIfEnvironmentVariable(named = "TEST_DATABASE_URL", matches = "jdbc:postgresql://.+")
public class LmsEndToEndIntegrationTest {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ClassroomService classroomService;

    @Autowired
    private AssignmentService assignmentService;

    @Autowired
    private LiveClassService liveClassService;

    @Autowired
    private CommentService commentService;

    @Test
    public void testCompleteLmsWorkflow() {
        System.out.println("=== Starting LMS End-to-End Integration Verification ===");

        // 1. Fetch real teacher and student
        UserEntity teacher = userRepository.findByEmailIgnoreCase("amit.sharma@institute.com")
                .orElseThrow(() -> new IllegalStateException("Teacher amit.sharma@institute.com not found"));
        UserEntity student = userRepository.findByEmailIgnoreCase("rahul@institute.com")
                .orElseThrow(() -> new IllegalStateException("Student rahul@institute.com not found"));

        assertNotNull(teacher.getId());
        assertNotNull(student.getId());
        System.out.println("1. Verified Teacher: " + teacher.getName() + " and Student: " + student.getName());

        // 2. Teacher creates classroom
        Map<String, Object> classReq = new HashMap<>();
        classReq.put("name", "CS-401: Cloud Computing & Distributed Systems");
        classReq.put("section", "Section A");
        classReq.put("subject", "Computer Science");
        classReq.put("room", "Virtual Room 101");
        classReq.put("description", "Master microservices, event streams, and cloud native architectures.");
        classReq.put("themeColor", "#1967d2");
        classReq.put("isPublic", true);
        classReq.put("requiresApproval", false);

        Map<String, Object> createdClass = classroomService.createClassroom(teacher, classReq);
        UUID classroomId = (UUID) createdClass.get("id");
        String invitationCode = (String) createdClass.get("invitationCode");

        assertNotNull(classroomId);
        assertNotNull(invitationCode);
        assertEquals(8, invitationCode.length());
        System.out.println("2. Classroom created: ID=" + classroomId + ", Code=" + invitationCode);

        // 3. Student joins classroom via invitation code
        Map<String, Object> joinResult = classroomService.joinByInvitationCode(student, invitationCode);
        assertEquals("ACTIVE", joinResult.get("status"));
        System.out.println("3. Student successfully joined: " + joinResult.get("message"));

        // 4. Verify members list
        Map<String, Object> members = classroomService.getMembers(teacher, classroomId);
        List<?> teachers = (List<?>) members.get("teachers");
        List<?> students = (List<?>) members.get("students");
        assertTrue(teachers.size() >= 1);
        assertTrue(students.size() >= 1);
        System.out.println("4. Members verified: " + teachers.size() + " teacher(s), " + students.size() + " student(s)");

        // 5. Teacher creates assignment
        Map<String, Object> assignReq = new HashMap<>();
        assignReq.put("title", "Distributed Key-Value Store Implementation");
        assignReq.put("instructions", "Build a replicated key-value store using Raft consensus or consistent hashing.");
        assignReq.put("pointsPossible", 100);
        assignReq.put("dueDate", LocalDateTime.now().plusDays(7).toString());
        assignReq.put("topic", "Distributed Systems");
        assignReq.put("allowLateSubmissions", true);

        Map<String, Object> createdAssign = assignmentService.createAssignment(teacher, classroomId, assignReq);
        UUID assignmentId = (UUID) createdAssign.get("id");
        assertNotNull(assignmentId);
        System.out.println("5. Assignment created: " + createdAssign.get("title") + " (ID=" + assignmentId + ")");

        // 6. Student checks assignment list
        List<Map<String, Object>> studentAssignments = assignmentService.getClassroomAssignments(student, classroomId, null);
        assertFalse(studentAssignments.isEmpty());
        assertEquals("ASSIGNED", studentAssignments.get(0).get("submissionStatus"));
        System.out.println("6. Student assignment status: " + studentAssignments.get(0).get("submissionStatus"));

        // 7. Student submits assignment
        Map<String, Object> submitReq = new HashMap<>();
        submitReq.put("submissionText", "GitHub repo: https://github.com/student/raft-kv-store. All test suites pass.");
        Map<String, Object> submitResult = assignmentService.submitAssignment(student, assignmentId, submitReq);
        UUID submissionId = (UUID) submitResult.get("id");
        assertEquals("TURNED_IN", submitResult.get("status"));
        System.out.println("7. Student turned in assignment. Submission ID=" + submissionId);

        // 8. Teacher grades submission
        Map<String, Object> gradeReq = new HashMap<>();
        gradeReq.put("score", new BigDecimal("96.50"));
        gradeReq.put("feedback", "Excellent implementation of log replication and leader election! Clean test coverage.");
        gradeReq.put("isReturned", true);

        Map<String, Object> gradeResult = assignmentService.gradeSubmission(teacher, submissionId, gradeReq);
        assertEquals(new BigDecimal("96.50"), gradeResult.get("score"));
        assertTrue((Boolean) gradeResult.get("isReturned"));
        System.out.println("8. Teacher graded submission: Score=" + gradeResult.get("score") + ", Feedback=" + gradeResult.get("feedback"));

        // 9. Teacher schedules Google Meet Live Class
        Map<String, Object> meetReq = new HashMap<>();
        meetReq.put("title", "Live Class: Raft Consensus Deep-Dive & Lab Walkthrough");
        meetReq.put("description", "Interactive discussion on edge-case partitions and log compaction.");
        meetReq.put("startTime", LocalDateTime.now().plusMinutes(5).toString());
        meetReq.put("endTime", LocalDateTime.now().plusMinutes(65).toString());

        Map<String, Object> liveClass = liveClassService.scheduleLiveClass(teacher, classroomId, meetReq);
        UUID liveClassId = (UUID) liveClass.get("id");
        String meetLink = (String) liveClass.get("meetLink");
        assertNotNull(liveClassId);
        assertNotNull(meetLink);
        assertTrue(meetLink.startsWith("https://meet.google.com/"), "Meet link must be Google Meet URL");
        System.out.println("9. Google Meet Live Class scheduled: " + meetLink);

        // 10. Student joins live class -> Attendance recorded
        Map<String, Object> joinMeetResult = liveClassService.joinClass(student, liveClassId);
        assertEquals(meetLink, joinMeetResult.get("meetLink"));
        System.out.println("10. Student joined live class. Attendance recorded: " + joinMeetResult.get("message"));

        // 11. Teacher views attendance report
        Map<String, Object> attendanceReport = liveClassService.getAttendanceReport(teacher, liveClassId);
        List<?> attendees = (List<?>) attendanceReport.get("attendance");
        assertFalse(attendees.isEmpty());
        System.out.println("11. Attendance report verified: " + attendees.size() + " attendee(s) recorded.");

        // 12. Classroom Stream Comments
        Map<String, Object> commentReq = new HashMap<>();
        commentReq.put("content", "Welcome everyone to CS-401! Please review the syllabus and join today's Google Meet.");
        commentReq.put("targetType", "STREAM_POST");

        Map<String, Object> postedComment = commentService.addComment(teacher, classroomId, commentReq);
        assertNotNull(postedComment.get("id"));

        List<Map<String, Object>> streamComments = commentService.getComments(classroomId, "STREAM_POST", null);
        assertFalse(streamComments.isEmpty());
        System.out.println("12. Classroom stream feed working: " + streamComments.size() + " post(s).");

        System.out.println("=== ALL LMS END-TO-END TESTS PASSED SUCCESSFULLY! ===");
    }
}
