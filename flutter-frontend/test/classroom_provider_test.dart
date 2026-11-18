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
      while (!provider.isLoaded) {
        await Future<void>.delayed(Duration.zero);
      }
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
        final enrolledC1 = provider.byId(c1.id)!;

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

        expect(
          provider.canSubmitWork(
            enrolledC1,
            ClassroomRole.student,
            'student-1',
          ),
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

    test(
      '9. Local engagement activities support polls, quiz results, Q&A and drafts',
      () async {
        final classroom = provider.create(
          name: 'Engagement Test',
          subject: 'CS',
          section: 'A',
          description: '',
          teacherId: 'teacher-1',
          teacherName: 'Teacher',
          studentIds: ['student-1'],
        );
        final poll = provider.addEngagement(
          classroomId: classroom.id,
          kind: 'poll',
          title: 'Preferred lab time',
          body: '',
          authorId: 'teacher-1',
          authorName: 'Teacher',
          data: {
            'options': ['Morning', 'Afternoon'],
            'votes': <String, List<String>>{},
          },
        );
        final votes = Map<String, dynamic>.from(poll.data['votes'] as Map)
          ..['Morning'] = ['student-1'];
        provider.updateEngagement(
          poll.copyWith(data: {...poll.data, 'votes': votes}),
        );

        final draft = provider.addEngagement(
          classroomId: classroom.id,
          kind: 'assignment_draft',
          title: 'Draft lab',
          body: 'Instructions',
          authorId: 'teacher-1',
          authorName: 'Teacher',
          data: {'marks': 20},
        );
        expect(
          provider.engagementFor(classroom.id).map((item) => item.kind),
          containsAll(['poll', 'assignment_draft']),
        );
        expect(
          provider
              .engagementFor(classroom.id)
              .firstWhere((item) => item.id == poll.id)
              .data['votes']['Morning'],
          ['student-1'],
        );
        expect(
          provider.canAccessClass(
            classroom,
            ClassroomRole.student,
            'student-1',
          ),
          isTrue,
        );
        expect(
          provider.canManageClass(
            classroom,
            ClassroomRole.student,
            'student-1',
          ),
          isFalse,
        );
        provider.deleteEngagement(classroom.id, draft.id);
        expect(
          provider
              .engagementFor(classroom.id)
              .any((item) => item.id == draft.id),
          isFalse,
        );
      },
    );

    test('10. New installations do not receive bundled classroom records', () {
      expect(provider.isLocalOnly, isTrue);
      expect(provider.classrooms, isEmpty);
      expect(provider.archivedClassrooms, isEmpty);
    });

    test('11. Assignment drafts, deadline permissions, and reminders use saved records', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final classroom = provider.create(
        name: 'Deadline checks',
        subject: 'CS',
        section: 'A',
        description: '',
        teacherId: 'teacher-1',
        teacherName: 'Teacher',
        studentIds: ['student-1'],
      );
      provider.addAssignment(
        classroom.id,
        'Draft work',
        '',
        10,
        today,
        isDraft: true,
        allowLateSubmission: false,
      );
      provider.addAssignment(
        classroom.id,
        'Due today',
        '',
        10,
        today,
        allowLateSubmission: false,
      );
      final visibleToTeacher = provider.assignmentsFor(classroom.id);
      final visibleToStudent = provider.assignmentsFor(classroom.id, includeDrafts: false);
      expect(visibleToTeacher.length, 2);
      expect(visibleToStudent.map((item) => item.title), ['Due today']);
      expect(provider.canSubmitAssignment(visibleToTeacher.first, classroom, 'student-1'), isFalse);

      expect(
        provider.refreshDeadlineNotifications('student-1', now: now),
        1,
      );
      final reminder = provider.notificationsFor('student-1').firstWhere(
            (item) => item.title == 'Assignment deadline reminder',
          );
      provider.markNotificationAsRead(reminder.id, 'student-1');
      expect(provider.refreshDeadlineNotifications('student-1', now: now), 0);
      expect(provider.submit(visibleToStudent.single.id, 'outsider', 'No access', classroomId: classroom.id), isFalse);
      expect(provider.submit(visibleToStudent.single.id, 'student-1', 'Ready', classroomId: classroom.id), isTrue);
      expect(provider.submissionFor(visibleToStudent.single.id, 'student-1'), isNotNull);
      expect(provider.refreshDeadlineNotifications('student-1', now: now), 0);

      provider.addAssignment(
        classroom.id,
        'Closed work',
        '',
        10,
        today.subtract(const Duration(days: 2)),
        allowLateSubmission: false,
      );
      final closed = provider.assignmentsFor(classroom.id).first;
      expect(provider.canSubmitAssignment(closed, classroom, 'student-1'), isFalse);
      expect(provider.submit(closed.id, 'student-1', 'Late', classroomId: classroom.id), isFalse);
    });

    test('12. Timed quizzes enforce membership, deadline, one attempt, and automatic score', () {
      final now = DateTime.now();
      final classroom = provider.create(
        name: 'Quiz checks',
        subject: 'CS',
        section: 'A',
        description: '',
        teacherId: 'teacher-1',
        teacherName: 'Teacher',
        studentIds: ['student-1'],
      );
      final quiz = ClassroomQuiz(
        id: 'quiz_one_attempt',
        classroomId: classroom.id,
        title: 'Local quiz',
        instructions: '',
        teacherId: 'teacher-1',
        durationMinutes: 2,
        questions: const [
          QuizQuestion(prompt: '2 + 2?', options: ['3', '4'], correctOptionIndex: 1, points: 3),
        ],
        createdAt: now,
        dueAt: DateTime(now.year, now.month, now.day),
      );
      provider.addQuiz(quiz);
      expect(provider.canTakeQuiz(quiz, 'student-1'), isTrue);
      expect(provider.canTakeQuiz(quiz, 'outsider'), isFalse);
      final attempt = provider.submitQuiz(
        quiz: quiz,
        studentId: 'student-1',
        answers: const {0: 1},
        startedAt: now,
        submittedAt: now.add(const Duration(seconds: 30)),
      );
      expect(attempt?.score, 3);
      expect(attempt?.maxScore, 3);
      expect(provider.canTakeQuiz(quiz, 'student-1'), isFalse);
      expect(
        provider.submitQuiz(
          quiz: quiz,
          studentId: 'student-1',
          answers: const {0: 0},
          startedAt: now,
          submittedAt: now.add(const Duration(seconds: 40)),
        ),
        isNull,
      );

      final timedOut = ClassroomQuiz(
        id: 'quiz_timed_out',
        classroomId: classroom.id,
        title: 'Expired attempt',
        instructions: '',
        teacherId: 'teacher-1',
        durationMinutes: 1,
        questions: quiz.questions,
        createdAt: now,
      );
      provider.addQuiz(timedOut);
      expect(
        provider.submitQuiz(
          quiz: timedOut,
          studentId: 'student-1',
          answers: const {0: 1},
          startedAt: now.subtract(const Duration(minutes: 2)),
          submittedAt: now,
        ),
        isNull,
      );
    });

    test('13. Polls, groups, peer review, grading history, and recents are validated', () {
      final classroom = provider.create(
        name: 'Collaboration checks',
        subject: 'CS',
        section: 'A',
        description: '',
        teacherId: 'teacher-1',
        teacherName: 'Teacher',
        studentIds: ['student-1', 'student-2'],
      );
      final poll = ClassroomPoll(
        id: 'poll_votes',
        classroomId: classroom.id,
        question: 'Choose a lab time',
        options: const ['Morning', 'Afternoon'],
        createdBy: 'teacher-1',
        createdAt: DateTime.now(),
      );
      provider.addPoll(poll);
      expect(provider.votePoll(classroom.id, poll.id, 'outsider', 0), isFalse);
      expect(provider.votePoll(classroom.id, poll.id, 'student-1', 0), isTrue);
      expect(provider.votePoll(classroom.id, poll.id, 'student-1', 1), isTrue);
      expect(provider.pollsFor(classroom.id).single.votes['student-1'], 1);
      expect(provider.closePoll(classroom.id, poll.id), isTrue);
      expect(provider.votePoll(classroom.id, poll.id, 'student-2', 0), isFalse);

      expect(provider.addGroup(classroom.id, 'Project team', ['student-1', 'student-2']), isTrue);
      expect(provider.addGroup(classroom.id, 'project team', ['student-1']), isFalse);
      expect(provider.addGroup(classroom.id, 'Invalid member', ['outsider']), isFalse);

      provider.addAssignment(
        classroom.id,
        'Reviewable work',
        '',
        20,
        null,
        allowPeerReview: true,
        rubric: const [RubricCriterion(title: 'Reasoning', maxPoints: 20)],
      );
      final assignment = provider.assignmentsFor(classroom.id).single;
      for (final studentId in classroom.studentIds) {
        expect(provider.submit(assignment.id, studentId, 'Solution', classroomId: classroom.id), isTrue);
      }
      provider.grade(assignment.id, 'student-2', 15, 'Good reasoning', gradedBy: 'Teacher', rubricScores: const {'Reasoning': 15});
      provider.grade(assignment.id, 'student-2', 18, 'Revision is clearer', gradedBy: 'Teacher', rubricScores: const {'Reasoning': 18});
      expect(provider.submissionFor(assignment.id, 'student-2')?.gradeHistory.length, 2);
      expect(provider.submitPeerReview(assignment: assignment, reviewerId: 'student-1', revieweeId: 'student-2', rating: 5, feedback: 'Clear explanation'), isTrue);
      expect(provider.submitPeerReview(assignment: assignment, reviewerId: 'student-1', revieweeId: 'student-2', rating: 4, feedback: 'Second review'), isFalse);
      expect(provider.peerReviewsFor(assignment.id).single.feedback, 'Clear explanation');

      provider.recordRecentlyViewed('student-1', 'material', 'mat_1', 'Lecture Notes', classroom.id);
      provider.recordRecentlyViewed('student-1', 'assignment', assignment.id, assignment.title, classroom.id);
      expect(provider.recentlyViewedFor('student-1').map((item) => item.type), ['assignment', 'material']);
      expect(provider.activitiesFor(classroom.id).map((item) => item.type), containsAll(['poll', 'assignment', 'submission', 'grade']));
    });
  });
}
