package com.edlearn.backend.service;

import com.edlearn.backend.model.ExamEntity;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.ExamAttemptRepository;
import com.edlearn.backend.repository.ExamRepository;
import com.edlearn.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@EnabledIfEnvironmentVariable(named = "TEST_DATABASE_URL", matches = "jdbc:postgresql://.+")
class ExamServiceIntegrationTest {

    @Autowired
    private ExamService examService;

    @Autowired
    private ExamRepository examRepository;

    @Autowired
    private ExamAttemptRepository attemptRepository;

    @Autowired
    private UserRepository userRepository;

    private UserEntity admin;
    private UserEntity student;
    private ExamEntity exam;

    @BeforeEach
    void setUp() {
        String code = "INST-" + UUID.randomUUID().toString().substring(0, 8);

        admin = new UserEntity();
        admin.setEmail("admin." + UUID.randomUUID() + "@test.com");
        admin.setFullName("Admin Tester");
        admin.setRole("admin");
        admin.setInstituteCode(code);
        admin.setStatus("Active");
        admin = userRepository.save(admin);

        student = new UserEntity();
        student.setEmail("student." + UUID.randomUUID() + "@test.com");
        student.setFullName("Student Tester");
        student.setRole("student");
        student.setInstituteCode(code);
        student.setStatus("Active");
        student = userRepository.save(student);

        // Find or create a test exam
        List<ExamEntity> existing = examRepository.findAll();
        if (!existing.isEmpty()) {
            exam = existing.get(0);
        } else {
            exam = new ExamEntity();
            exam.setTitle("Test Examination");
            exam.setCourseCode("TEST-101");
            exam.setCourseName("Testing");
            exam.setClassName("BCA");
            exam.setInstituteCode(code);
            exam.setCreatedBy(admin);
            exam.setDurationMinutes(30);
            exam.setTotalMarks(50);
            exam.setStatus("Published");
            exam.setResultsReleased(false);
            exam.setQuestionsJson("[{\"id\":\"q1\",\"q\":\"What is 2+2?\",\"options\":{\"A\":\"3\",\"B\":\"4\",\"C\":\"5\"},\"answer\":\"B\",\"marks\":10}]");
            exam = examRepository.save(exam);
        }
    }

    @Test
    void testExamListingAndDetails() {
        List<Map<String, Object>> exams = examService.getExams(student);
        assertNotNull(exams);
        assertFalse(exams.isEmpty());

        Map<String, Object> details = examService.getExamDetails(student, exam.getId());
        assertNotNull(details);
        assertEquals(exam.getId().toString(), details.get("id").toString());
        assertTrue(details.containsKey("questions"));
    }

    @Test
    void testStartAttemptSaveAnswerAndSingleAttemptConstraint() {
        // 1. Start attempt
        Map<String, Object> attempt = examService.startAttempt(student, exam.getId());
        assertNotNull(attempt);
        assertEquals("IN_PROGRESS", attempt.get("status"));

        // 2. Save an answer
        Map<String, Object> answerBody = new HashMap<>();
        answerBody.put("questionId", "q1");
        answerBody.put("selectedOption", "B");
        Map<String, Object> saveResult = examService.saveAnswer(student, exam.getId(), answerBody);
        assertNotNull(saveResult);
        assertTrue(Boolean.TRUE.equals(saveResult.get("success")));

        // 3. Submit exam
        Map<String, Object> submitBody = new HashMap<>();
        Map<String, String> answers = new HashMap<>();
        answers.put("q1", "B");
        submitBody.put("answers", answers);

        Map<String, Object> submitResult = examService.submitExam(student, exam.getId(), submitBody);
        assertNotNull(submitResult);
        assertEquals("SUBMITTED", submitResult.get("status"));

        // 4. Verify Single Attempt Rule: Cannot start attempt again (HTTP 409)
        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () ->
                examService.startAttempt(student, exam.getId()));
        assertEquals(409, ex.getStatusCode().value());

        // 5. Verify cannot submit again (HTTP 409)
        ResponseStatusException ex2 = assertThrows(ResponseStatusException.class, () ->
                examService.submitExam(student, exam.getId(), submitBody));
        assertEquals(409, ex2.getStatusCode().value());
    }

    @Test
    void testResultReleaseControl() {
        // Ensure student has submitted
        examService.startAttempt(student, exam.getId());
        Map<String, Object> submitBody = new HashMap<>();
        Map<String, String> answers = new HashMap<>();
        answers.put("q1", "B");
        submitBody.put("answers", answers);
        examService.submitExam(student, exam.getId(), submitBody);

        // Before release: student sees resultsReleased = false and scores are hidden
        examService.releaseResults(admin, exam.getId(), false);
        Map<String, Object> lockedAttempt = examService.getStudentAttempt(student, exam.getId());
        assertEquals(false, lockedAttempt.get("resultsReleased"));
        assertNull(lockedAttempt.get("score"));

        // Admin releases results
        examService.releaseResults(admin, exam.getId(), true);
        Map<String, Object> releasedAttempt = examService.getStudentAttempt(student, exam.getId());
        assertEquals(true, releasedAttempt.get("resultsReleased"));
        assertNotNull(releasedAttempt.get("score"));
        assertNotNull(releasedAttempt.get("passed"));

        // Admin can view all attempts
        List<Map<String, Object>> allAttempts = examService.getExamAttempts(admin, exam.getId());
        assertNotNull(allAttempts);
        assertFalse(allAttempts.isEmpty());
    }
}
