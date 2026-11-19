import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_frontend/features/classroom/models/classroom_model.dart';
import 'package:flutter_frontend/features/classroom/providers/classroom_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EduChain Google Classroom LMS Provider & RBAC Suite', () {
    late ClassroomProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = ClassroomProvider();
      await provider.ready;
    });

    tearDown(() async {
      await provider.flushPendingSaves();
    });

    test(
      '1. Creates, filters, updates, and deletes a teacher classroom with unique code',
      () {
        final classroom = provider.create(
          name: 'Distributed Systems 401',
          subject: 'Computer Science',
          section: 'CS-4A',
          description: 'Advanced Cloud Computing and Microservices',
          teacherId: 'teacher-1',
          teacherName: 'Prof. Rajesh Verma',
          room: 'Hall 302',
        );

        expect(provider.forTeacher('teacher-1'), contains(classroom));
        expect(provider.forTeacher('teacher-2'), isEmpty);
        expect(classroom.code, startsWith('EC'));
        expect(classroom.room, 'Hall 302');

        provider.update(
          classroom.copyWith(name: 'Advanced Distributed Systems'),
        );
        expect(
          provider.byId(classroom.id)?.name,
          'Advanced Distributed Systems',
        );

        final newCode = provider.regenerateCode(classroom.id);
        expect(newCode, startsWith('EC'));
        expect(provider.byId(classroom.id)?.code, newCode);

        provider.delete(classroom.id);
        expect(provider.byId(classroom.id), isNull);
      },
    );

    test(
      '2. Strict RBAC: Separate permissions for Student, Teacher, and Admin',
      () {
        final c1 = provider.create(
          name: 'Algorithms',
          subject: 'CS',
          section: 'A',
          description: '',
          teacherId: 'teacher-100',
          teacherName: 'Teacher 100',
        );

        final c2 = provider.create(
          name: 'Databases',
          subject: 'CS',
          section: 'B',
          description: '',
          teacherId: 'teacher-200',
          teacherName: 'Teacher 200',
        );

        // Student 1 joins C1 only
        expect(provider.join(c1.code, 'student-1'), isTrue);

        // Verify Teacher view: Teacher 100 sees only C1; Teacher 200 sees only C2
        final t1Classes = provider.forTeacher('teacher-100');
        expect(t1Classes.map((c) => c.id), contains(c1.id));
        expect(t1Classes.map((c) => c.id), isNot(contains(c2.id)));

        final t2Classes = provider.forTeacher('teacher-200');
        expect(t2Classes.map((c) => c.id), contains(c2.id));
        expect(t2Classes.map((c) => c.id), isNot(contains(c1.id)));

        // Verify Student view: Student 1 sees only C1
        final s1Classes = provider.forStudent('student-1');
        expect(s1Classes.map((c) => c.id), contains(c1.id));
        expect(s1Classes.map((c) => c.id), isNot(contains(c2.id)));

        // Verify Admin view: Admin oversees all classes
        final adminClasses = provider.forAdmin();
        expect(adminClasses.map((c) => c.id), containsAll([c1.id, c2.id]));

        // Verify permission guards
        expect(
          provider.canManageClass(c1, ClassroomRole.teacher, 'teacher-100'),
          isTrue,
        );
        expect(
          provider.canManageClass(c1, ClassroomRole.teacher, 'teacher-200'),
          isFalse,
        );
        expect(
          provider.canManageClass(c1, ClassroomRole.student, 'student-1'),
          isFalse,
        );
        expect(
          provider.canManageClass(c1, ClassroomRole.admin, 'admin-1'),
          isTrue,
        );

        expect(
          provider.canGrade(c1, ClassroomRole.teacher, 'teacher-100'),
          isTrue,
        );
        expect(
          provider.canGrade(c1, ClassroomRole.teacher, 'teacher-200'),
          isFalse,
        );
        expect(
          provider.canGrade(c1, ClassroomRole.student, 'student-1'),
          isFalse,
        );
        expect(provider.canGrade(c1, ClassroomRole.admin, 'admin-1'), isTrue);
        expect(
          provider.canTakeAttendance(c1, ClassroomRole.admin, 'admin-1'),
          isTrue,
        );

        expect(
          provider.canSubmitWork(c1, ClassroomRole.student, 'student-1'),
          isTrue,
        );
        expect(
          provider.canSubmitWork(c1, ClassroomRole.student, 'student-2'),
          isFalse,
        );
        expect(
          provider.canSubmitWork(c1, ClassroomRole.teacher, 'teacher-100'),
          isFalse,
        );
      },
    );

    test('3. Stream Announcements, Pinned Posts, and Discussion Comments', () {
      final classroom = provider.create(
        name: 'Physics',
        subject: 'Science',
        section: '101',
        description: '',
        teacherId: 'teacher-1',
        teacherName: 'Teacher',
      );

      provider.addPost(
        classroom.id,
        'Teacher',
        'General announcement',
        authorId: 'teacher-1',
        authorRole: 'teacher',
      );

      provider.addPost(
        classroom.id,
        'Teacher',
        'Important notice',
        authorId: 'teacher-1',
        authorRole: 'teacher',
        isPinned: true,
      );

      final posts = provider.postsFor(classroom.id);
      expect(posts.length, 2);
      expect(posts.first.text, 'Important notice'); // Pinned first!
      expect(posts.first.isPinned, isTrue);

      // Add comments
      final pinnedPost = posts.first;
      provider.addComment(
        classroom.id,
        pinnedPost.id,
        authorId: 'student-1',
        authorName: 'Aarav Sharma',
        authorRole: 'student',
        text: 'Will this be on the exam?',
      );

      final updatedPost = provider.postsFor(classroom.id).first;
      expect(updatedPost.comments.length, 1);
      expect(updatedPost.comments.first.text, 'Will this be on the exam?');

      // Delete comment
      provider.deleteComment(
        classroom.id,
        pinnedPost.id,
        updatedPost.comments.first.id,
      );
      expect(provider.postsFor(classroom.id).first.comments, isEmpty);
    });

    test(
      '4. Assignments, Student Submissions, Unsubmit, and Teacher Grading with Feedback',
      () {
        final classroom = provider.create(
          name: 'Math',
          subject: 'Mathematics',
          section: 'A',
          description: '',
          teacherId: 'teacher-1',
          teacherName: 'Teacher',
        );
        provider.join(classroom.code, 'student-1');

        // Add assignment
        provider.addAssignment(
          classroom.id,
          'Calculus Problem Set 1',
          'Solve problems 1 through 10',
          100,
          DateTime.now().add(const Duration(days: 5)),
          category: 'Homework',
        );

        final asg = provider.assignmentsFor(classroom.id).single;
        expect(asg.title, 'Calculus Problem Set 1');
        expect(asg.category, 'Homework');

        // Submit
        provider.submit(
          asg.id,
          'student-1',
          'All 10 problems completed.',
          classroomId: classroom.id,
          studentName: 'Student One',
          attachmentName: 'calculus_p1.pdf',
        );

        var sub = provider.submissionFor(asg.id, 'student-1');
        expect(sub, isNotNull);
        expect(sub?.status, SubmissionStatus.submitted);
        expect(sub?.marks, isNull);

        // Unsubmit test
        provider.unsubmit(asg.id, 'student-1');
        expect(provider.submissionFor(asg.id, 'student-1'), isNull);

        // Re-submit
        provider.submit(
          asg.id,
          'student-1',
          'Final corrected work.',
          classroomId: classroom.id,
          studentName: 'Student One',
        );

        // Teacher grades submission
        provider.grade(
          asg.id,
          'student-1',
          94,
          'Great proofs on problem 7 and 9!',
          gradedBy: 'Teacher',
        );
        sub = provider.submissionFor(asg.id, 'student-1');
        expect(sub?.marks, 94);
        expect(sub?.feedback, 'Great proofs on problem 7 and 9!');
        expect(sub?.status, SubmissionStatus.graded);

        // Check student progress summary
        final progress = provider.getStudentProgress(classroom.id, 'student-1');
        expect(progress.averageGradePercentage, 94.0);
        expect(progress.letterGrade, 'A+');
        expect(progress.submittedCount, 1);
      },
    );

    test('5. Session-Based Attendance Recording and Metrics Calculation', () {
      final classroom = provider.create(
        name: 'Chemistry',
        subject: 'Science',
        section: 'Lab',
        description: '',
        teacherId: 'teacher-1',
        teacherName: 'Teacher',
        studentIds: ['s1', 's2', 's3'],
      );

      // Session 1
      provider.recordAttendanceSession(
        classroomId: classroom.id,
        date: DateTime.now().subtract(const Duration(days: 7)),
        topic: 'Chemical Equilibrium Lab',
        takenByTeacherId: 'teacher-1',
        records: {
          's1': AttendanceStatus.present,
          's2': AttendanceStatus.absent,
          's3': AttendanceStatus.late,
        },
      );

      // Session 2
      provider.recordAttendanceSession(
        classroomId: classroom.id,
        date: DateTime.now().subtract(const Duration(days: 3)),
        topic: 'Organic Reaction Mechanisms',
        takenByTeacherId: 'teacher-1',
        records: {
          's1': AttendanceStatus.present,
          's2': AttendanceStatus.present,
          's3': AttendanceStatus.absent,
        },
      );

      final sessions = provider.attendanceSessionsFor(classroom.id);
      expect(sessions.length, 2);

      // Check student attendance rates
      expect(provider.calculateStudentAttendance(classroom.id, 's1'), 100.0);
      expect(provider.calculateStudentAttendance(classroom.id, 's2'), 50.0);

      // Overall class rate
      final classRate = provider.calculateClassAttendanceRate(classroom.id);
      expect(classRate, greaterThan(0));
    });

    test('6. Learning Materials Management and Module Categorization', () {
      final classroom = provider.create(
        name: 'Operating Systems',
        subject: 'CS',
        section: 'A',
        description: '',
        teacherId: 'teacher-1',
        teacherName: 'Teacher',
      );

      provider.addMaterial(
        classroomId: classroom.id,
        title: 'Virtual Memory & Paging Slides',
        description: 'Lecture 12 slides and TLB simulation code.',
        topic: 'Module 3: Memory Management',
        uploadedBy: 'Teacher',
        attachmentName: 'lecture_12_paging.pdf',
        fileType: 'pdf',
      );

      provider.addMaterial(
        classroomId: classroom.id,
        title: 'Linux Kernel Scheduling Architecture',
        description: 'CFS Scheduler documentation.',
        topic: 'Module 2: CPU Scheduling',
        uploadedBy: 'Teacher',
        linkUrl: 'https://kernel.org/sched',
        fileType: 'link',
      );

      final allMats = provider.materialsFor(classroom.id);
      expect(allMats.length, 2);

      final memMats = provider.materialsFor(
        classroom.id,
        'Module 3: Memory Management',
      );
      expect(memMats.length, 1);
      expect(memMats.first.title, 'Virtual Memory & Paging Slides');

      final topics = provider.topicsFor(classroom.id);
      expect(topics, contains('Module 3: Memory Management'));
      expect(topics, contains('Module 2: CPU Scheduling'));

      provider.deleteMaterial(classroom.id, memMats.first.id);
      expect(
        provider.materialsFor(classroom.id, 'Module 3: Memory Management'),
        isEmpty,
      );
    });

    test('7. Real-Time In-App Notifications and Unread Badging', () {
      final classroom = provider.create(
        name: 'Networks',
        subject: 'CS',
        section: 'B',
        description: '',
        teacherId: 'teacher-1',
        teacherName: 'Teacher',
        studentIds: ['s1'],
      );

      provider.addNotification(
        recipientUserId: 's1',
        classroomId: classroom.id,
        classroomName: classroom.name,
        title: 'Assignment Posted',
        message: 'Socket Programming Lab is due Friday.',
        type: 'assignment',
      );

      expect(provider.unreadNotificationsCount('s1'), 1);

      final notifs = provider.notificationsFor('s1');
      expect(notifs.length, 1);
      expect(notifs.first.isRead, isFalse);

      provider.markNotificationAsRead(notifs.first.id, 's1');
      expect(provider.unreadNotificationsCount('s1'), 0);
    });

    test(
      '8. Classroom Analytics Summary and At-Risk Student Identification',
      () {
        final classroom = provider.create(
          name: 'AI Engineering',
          subject: 'CS',
          section: 'AI-1',
          description: '',
          teacherId: 'teacher-1',
          teacherName: 'Teacher',
          studentIds: ['good-student', 'struggling-student'],
        );

        provider.addAssignment(
          classroom.id,
          'Neural Net From Scratch',
          'Code backprop',
          100,
          DateTime.now().add(const Duration(days: 2)),
        );
        final asg = provider.assignmentsFor(classroom.id).single;

        // Good student submits and scores 90
        provider.submit(
          asg.id,
          'good-student',
          'done',
          classroomId: classroom.id,
        );
        provider.grade(asg.id, 'good-student', 90, 'Great job');

        // Struggling student attendance session
        provider.recordAttendanceSession(
          classroomId: classroom.id,
          date: DateTime.now().subtract(const Duration(days: 1)),
          topic: 'Intro to Tensors',
          takenByTeacherId: 'teacher-1',
          records: {
            'good-student': AttendanceStatus.present,
            'struggling-student': AttendanceStatus.absent,
          },
        );

        final analytics = provider.getClassroomAnalytics(classroom.id);
        expect(analytics.totalStudents, 2);
        expect(analytics.totalAssignments, 1);
        expect(analytics.atRiskStudentIds, contains('struggling-student'));
        expect(analytics.gradeDistribution['A'], 1);
      },
    );
  });
}
