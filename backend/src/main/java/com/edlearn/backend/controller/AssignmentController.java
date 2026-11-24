package com.edlearn.backend.controller;

import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.service.AssignmentService;
import com.edlearn.backend.service.PortalAccessService;
import org.springframework.web.multipart.MultipartFile;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/assignments")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class AssignmentController {

    private final AssignmentService assignmentService;
    private final PortalAccessService accessService;

    public AssignmentController(AssignmentService assignmentService, PortalAccessService accessService) {
        this.assignmentService = assignmentService;
        this.accessService = accessService;
    }

    @GetMapping
    public List<Map<String, Object>> getAssignments(HttpServletRequest request) {
        UserEntity user = accessService.require(request, "admin", "teacher", "instructor", "student");
        if ("student".equalsIgnoreCase(user.getRole())) {
            return assignmentService.getStudentAssignments(user);
        } else {
            return assignmentService.getInstructorAssignments(user);
        }
    }

    @GetMapping("/my")
    public List<Map<String, Object>> getMyAssignments(HttpServletRequest request) {
        UserEntity student = accessService.require(request, "student");
        return assignmentService.getStudentAssignments(student);
    }

    @GetMapping("/instructor")
    public List<Map<String, Object>> getInstructorAssignments(HttpServletRequest request) {
        UserEntity instructor = accessService.require(request, "teacher", "instructor", "admin");
        return assignmentService.getInstructorAssignments(instructor);
    }

    @GetMapping("/my-results")
    public List<Map<String, Object>> getMyResults(HttpServletRequest request) {
        UserEntity student = accessService.require(request, "student");
        return assignmentService.getStudentResults(student);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> createAssignment(HttpServletRequest request,
                                                @RequestParam(required = false) UUID classroomId,
                                                @RequestBody Map<String, Object> body) {
        UserEntity user = accessService.require(request, "teacher", "instructor", "admin");
        return assignmentService.createAssignment(user, classroomId, body);
    }

    @GetMapping("/{id}")
    public Map<String, Object> getAssignmentDetails(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity user = accessService.require(request, "teacher", "instructor", "student", "admin");
        return assignmentService.getAssignmentDetails(user, id);
    }

    @GetMapping("/{id}/submissions")
    public List<Map<String, Object>> getAssignmentSubmissions(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity user = accessService.require(request, "teacher", "instructor", "admin");
        return assignmentService.getAssignmentSubmissions(user, id);
    }

    @PutMapping("/{id}")
    public Map<String, Object> updateAssignment(HttpServletRequest request, @PathVariable UUID id, @RequestBody Map<String, Object> body) {
        UserEntity user = accessService.require(request, "teacher", "instructor", "admin");
        return assignmentService.updateAssignment(user, id, body);
    }

    @DeleteMapping("/{id}")
    public Map<String, Object> deleteAssignment(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity user = accessService.require(request, "teacher", "instructor", "admin");
        assignmentService.deleteAssignment(user, id);
        return Map.of("success", true, "message", "Assignment deleted successfully");
    }

    @PostMapping("/attachments/upload")
    public Map<String, Object> uploadAttachment(HttpServletRequest request,
                                                @RequestParam(required = false) UUID classroomId,
                                                @RequestParam(defaultValue = "ASSIGNMENT") String purpose,
                                                @RequestParam("file") MultipartFile file) {
        UserEntity user = accessService.require(request, "teacher", "instructor", "student", "admin");
        return assignmentService.uploadAssignmentFile(user, classroomId, purpose, file);
    }

    @GetMapping("/classroom/{classroomId}")
    public List<Map<String, Object>> getClassroomAssignments(HttpServletRequest request,
                                                             @PathVariable UUID classroomId,
                                                             @RequestParam(required = false) String topic) {
        UserEntity user = accessService.require(request, "teacher", "instructor", "student", "admin");
        return assignmentService.getClassroomAssignments(user, classroomId, topic);
    }

    @GetMapping("/to-do")
    public Map<String, Object> getStudentTodoList(HttpServletRequest request) {
        UserEntity student = accessService.require(request, "student");
        return assignmentService.getStudentTodoList(student);
    }

    @PostMapping("/{id}/submit")
    public Map<String, Object> submitAssignment(HttpServletRequest request,
                                                @PathVariable UUID id,
                                                @RequestBody Map<String, Object> body) {
        UserEntity student = accessService.require(request, "student");
        return assignmentService.submitAssignment(student, id, body);
    }

    @PostMapping("/{id}/unsubmit")
    public Map<String, Object> unsubmitAssignment(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity student = accessService.require(request, "student");
        return assignmentService.unsubmitAssignment(student, id);
    }

    @PostMapping("/submissions/{submissionId}/evaluate")
    public Map<String, Object> evaluateSubmission(HttpServletRequest request,
                                                  @PathVariable UUID submissionId,
                                                  @RequestBody Map<String, Object> body) {
        UserEntity instructor = accessService.require(request, "teacher", "instructor", "admin");
        return assignmentService.evaluateSubmission(instructor, submissionId, body);
    }

    @PostMapping("/submissions/{submissionId}/grade")
    public Map<String, Object> gradeSubmission(HttpServletRequest request,
                                               @PathVariable UUID submissionId,
                                               @RequestBody Map<String, Object> body) {
        UserEntity instructor = accessService.require(request, "teacher", "instructor", "admin");
        return assignmentService.gradeSubmission(instructor, submissionId, body);
    }

    @GetMapping("/classroom/{classroomId}/gradebook")
    public Map<String, Object> getClassGradebook(HttpServletRequest request, @PathVariable UUID classroomId) {
        UserEntity user = accessService.require(request, "teacher", "instructor", "admin");
        return assignmentService.getClassGradebook(user, classroomId);
    }

    @DeleteMapping("/attachments/{attachmentId}")
    public Map<String, Object> deleteAttachment(HttpServletRequest request, @PathVariable UUID attachmentId) {
        UserEntity user = accessService.require(request, "student", "teacher", "instructor", "admin");
        assignmentService.deleteAttachment(user, attachmentId);
        return Map.of("success", true, "message", "Attachment removed successfully.");
    }
}
