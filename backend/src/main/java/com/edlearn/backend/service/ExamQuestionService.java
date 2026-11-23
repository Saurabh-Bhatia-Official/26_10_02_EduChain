package com.edlearn.backend.service;

import com.edlearn.backend.model.ExamQuestionEntity;
import com.edlearn.backend.model.ExamQuestionVersionEntity;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.ExamQuestionRepository;
import com.edlearn.backend.repository.ExamQuestionVersionRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ExamQuestionService {
    private static final Set<String> TYPES = Set.of("MCQ_SINGLE", "MCQ_MULTI", "TRUE_FALSE", "FILL_BLANK", "SHORT_ANSWER", "LONG_ANSWER", "MATCH");
    private static final Set<String> DIFFICULTIES = Set.of("EASY", "MEDIUM", "HARD");
    private final ExamQuestionRepository questions;
    private final ExamQuestionVersionRepository versions;
    private final ObjectMapper mapper = new ObjectMapper();

    public ExamQuestionService(ExamQuestionRepository questions, ExamQuestionVersionRepository versions) {
        this.questions = questions;
        this.versions = versions;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> list(UserEntity actor, Map<String, String> filters) {
        return questions.findByInstituteCodeIgnoreCaseOrderByUpdatedAtDesc(institute(actor)).stream()
                .filter(q -> matches(q, filters))
                .map(this::format)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Map<String, Object> get(UserEntity actor, UUID id) {
        return format(find(actor, id));
    }

    @Transactional
    public Map<String, Object> create(UserEntity actor, Map<String, Object> body) {
        ExamQuestionEntity question = new ExamQuestionEntity();
        question.setInstituteCode(institute(actor));
        question.setCreatedBy(actor);
        apply(question, body);
        question.setCreatedAt(LocalDateTime.now());
        question.setUpdatedAt(LocalDateTime.now());
        question.setVersion(1);
        return format(questions.save(question));
    }

    @Transactional
    public Map<String, Object> update(UserEntity actor, UUID id, Map<String, Object> body) {
        ExamQuestionEntity question = find(actor, id);
        if (!"admin".equalsIgnoreCase(actor.getRole()) && !question.getCreatedBy().getId().equals(actor.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You can only edit questions you created.");
        }
        ExamQuestionVersionEntity version = new ExamQuestionVersionEntity();
        version.setQuestion(question);
        version.setVersionNumber(question.getVersion());
        version.setQuestionSnapshot(writeSnapshot(format(question)));
        versions.save(version);
        apply(question, body);
        question.setVersion(question.getVersion() + 1);
        question.setUpdatedAt(LocalDateTime.now());
        return format(questions.save(question));
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> history(UserEntity actor, UUID id) {
        ExamQuestionEntity question = find(actor, id);
        if (!"admin".equalsIgnoreCase(actor.getRole()) && !question.getCreatedBy().getId().equals(actor.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You can only inspect versions of questions you created.");
        }
        return versions.findByQuestionIdOrderByVersionNumberDesc(id).stream().map(v -> {
            try { return mapper.readValue(v.getQuestionSnapshot(), new TypeReference<Map<String, Object>>() {}); }
            catch (Exception ex) { return Map.<String, Object>of("version", v.getVersionNumber(), "createdAt", v.getCreatedAt()); }
        }).collect(Collectors.toList());
    }

    @Transactional
    public void delete(UserEntity actor, UUID id) {
        ExamQuestionEntity question = find(actor, id);
        if (!"admin".equalsIgnoreCase(actor.getRole()) && !question.getCreatedBy().getId().equals(actor.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You can only delete questions you created.");
        }
        // Exams store immutable JSON snapshots, so removing a bank entry never edits an existing exam.
        versions.deleteAll(versions.findByQuestionIdOrderByVersionNumberDesc(id));
        questions.delete(question);
    }

    private ExamQuestionEntity find(UserEntity actor, UUID id) {
        return questions.findByIdAndInstituteCodeIgnoreCase(id, institute(actor))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Question not found."));
    }

    private void apply(ExamQuestionEntity q, Map<String, Object> body) {
        String text = Objects.toString(body.get("questionText"), q.getQuestionText() == null ? "" : q.getQuestionText()).trim();
        if (text.isEmpty()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Question text is required.");
        String type = Objects.toString(body.get("questionType"), q.getQuestionType() == null ? "MCQ_SINGLE" : q.getQuestionType()).toUpperCase(Locale.ROOT);
        if (!TYPES.contains(type)) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported question type.");
        String difficulty = Objects.toString(body.get("difficulty"), q.getDifficulty() == null ? "MEDIUM" : q.getDifficulty()).toUpperCase(Locale.ROOT);
        if (!DIFFICULTIES.contains(difficulty)) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Difficulty must be EASY, MEDIUM, or HARD.");
        int marks = body.get("marks") instanceof Number n ? n.intValue() : (q.getMarks() == 0 ? 1 : q.getMarks());
        double negativeMarks = body.get("negativeMarks") instanceof Number n ? n.doubleValue() : q.getNegativeMarks();
        if (marks <= 0 || negativeMarks < 0 || negativeMarks > marks) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Marks must be positive and negative marks must be between zero and the question marks.");
        q.setQuestionText(text);
        q.setQuestionType(type);
        q.setSubject(value(body, "subject", q.getSubject()));
        q.setClassName(value(body, "className", q.getClassName()));
        q.setChapter(value(body, "chapter", q.getChapter()));
        q.setTopic(value(body, "topic", q.getTopic()));
        q.setDifficulty(difficulty);
        q.setMarks(marks);
        q.setNegativeMarks(negativeMarks);
        if (body.containsKey("options")) q.setOptionsJson(serialize(body.get("options")));
        if (body.containsKey("correctAnswer")) q.setCorrectAnswer(Objects.toString(body.get("correctAnswer"), ""));
        if (body.containsKey("explanation")) q.setExplanation(value(body, "explanation", null));
        if (("MCQ_SINGLE".equals(type) || "MCQ_MULTI".equals(type) || "TRUE_FALSE".equals(type)) && (q.getOptionsJson() == null || q.getOptionsJson().isBlank())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "This question type requires answer options.");
        }
        if (q.getCorrectAnswer() == null || q.getCorrectAnswer().isBlank()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Correct answer is required for automatic grading.");
    }

    private String value(Map<String, Object> body, String key, String current) {
        return body.containsKey(key) ? Objects.toString(body.get(key), "").trim() : current;
    }

    private String serialize(Object value) {
        if (value == null) return null;
        try { return mapper.writeValueAsString(value); }
        catch (Exception ex) { throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid question options."); }
    }

    private String writeSnapshot(Map<String, Object> snapshot) {
        try { return mapper.writeValueAsString(snapshot); }
        catch (Exception ex) { throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Unable to save question version."); }
    }

    private boolean matches(ExamQuestionEntity q, Map<String, String> filters) {
        return contains(q.getQuestionText(), filters.get("search"))
                && equalsFilter(q.getSubject(), filters.get("subject"))
                && equalsFilter(q.getClassName(), filters.get("className"))
                && equalsFilter(q.getChapter(), filters.get("chapter"))
                && equalsFilter(q.getTopic(), filters.get("topic"))
                && equalsFilter(q.getDifficulty(), filters.get("difficulty"))
                && equalsFilter(q.getQuestionType(), filters.get("questionType"));
    }
    private boolean contains(String value, String filter) { return filter == null || filter.isBlank() || (value != null && value.toLowerCase(Locale.ROOT).contains(filter.trim().toLowerCase(Locale.ROOT))); }
    private boolean equalsFilter(String value, String filter) { return filter == null || filter.isBlank() || (value != null && value.equalsIgnoreCase(filter.trim())); }
    private String institute(UserEntity actor) {
        if (actor.getInstituteCode() == null || actor.getInstituteCode().isBlank()) {
            throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.FORBIDDEN,
                    "Your account is not linked to an institute.");
        }
        return actor.getInstituteCode();
    }

    private Map<String, Object> format(ExamQuestionEntity q) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", q.getId()); map.put("instituteCode", q.getInstituteCode()); map.put("questionText", q.getQuestionText());
        map.put("questionType", q.getQuestionType()); map.put("subject", q.getSubject()); map.put("className", q.getClassName());
        map.put("chapter", q.getChapter()); map.put("topic", q.getTopic()); map.put("difficulty", q.getDifficulty());
        map.put("marks", q.getMarks()); map.put("negativeMarks", q.getNegativeMarks()); map.put("options", readOptions(q.getOptionsJson()));
        map.put("correctAnswer", q.getCorrectAnswer()); map.put("explanation", q.getExplanation()); map.put("version", q.getVersion());
        map.put("createdById", q.getCreatedBy().getId()); map.put("createdByName", q.getCreatedBy().getName());
        map.put("createdAt", q.getCreatedAt() == null ? null : q.getCreatedAt().toString());
        map.put("updatedAt", q.getUpdatedAt() == null ? null : q.getUpdatedAt().toString());
        return map;
    }

    private Object readOptions(String json) {
        if (json == null || json.isBlank()) return List.of();
        try { return mapper.readValue(json, Object.class); }
        catch (Exception ex) { return List.of(); }
    }
}
