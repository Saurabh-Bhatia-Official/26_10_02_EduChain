package com.edlearn.backend.service;

import com.edlearn.backend.model.*;
import com.edlearn.backend.repository.*;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class AssignmentServiceTest {
    private final AssignmentRepository assignments = mock(AssignmentRepository.class);
    private final AssignmentSubmissionRepository submissions = mock(AssignmentSubmissionRepository.class);
    private final AssignmentAttachmentRepository attachments = mock(AssignmentAttachmentRepository.class);
    private final GradeRepository grades = mock(GradeRepository.class);
    private final ClassroomRepository classrooms = mock(ClassroomRepository.class);
    private final ClassroomMemberRepository members = mock(ClassroomMemberRepository.class);
    private final CloudinaryService cloudinary = mock(CloudinaryService.class);
    private final AssignmentService service = new AssignmentService(assignments, submissions, attachments, grades, classrooms, members, cloudinary);

    @Test
    void studentCannotReadAssignmentsFromAClassTheyDoNotBelongTo() {
        UUID classId = UUID.randomUUID();
        UUID studentId = UUID.randomUUID();
        ClassroomEntity classroom = classroom(classId);
        UserEntity student = student(studentId);
        when(classrooms.findById(classId)).thenReturn(Optional.of(classroom));
        when(members.findByClassroomIdAndUserId(classId, studentId)).thenReturn(Optional.empty());

        ResponseStatusException error = assertThrows(ResponseStatusException.class, () -> service.getClassroomAssignments(student, classId, null));
        assertEquals(HttpStatus.FORBIDDEN, error.getStatusCode());
        verify(assignments, never()).findByClassroomIdOrderByCreatedAtDesc(classId);
    }

    @Test
    void directDuplicateSubmissionIsRejectedUntilTheStudentUnsubmits() {
        UUID classId = UUID.randomUUID();
        UUID assignmentId = UUID.randomUUID();
        UUID studentId = UUID.randomUUID();
        ClassroomEntity classroom = classroom(classId);
        AssignmentEntity assignment = new AssignmentEntity();
        assignment.setId(assignmentId);
        assignment.setClassroom(classroom);
        assignment.setTitle("Unit test assignment");
        assignment.setStatus("PUBLISHED");
        UserEntity student = student(studentId);
        ClassroomMemberEntity membership = new ClassroomMemberEntity(classroom, student, "STUDENT", "ACTIVE");
        AssignmentSubmissionEntity existing = new AssignmentSubmissionEntity();
        existing.setAssignment(assignment);
        existing.setStudent(student);
        existing.setStatus("TURNED_IN");
        when(assignments.findById(assignmentId)).thenReturn(Optional.of(assignment));
        when(members.findByClassroomIdAndUserId(classId, studentId)).thenReturn(Optional.of(membership));
        when(submissions.findByAssignmentIdAndStudentId(assignmentId, studentId)).thenReturn(Optional.of(existing));

        ResponseStatusException error = assertThrows(ResponseStatusException.class,
                () -> service.submitAssignment(student, assignmentId, java.util.Map.of("submissionText", "duplicate")));
        assertEquals(HttpStatus.CONFLICT, error.getStatusCode());
        verify(submissions, never()).save(any());
    }

    @Test
    void studentUploadMustBeForAnActiveEnrolledClass() {
        UUID classId = UUID.randomUUID();
        UUID studentId = UUID.randomUUID();
        ClassroomEntity classroom = classroom(classId);
        UserEntity student = student(studentId);
        when(classrooms.findById(classId)).thenReturn(Optional.of(classroom));
        when(members.findByClassroomIdAndUserId(classId, studentId)).thenReturn(Optional.empty());
        MockMultipartFile file = new MockMultipartFile("file", "work.pdf", "application/pdf", new byte[]{1, 2, 3});

        ResponseStatusException error = assertThrows(ResponseStatusException.class,
                () -> service.uploadAssignmentFile(student, classId, "SUBMISSION", file));
        assertEquals(HttpStatus.FORBIDDEN, error.getStatusCode());
        verifyNoInteractions(cloudinary);
    }

    private ClassroomEntity classroom(UUID id) {
        ClassroomEntity classroom = new ClassroomEntity();
        classroom.setId(id);
        return classroom;
    }

    private UserEntity student(UUID id) {
        UserEntity student = new UserEntity();
        student.setId(id);
        student.setRole("student");
        student.setName("Test Student");
        student.setInstituteCode("INST-TEST");
        return student;
    }
}
