package com.edlearn.backend.service;

import com.edlearn.backend.model.ExamQuestionEntity;
import com.edlearn.backend.model.ExamQuestionVersionEntity;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.ExamQuestionRepository;
import com.edlearn.backend.repository.ExamQuestionVersionRepository;
import org.junit.jupiter.api.Test;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class ExamQuestionServiceTest {
    private final ExamQuestionRepository questions = mock(ExamQuestionRepository.class);
    private final ExamQuestionVersionRepository versions = mock(ExamQuestionVersionRepository.class);
    private final ExamQuestionService service = new ExamQuestionService(questions, versions);

    @Test
    void editingQuestionStoresPreviousVersionBeforeChangingCurrentBankEntry() {
        UserEntity teacher = new UserEntity();
        teacher.setId(UUID.randomUUID());
        teacher.setRole("teacher");
        teacher.setName("Question Author");
        teacher.setInstituteCode("INST-TEST");
        ExamQuestionEntity question = new ExamQuestionEntity();
        question.setId(UUID.randomUUID());
        question.setInstituteCode("INST-TEST");
        question.setCreatedBy(teacher);
        question.setQuestionText("Original question");
        question.setQuestionType("MCQ_SINGLE");
        question.setDifficulty("EASY");
        question.setMarks(2);
        question.setOptionsJson("[\"A\",\"B\"]");
        question.setCorrectAnswer("A");
        when(questions.findByIdAndInstituteCodeIgnoreCase(question.getId(), "INST-TEST")).thenReturn(Optional.of(question));
        when(questions.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        Map<String, Object> result = service.update(teacher, question.getId(), Map.of(
                "questionText", "Updated question", "questionType", "MCQ_SINGLE", "difficulty", "MEDIUM",
                "marks", 3, "negativeMarks", 1, "options", java.util.List.of("A", "B"), "correctAnswer", "B"));

        assertEquals("Updated question", result.get("questionText"));
        assertEquals(2, result.get("version"));
        var versionCaptor = org.mockito.ArgumentCaptor.forClass(ExamQuestionVersionEntity.class);
        verify(versions).save(versionCaptor.capture());
        assertEquals(1, versionCaptor.getValue().getVersionNumber());
        assertTrue(versionCaptor.getValue().getQuestionSnapshot().contains("Original question"));
    }

    @Test
    void invalidQuestionMarksAreRejected() {
        UserEntity teacher = new UserEntity();
        teacher.setId(UUID.randomUUID());
        teacher.setRole("teacher");
        teacher.setInstituteCode("INST-TEST");

        var error = assertThrows(org.springframework.web.server.ResponseStatusException.class,
                () -> service.create(teacher, Map.of("questionText", "Q", "questionType", "SHORT_ANSWER", "marks", 0, "correctAnswer", "A")));
        assertEquals(400, error.getStatusCode().value());
        verify(questions, never()).save(any());
    }
}
