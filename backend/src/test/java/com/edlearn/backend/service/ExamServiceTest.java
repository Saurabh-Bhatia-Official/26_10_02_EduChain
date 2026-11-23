package com.edlearn.backend.service;

import com.edlearn.backend.model.ExamAttemptEntity;
import com.edlearn.backend.model.ExamEntity;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.ExamAttemptRepository;
import com.edlearn.backend.repository.ExamRepository;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class ExamServiceTest {
    private final ExamRepository exams = mock(ExamRepository.class);
    private final ExamAttemptRepository attempts = mock(ExamAttemptRepository.class);
    private final ExamService service = new ExamService(exams, attempts);

    @Test
    void scoringUsesQuestionMarksAndAppliesNegativeMarks() {
        String questions = "[{\"id\":\"q1\",\"correctAnswer\":\"A\",\"marks\":5,\"negativeMarks\":2},{\"id\":\"q2\",\"correctAnswer\":\"B\",\"marks\":15}]";
        assertEquals(13, service.calculateScore(questions, "{\"q1\":\"wrong\",\"q2\":\"B\"}", 20));
        assertEquals(5, service.calculateScore(questions, "{\"q1\":\"A\"}", 20));
        assertEquals(0, service.calculateScore(questions, "{\"q1\":\"wrong\"}", 20));
    }

    @Test
    void incrementalAnswerSavesIntoAttemptForTimeoutAutoSubmit() {
        UUID examId = UUID.randomUUID();
        UserEntity student = user("student", "INST-TEST");
        ExamEntity exam = exam(examId, "INST-TEST");
        ExamAttemptEntity attempt = new ExamAttemptEntity();
        attempt.setExam(exam);
        attempt.setStudent(student);
        attempt.setStartedAt(LocalDateTime.now().minusSeconds(10));
        attempt.setAnswersJson("{}");
        when(exams.findById(examId)).thenReturn(Optional.of(exam));
        when(attempts.findByExamAndStudent(exam, student)).thenReturn(Optional.of(attempt));
        when(attempts.save(attempt)).thenReturn(attempt);

        Map<String, Object> result = service.saveAnswer(student, examId, Map.of("questionId", "q1", "selectedOption", "A"));

        assertEquals("A", ((Map<?, ?>) result.get("savedAnswers")).get("q1"));
        assertTrue(attempt.getAnswersJson().contains("q1"));
    }

    @Test
    void answerForUnknownQuestionIsRejected() {
        UUID examId = UUID.randomUUID();
        UserEntity student = user("student", "INST-TEST");
        ExamEntity exam = exam(examId, "INST-TEST");
        ExamAttemptEntity attempt = new ExamAttemptEntity();
        attempt.setExam(exam);
        attempt.setStudent(student);
        attempt.setStartedAt(LocalDateTime.now());
        when(exams.findById(examId)).thenReturn(Optional.of(exam));
        when(attempts.findByExamAndStudent(exam, student)).thenReturn(Optional.of(attempt));

        ResponseStatusException error = assertThrows(ResponseStatusException.class,
                () -> service.saveAnswer(student, examId, Map.of("questionId", "other", "answer", "A")));
        assertEquals(HttpStatus.BAD_REQUEST, error.getStatusCode());
        verify(attempts, never()).save(any());
    }

    @Test
    void studentExamListNeverFallsBackToAnotherInstitute() {
        UserEntity student = user("student", "INST-TEST");
        when(exams.findByInstituteCodeIgnoreCaseAndStatusIgnoreCaseOrderByCreatedAtDesc("INST-TEST", "Published"))
                .thenReturn(java.util.List.of());
        assertTrue(service.getExams(student).isEmpty());
        verify(exams, never()).findAll();
    }

    @Test
    void studentCannotOpenExamAssignedToAnotherClass() {
        UUID examId = UUID.randomUUID();
        UserEntity student = user("student", "INST-TEST");
        student.setClassName("Class 8");
        ExamEntity exam = exam(examId, "INST-TEST");
        exam.setClassName("Class 9");
        when(exams.findById(examId)).thenReturn(Optional.of(exam));

        ResponseStatusException error = assertThrows(ResponseStatusException.class,
                () -> service.getExamDetails(student, examId));
        assertEquals(HttpStatus.NOT_FOUND, error.getStatusCode());
    }

    private ExamEntity exam(UUID id, String institute) {
        ExamEntity exam = new ExamEntity();
        exam.setId(id);
        exam.setInstituteCode(institute);
        exam.setClassName("Class 8");
        exam.setStatus("Published");
        exam.setDurationMinutes(60);
        exam.setTotalMarks(20);
        exam.setQuestionsJson("[{\"id\":\"q1\",\"question\":\"Question\",\"correctAnswer\":\"A\",\"marks\":20}]");
        return exam;
    }

    private UserEntity user(String role, String institute) {
        UserEntity user = new UserEntity();
        user.setId(UUID.randomUUID());
        user.setRole(role);
        user.setInstituteCode(institute);
        user.setName("Test User");
        if ("student".equalsIgnoreCase(role)) user.setClassName("Class 8");
        return user;
    }
}
