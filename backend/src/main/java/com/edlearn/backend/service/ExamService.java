package com.edlearn.backend.service;

import com.edlearn.backend.model.ExamAttemptEntity;
import com.edlearn.backend.model.ExamEntity;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.ExamAttemptRepository;
import com.edlearn.backend.repository.ExamRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class ExamService {

    private final ExamRepository examRepository;
    private final ExamAttemptRepository attemptRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public ExamService(ExamRepository examRepository, ExamAttemptRepository attemptRepository) {
        this.examRepository = examRepository;
        this.attemptRepository = attemptRepository;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getExams(UserEntity actor) {
        String role = actor.getRole().toLowerCase(Locale.ROOT);
        String instCode = actor.getInstituteCode() != null ? actor.getInstituteCode() : "INST-2025";
        List<ExamEntity> exams;

        if ("student".equals(role)) {
            exams = examRepository.findByInstituteCodeIgnoreCaseAndStatusIgnoreCaseOrderByCreatedAtDesc(instCode, "Published");
            if (exams.isEmpty()) {
                exams = examRepository.findAll().stream()
                        .filter(e -> "Published".equalsIgnoreCase(e.getStatus()))
                        .toList();
            }
        } else {
            exams = examRepository.findByInstituteCodeIgnoreCaseOrderByCreatedAtDesc(instCode);
            if (exams.isEmpty()) {
                exams = examRepository.findAll();
            }
        }

        return exams.stream().map(e -> toExamSummary(e, actor)).toList();
    }

    @Transactional
    public Map<String, Object> getExamDetails(UserEntity actor, UUID examId) {
        ExamEntity exam = examRepository.findById(examId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Examination not found."));

        String role = actor.getRole().toLowerCase(Locale.ROOT);
        Map<String, Object> map = toExamSummary(exam, actor);

        List<Map<String, Object>> questions = parseQuestions(exam.getQuestionsJson());
        if ("student".equals(role)) {
            // Check student's attempt status
            Optional<ExamAttemptEntity> attemptOpt = attemptRepository.findByExamAndStudent(exam, actor);
            boolean showCorrect = exam.getResultsReleased() && attemptOpt.isPresent() && "SUBMITTED".equals(attemptOpt.get().getStatus());

            if (!showCorrect) {
                // Strip correct answer for exam security
                questions = questions.stream().map(q -> {
                    Map<String, Object> safe = new LinkedHashMap<>(q);
                    safe.remove("correctAnswer");
                    return safe;
                }).toList();
            }

            if (attemptOpt.isPresent()) {
                ExamAttemptEntity attempt = attemptOpt.get();
                map.put("attemptId", attempt.getId());
                map.put("attemptStatus", attempt.getStatus());
                map.put("savedAnswers", parseAnswers(attempt.getAnswersJson()));
                if ("IN_PROGRESS".equals(attempt.getStatus())) {
                    long elapsedSeconds = Duration.between(attempt.getStartedAt(), LocalDateTime.now()).getSeconds();
                    long remainingSeconds = Math.max(0, (exam.getDurationMinutes() * 60L) - elapsedSeconds);
                    map.put("remainingSeconds", remainingSeconds);
                }
            }
        }

        map.put("questions", questions);
        return map;
    }

    @Transactional
    public Map<String, Object> startAttempt(UserEntity student, UUID examId) {
        if (!"student".equalsIgnoreCase(student.getRole())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only students can attempt examinations.");
        }

        ExamEntity exam = examRepository.findById(examId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Examination not found."));

        if (!"Published".equalsIgnoreCase(exam.getStatus())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "This examination is not open for attempts.");
        }

        Optional<ExamAttemptEntity> existingOpt = attemptRepository.findByExamAndStudent(exam, student);
        if (existingOpt.isPresent()) {
            ExamAttemptEntity existing = existingOpt.get();
            if ("SUBMITTED".equalsIgnoreCase(existing.getStatus()) || "EXPIRED".equalsIgnoreCase(existing.getStatus())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "EXAM ALREADY SUBMITTED: You have already attempted this examination. One student = one attempt per exam.");
            }

            // Restore in-progress attempt
            long elapsedSeconds = Duration.between(existing.getStartedAt(), LocalDateTime.now()).getSeconds();
            long totalSeconds = exam.getDurationMinutes() * 60L;
            if (elapsedSeconds >= totalSeconds) {
                // Auto-submit expired attempt
                autoSubmitAttempt(existing, exam);
                throw new ResponseStatusException(HttpStatus.CONFLICT, "EXAM ALREADY SUBMITTED: Examination time limit has expired and your exam was auto-submitted.");
            }

            long remainingSeconds = totalSeconds - elapsedSeconds;
            Map<String, Object> restored = toAttemptResponse(existing, exam, remainingSeconds);
            restored.put("restored", true);
            return restored;
        }

        try {
            ExamAttemptEntity attempt = new ExamAttemptEntity();
            attempt.setExam(exam);
            attempt.setStudent(student);
            attempt.setAnswersJson("{}");
            attempt.setTotalMarks(exam.getTotalMarks());
            attempt.setStartedAt(LocalDateTime.now());
            attempt.setStatus("IN_PROGRESS");
            attempt = attemptRepository.save(attempt);

            long totalSeconds = exam.getDurationMinutes() * 60L;
            return toAttemptResponse(attempt, exam, totalSeconds);
        } catch (DataIntegrityViolationException ex) {
            // Concurrency guard: unique constraint violated
            ExamAttemptEntity existing = attemptRepository.findByExamAndStudent(exam, student)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.CONFLICT, "Duplicate attempt blocked."));
            if ("SUBMITTED".equalsIgnoreCase(existing.getStatus())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "EXAM ALREADY SUBMITTED: You have already attempted this examination.");
            }
            long elapsedSeconds = Duration.between(existing.getStartedAt(), LocalDateTime.now()).getSeconds();
            long remainingSeconds = Math.max(0, (exam.getDurationMinutes() * 60L) - elapsedSeconds);
            return toAttemptResponse(existing, exam, remainingSeconds);
        }
    }

    @Transactional
    public Map<String, Object> saveAnswer(UserEntity student, UUID examId, Map<String, Object> body) {
        if (!"student".equalsIgnoreCase(student.getRole())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only students can submit answers.");
        }

        ExamEntity exam = examRepository.findById(examId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Examination not found."));

        ExamAttemptEntity attempt = attemptRepository.findByExamAndStudent(exam, student)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No active exam attempt found. Start the exam first."));

        if (!"IN_PROGRESS".equalsIgnoreCase(attempt.getStatus())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "EXAM ALREADY SUBMITTED: Answers cannot be modified after submission.");
        }

        long elapsedSeconds = Duration.between(attempt.getStartedAt(), LocalDateTime.now()).getSeconds();
        if (elapsedSeconds >= exam.getDurationMinutes() * 60L) {
            autoSubmitAttempt(attempt, exam);
            throw new ResponseStatusException(HttpStatus.CONFLICT, "EXAM ALREADY SUBMITTED: Examination time limit expired. Exam has been auto-submitted.");
        }

        Object answers = body.get("answers");
        if (answers != null) {
            try {
                attempt.setAnswersJson(objectMapper.writeValueAsString(answers));
            } catch (Exception e) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid answers format.");
            }
        }

        attempt.setUpdatedAt(LocalDateTime.now());
        attemptRepository.save(attempt);

        long remainingSeconds = Math.max(0, (exam.getDurationMinutes() * 60L) - elapsedSeconds);
        return Map.of("success", true, "remainingSeconds", remainingSeconds, "savedAnswers", parseAnswers(attempt.getAnswersJson()));
    }

    @Transactional
    public Map<String, Object> submitExam(UserEntity student, UUID examId, Map<String, Object> body) {
        if (!"student".equalsIgnoreCase(student.getRole())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only students can submit examinations.");
        }

        ExamEntity exam = examRepository.findById(examId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Examination not found."));

        ExamAttemptEntity attempt = attemptRepository.findByExamAndStudent(exam, student)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No exam attempt found. Start the exam before submitting."));

        if ("SUBMITTED".equalsIgnoreCase(attempt.getStatus())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "EXAM ALREADY SUBMITTED: Duplicate submission is blocked. You have already submitted this exam.");
        }

        if (body != null && body.containsKey("answers")) {
            try {
                attempt.setAnswersJson(objectMapper.writeValueAsString(body.get("answers")));
            } catch (Exception ignored) {}
        }

        // Calculate score on the backend
        int score = calculateScore(exam.getQuestionsJson(), attempt.getAnswersJson(), exam.getTotalMarks());
        attempt.setObtainedMarks(score);
        attempt.setSubmittedAt(LocalDateTime.now());
        attempt.setStatus("SUBMITTED");
        attempt.setUpdatedAt(LocalDateTime.now());
        attempt = attemptRepository.save(attempt);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("success", true);
        response.put("examId", exam.getId());
        response.put("attemptId", attempt.getId());
        response.put("status", "SUBMITTED");
        response.put("submittedAt", attempt.getSubmittedAt());
        response.put("message", "EXAM SUBMITTED SUCCESSFULLY");
        response.put("resultsReleased", exam.getResultsReleased());

        if (exam.getResultsReleased()) {
            response.put("obtainedMarks", score);
            response.put("totalMarks", exam.getTotalMarks());
            response.put("percentage", Math.round(((double) score / exam.getTotalMarks()) * 100.0));
        } else {
            response.put("notice", "Results are pending administrator release.");
        }

        return response;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getStudentAttempt(UserEntity actor, UUID examId) {
        ExamEntity exam = examRepository.findById(examId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Examination not found."));

        ExamAttemptEntity attempt = attemptRepository.findByExamAndStudent(exam, actor)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No attempt found for this examination."));

        Map<String, Object> map = new LinkedHashMap<>();
        map.put("attemptId", attempt.getId());
        map.put("examId", exam.getId());
        map.put("title", exam.getTitle());
        map.put("status", attempt.getStatus());
        map.put("startedAt", attempt.getStartedAt());
        map.put("submittedAt", attempt.getSubmittedAt());
        map.put("totalMarks", attempt.getTotalMarks());
        map.put("resultsReleased", exam.getResultsReleased());

        if ("SUBMITTED".equalsIgnoreCase(attempt.getStatus())) {
            if (exam.getResultsReleased()) {
                map.put("obtainedMarks", attempt.getObtainedMarks());
                map.put("percentage", attempt.getTotalMarks() > 0 
                        ? Math.round(((double) attempt.getObtainedMarks() / attempt.getTotalMarks()) * 100.0) 
                        : 0);
                map.put("questions", parseQuestions(exam.getQuestionsJson()));
                map.put("studentAnswers", parseAnswers(attempt.getAnswersJson()));
            } else {
                map.put("notice", "Examination results remain hidden until released by an administrator.");
            }
        }

        return map;
    }

    @Transactional
    public Map<String, Object> releaseResults(UserEntity admin, UUID examId, boolean release) {
        if (!"admin".equalsIgnoreCase(admin.getRole())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only administrators can release examination results.");
        }

        ExamEntity exam = examRepository.findById(examId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Examination not found."));

        exam.setResultsReleased(release);
        exam.setUpdatedAt(LocalDateTime.now());
        examRepository.save(exam);

        return Map.of("success", true, "examId", exam.getId(), "resultsReleased", release,
                "message", release ? "Examination results have been released to students." : "Examination results have been locked.");
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getExamAttempts(UserEntity actor, UUID examId) {
        String role = actor.getRole().toLowerCase(Locale.ROOT);
        if (!"admin".equals(role) && !"teacher".equals(role)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied.");
        }

        ExamEntity exam = examRepository.findById(examId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Examination not found."));

        return attemptRepository.findByExamOrderBySubmittedAtDesc(exam).stream().map(att -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", att.getId());
            m.put("studentId", att.getStudent().getId());
            m.put("studentName", att.getStudent().getName());
            m.put("rollNumber", att.getStudent().getRollNumber());
            m.put("email", att.getStudent().getEmail());
            m.put("status", att.getStatus());
            m.put("obtainedMarks", att.getObtainedMarks());
            m.put("totalMarks", att.getTotalMarks());
            m.put("startedAt", att.getStartedAt());
            m.put("submittedAt", att.getSubmittedAt());
            return m;
        }).toList();
    }

    private void autoSubmitAttempt(ExamAttemptEntity attempt, ExamEntity exam) {
        int score = calculateScore(exam.getQuestionsJson(), attempt.getAnswersJson(), exam.getTotalMarks());
        attempt.setObtainedMarks(score);
        attempt.setStatus("SUBMITTED");
        attempt.setSubmittedAt(attempt.getStartedAt().plusMinutes(exam.getDurationMinutes()));
        attempt.setUpdatedAt(LocalDateTime.now());
        attemptRepository.save(attempt);
    }

    int calculateScore(String questionsJson, String answersJson, int totalMarks) {
        List<Map<String, Object>> questions = parseQuestions(questionsJson);
        Map<String, String> answers = parseAnswers(answersJson);

        if (questions.isEmpty()) return 0;

        int correctCount = 0;
        for (Map<String, Object> q : questions) {
            String qId = String.valueOf(q.get("id"));
            String correct = q.get("correctAnswer") != null ? q.get("correctAnswer").toString().trim() : "";
            String given = answers.get(qId);
            if (given != null && given.trim().equalsIgnoreCase(correct)) {
                correctCount++;
            }
        }

        return (int) Math.round(((double) correctCount / questions.size()) * totalMarks);
    }

    private Map<String, Object> toExamSummary(ExamEntity e, UserEntity actor) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", e.getId());
        map.put("title", e.getTitle());
        map.put("courseCode", e.getCourseCode() != null ? e.getCourseCode() : "CS-301");
        map.put("courseName", e.getCourseName() != null ? e.getCourseName() : "Database Management Systems");
        map.put("className", e.getClassName());
        map.put("sectionName", e.getSectionName());
        map.put("durationMinutes", e.getDurationMinutes());
        map.put("totalMarks", e.getTotalMarks());
        map.put("examDate", e.getExamDate());
        map.put("status", e.getStatus());
        map.put("resultsReleased", e.getResultsReleased());

        if ("student".equalsIgnoreCase(actor.getRole())) {
            Optional<ExamAttemptEntity> attemptOpt = attemptRepository.findByExamAndStudent(e, actor);
            if (attemptOpt.isPresent()) {
                ExamAttemptEntity att = attemptOpt.get();
                map.put("attemptStatus", att.getStatus());
                map.put("hasAttempted", true);
                map.put("isSubmitted", "SUBMITTED".equalsIgnoreCase(att.getStatus()));
                if ("SUBMITTED".equalsIgnoreCase(att.getStatus()) && e.getResultsReleased()) {
                    map.put("score", att.getObtainedMarks());
                }
            } else {
                map.put("attemptStatus", "NOT_STARTED");
                map.put("hasAttempted", false);
                map.put("isSubmitted", false);
            }
        }

        return map;
    }

    private Map<String, Object> toAttemptResponse(ExamAttemptEntity attempt, ExamEntity exam, long remainingSeconds) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("attemptId", attempt.getId());
        map.put("examId", exam.getId());
        map.put("title", exam.getTitle());
        map.put("durationMinutes", exam.getDurationMinutes());
        map.put("totalMarks", exam.getTotalMarks());
        map.put("startedAt", attempt.getStartedAt());
        map.put("remainingSeconds", remainingSeconds);
        map.put("status", attempt.getStatus());
        map.put("savedAnswers", parseAnswers(attempt.getAnswersJson()));

        // Strip correct answer for security
        List<Map<String, Object>> safeQuestions = parseQuestions(exam.getQuestionsJson()).stream().map(q -> {
            Map<String, Object> safe = new LinkedHashMap<>(q);
            safe.remove("correctAnswer");
            return safe;
        }).toList();
        map.put("questions", safeQuestions);

        return map;
    }

    private List<Map<String, Object>> parseQuestions(String json) {
        if (json == null || json.isBlank()) return Collections.emptyList();
        try {
            return objectMapper.readValue(json, new TypeReference<List<Map<String, Object>>>() {});
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    private Map<String, String> parseAnswers(String json) {
        if (json == null || json.isBlank()) return new LinkedHashMap<>();
        try {
            Map<String, Object> raw = objectMapper.readValue(json, new TypeReference<Map<String, Object>>() {});
            Map<String, String> result = new LinkedHashMap<>();
            raw.forEach((k, v) -> result.put(k, v != null ? v.toString() : ""));
            return result;
        } catch (Exception e) {
            return new LinkedHashMap<>();
        }
    }
}
