import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/classroom_model.dart';

/// Comprehensive Google Classroom LMS Provider with Strict RBAC and Persistence
class ClassroomProvider extends ChangeNotifier {
  ClassroomProvider() {
    loadPersistedData();
  }

  static const String _storageKeyClassrooms = 'educhain_lms_classrooms_v2';
  static const String _storageKeyPosts = 'educhain_lms_posts_v2';
  static const String _storageKeyAssignments = 'educhain_lms_assignments_v2';
  static const String _storageKeySubmissions = 'educhain_lms_submissions_v2';
  static const String _storageKeyMaterials = 'educhain_lms_materials_v2';
  static const String _storageKeyAttendance = 'educhain_lms_attendance_v2';
  static const String _storageKeyNotifications = 'educhain_lms_notifications_v2';
  static const String _storageKeyQuizzes = 'educhain_lms_quizzes_v1';
  static const String _storageKeyQuizAttempts = 'educhain_lms_quiz_attempts_v1';
  static const String _storageKeyPolls = 'educhain_lms_polls_v1';
  static const String _storageKeyGroups = 'educhain_lms_groups_v1';
  static const String _storageKeyPeerReviews = 'educhain_lms_peer_reviews_v1';
  static const String _storageKeyRecentlyViewed = 'educhain_lms_recently_viewed_v1';

  final Map<String, ClassroomModel> _classrooms = {};
  final Map<String, List<ClassroomPost>> _posts = {};
  final Map<String, List<ClassroomAssignment>> _assignments = {};
  final Map<String, List<ClassroomSubmission>> _submissions = {};
  final Map<String, List<ClassroomMaterial>> _materials = {};
  final Map<String, List<ClassroomAttendanceSession>> _attendanceSessions = {};
  final Map<String, List<ClassroomNotification>> _notifications = {};
  final Map<String, List<ClassroomQuiz>> _quizzes = {};
  final Map<String, List<QuizAttempt>> _quizAttempts = {};
  final Map<String, List<ClassroomPoll>> _polls = {};
  final Map<String, List<ClassroomGroup>> _groups = {};
  final Map<String, List<PeerReview>> _peerReviews = {};
  final Map<String, List<RecentlyViewedItem>> _recentlyViewed = {};

  bool _isLoaded = false;
  Future<void> _pendingSave = Future<void>.value();
  bool get isLoaded => _isLoaded;
  bool get isPreviewOnly => true;
  bool get isLocalOnly => true;
  bool get isBusy => false;

  List<ClassroomModel> get classrooms =>
      List.unmodifiable(_classrooms.values.where((c) => !c.isArchived));

  List<ClassroomModel> get archivedClassrooms =>
      List.unmodifiable(_classrooms.values.where((c) => c.isArchived));

  // ==========================================
  // Role-Based Filtering
  // ==========================================

  /// Strict RBAC: Teachers see ONLY classrooms they created / teach
  List<ClassroomModel> forTeacher(String teacherId) =>
      classrooms.where((item) => item.teacherId == teacherId).toList();

  /// Strict RBAC: Students see ONLY classrooms they are enrolled in
  List<ClassroomModel> forStudent(String studentId) =>
      classrooms.where((item) => item.studentIds.contains(studentId)).toList();

  /// Strict RBAC: Admins have institutional oversight to view all classrooms
  List<ClassroomModel> forAdmin() => classrooms;

  /// General filter by role
  List<ClassroomModel> forRole(ClassroomRole role, String userId) {
    switch (role) {
      case ClassroomRole.teacher:
        return forTeacher(userId);
      case ClassroomRole.student:
        return forStudent(userId);
      case ClassroomRole.admin:
        return forAdmin();
    }
  }

  List<ClassroomModel> archivedForRole(ClassroomRole role, String userId) {
    final archived = archivedClassrooms;
    switch (role) {
      case ClassroomRole.teacher:
        return archived.where((item) => item.teacherId == userId).toList();
      case ClassroomRole.student:
        return const [];
      case ClassroomRole.admin:
        return archived;
    }
  }

  ClassroomModel? byId(String id) => _classrooms[id];

  ClassroomModel? byCode(String code) {
    final clean = code.trim().toLowerCase();
    for (final c in _classrooms.values) {
      if (!c.isArchived && c.code.toLowerCase() == clean) return c;
    }
    return null;
  }

  // ==========================================
  // Permissions Guard Checkers
  // ==========================================

  bool canManageClass(ClassroomModel classroom, ClassroomRole role, String userId) {
    if (role == ClassroomRole.admin) return true;
    if (role == ClassroomRole.teacher && classroom.teacherId == userId) return true;
    return false;
  }

  bool canAccessClass(ClassroomModel classroom, ClassroomRole role, String userId) {
    if (role == ClassroomRole.admin) return true;
    if (role == ClassroomRole.teacher && classroom.teacherId == userId) return true;
    if (role == ClassroomRole.student && classroom.studentIds.contains(userId)) return true;
    return false;
  }

  bool canGrade(ClassroomModel classroom, ClassroomRole role, String userId) {
    return role == ClassroomRole.teacher && classroom.teacherId == userId;
  }

  bool canTakeAttendance(ClassroomModel classroom, ClassroomRole role, String userId) {
    return role == ClassroomRole.teacher && classroom.teacherId == userId;
  }

  bool canSubmitWork(ClassroomModel classroom, ClassroomRole role, String userId) {
    return role == ClassroomRole.student && classroom.studentIds.contains(userId);
  }

  bool canSubmitAssignment(
    ClassroomAssignment assignment,
    ClassroomModel classroom,
    String userId, {
    DateTime? now,
  }) {
    if (assignment.isDraft || !canSubmitWork(classroom, ClassroomRole.student, userId)) return false;
    final dueAt = assignment.dueAt;
    if (assignment.allowLateSubmission || dueAt == null) return true;
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final dueDate = DateTime(dueAt.year, dueAt.month, dueAt.day);
    return !today.isAfter(dueDate);
  }

  // ==========================================
  // Classroom CRUD
  // ==========================================

  ClassroomModel create({
    required String name,
    required String subject,
    required String section,
    required String description,
    required String teacherId,
    required String teacherName,
    String teacherEmail = '',
    String room = '',
    int bannerIndex = 0,
    Uint8List? bannerBytes,
    List<String> studentIds = const [],
  }) {
    final id = 'cls_${DateTime.now().microsecondsSinceEpoch}';
    final code = 'EC${id.substring(id.length - 5).toUpperCase()}';
    final classroom = ClassroomModel(
      id: id,
      name: name,
      subject: subject,
      section: section,
      description: description,
      code: code,
      teacherId: teacherId,
      teacherName: teacherName,
      teacherEmail: teacherEmail,
      room: room,
      bannerIndex: bannerIndex,
      bannerBytes: bannerBytes,
      studentIds: studentIds,
      createdAt: DateTime.now(),
    );
    _classrooms[id] = classroom;
    _saveToPrefs();
    notifyListeners();
    return classroom;
  }

  void update(ClassroomModel classroom) {
    if (!_classrooms.containsKey(classroom.id)) return;
    _classrooms[classroom.id] = classroom;
    _saveToPrefs();
    notifyListeners();
  }

  void delete(String id) {
    final assignments = _assignments.remove(id) ?? const <ClassroomAssignment>[];
    for (final assignment in assignments) {
      _submissions.remove(assignment.id);
      _peerReviews.remove(assignment.id);
    }
    for (final quiz in _quizzes.remove(id) ?? const <ClassroomQuiz>[]) {
      _quizAttempts.remove(quiz.id);
    }
    _polls.remove(id);
    _groups.remove(id);
    _classrooms.remove(id);
    _posts.remove(id);
    _materials.remove(id);
    _attendanceSessions.remove(id);
    _saveToPrefs();
    notifyListeners();
  }

  void toggleArchive(String id) {
    final existing = _classrooms[id];
    if (existing == null) return;
    _classrooms[id] = existing.copyWith(isArchived: !existing.isArchived);
    _saveToPrefs();
    notifyListeners();
  }

  String regenerateCode(String classroomId) {
    final existing = _classrooms[classroomId];
    if (existing == null) return '';
    final newCode = 'EC${DateTime.now().microsecondsSinceEpoch.toString().substring(8, 13).toUpperCase()}';
    _classrooms[classroomId] = existing.copyWith(code: newCode);
    _saveToPrefs();
    notifyListeners();
    return newCode;
  }

  // ==========================================
  // Student Enrollment & Roster
  // ==========================================

  bool join(String code, String studentId) {
    final classroom = byCode(code);
    if (classroom == null) return false;
    if (classroom.studentIds.contains(studentId)) return false;

    _classrooms[classroom.id] = classroom.copyWith(
      studentIds: [...classroom.studentIds, studentId],
    );

    // Notify teacher
    addNotification(
      recipientUserId: classroom.teacherId,
      classroomId: classroom.id,
      classroomName: classroom.name,
      title: 'New Student Joined',
      message: 'A student has joined ${classroom.name} with code ${classroom.code}.',
      type: 'announcement',
    );

    _saveToPrefs();
    notifyListeners();
    return true;
  }

  bool enrollStudent(String classroomId, String studentId) {
    final classroom = _classrooms[classroomId];
    if (classroom == null || classroom.studentIds.contains(studentId)) return false;
    _classrooms[classroomId] = classroom.copyWith(
      studentIds: [...classroom.studentIds, studentId],
    );

    addNotification(
      recipientUserId: studentId,
      classroomId: classroom.id,
      classroomName: classroom.name,
      title: 'Enrolled in ${classroom.name}',
      message: 'You have been enrolled into ${classroom.name} by ${classroom.teacherName}.',
      type: 'announcement',
    );

    _saveToPrefs();
    notifyListeners();
    return true;
  }

  bool removeStudent(String classroomId, String studentId) {
    final classroom = _classrooms[classroomId];
    if (classroom == null || !classroom.studentIds.contains(studentId)) return false;
    final updatedList = classroom.studentIds.where((id) => id != studentId).toList();
    _classrooms[classroomId] = classroom.copyWith(studentIds: updatedList);
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  bool leaveClass(String classroomId, String studentId) =>
      removeStudent(classroomId, studentId);

  // ==========================================
  // Stream & Announcements
  // ==========================================

  List<ClassroomPost> postsFor(String classroomId) {
    final list = _posts[classroomId] ?? const [];
    // Pinned posts first, then newest
    final sorted = List<ClassroomPost>.from(list);
    sorted.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return List.unmodifiable(sorted);
  }

  void addPost(
    String classroomId,
    String author,
    String text, {
    String authorId = '',
    String authorRole = 'teacher',
    bool isPinned = false,
    String? attachmentName,
    String? attachmentUrl,
    Uint8List? attachmentBytes,
  }) {
    final posts = _posts.putIfAbsent(classroomId, () => []);
    final post = ClassroomPost(
      id: 'post_${DateTime.now().microsecondsSinceEpoch}',
      author: author,
      text: text,
      createdAt: DateTime.now(),
      authorId: authorId,
      authorRole: authorRole,
      classroomId: classroomId,
      isPinned: isPinned,
      attachmentName: attachmentName,
      attachmentUrl: attachmentUrl,
      attachmentBytes: attachmentBytes,
    );
    posts.insert(0, post);

    // Broadcast notification to all enrolled students
    final classroom = _classrooms[classroomId];
    if (classroom != null && (authorRole == 'teacher' || authorRole == 'admin')) {
      for (final sId in classroom.studentIds) {
        addNotification(
          recipientUserId: sId,
          classroomId: classroomId,
          classroomName: classroom.name,
          title: 'New Announcement: ${classroom.name}',
          message: text.length > 70 ? '${text.substring(0, 70)}...' : text,
          type: 'announcement',
        );
      }
    } else if (classroom != null && authorRole == 'student') {
      addNotification(
        recipientUserId: classroom.teacherId,
        classroomId: classroomId,
        classroomName: classroom.name,
        title: 'New Classroom Question',
        message: text.length > 70 ? '${text.substring(0, 70)}...' : text,
        type: 'discussion',
      );
    }

    _saveToPrefs();
    notifyListeners();
  }

  void deletePost(String classroomId, String postId) {
    _posts[classroomId]?.removeWhere((p) => p.id == postId);
    _saveToPrefs();
    notifyListeners();
  }

  void updatePost(String classroomId, String postId, String text, {bool? isPinned}) {
    final posts = _posts[classroomId];
    if (posts == null) return;
    final index = posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;
    posts[index] = posts[index].copyWith(text: text, isPinned: isPinned);
    _saveToPrefs();
    notifyListeners();
  }

  void togglePinPost(String classroomId, String postId) {
    final posts = _posts[classroomId];
    if (posts == null) return;
    final index = posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;
    posts[index] = posts[index].copyWith(isPinned: !posts[index].isPinned);
    _saveToPrefs();
    notifyListeners();
  }

  void addComment(
    String classroomId,
    String postId, {
    required String authorId,
    required String authorName,
    required String authorRole,
    required String text,
  }) {
    final posts = _posts[classroomId];
    if (posts == null) return;
    final index = posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;

    final comment = ClassroomComment(
      id: 'comm_${DateTime.now().microsecondsSinceEpoch}',
      authorId: authorId,
      authorName: authorName,
      authorRole: authorRole,
      text: text,
      createdAt: DateTime.now(),
    );

    final post = posts[index];
    posts[index] = post.copyWith(comments: [...post.comments, comment]);
    _saveToPrefs();
    notifyListeners();
  }

  void deleteComment(String classroomId, String postId, String commentId) {
    final posts = _posts[classroomId];
    if (posts == null) return;
    final index = posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;

    final post = posts[index];
    final updated = post.comments.where((c) => c.id != commentId).toList();
    posts[index] = post.copyWith(comments: updated);
    _saveToPrefs();
    notifyListeners();
  }

  // ==========================================
  // Assignments
  // ==========================================

  List<ClassroomAssignment> assignmentsFor(
    String classroomId, {
    bool includeDrafts = true,
  }) {
    final items = _assignments[classroomId] ?? const [];
    final visible = includeDrafts ? items : items.where((item) => !item.isDraft).toList();
    return List.unmodifiable(visible);
  }

  void addAssignment(
    String classroomId,
    String title,
    String instructions,
    int maxMarks,
    DateTime? dueAt, {
    String teacherId = '',
    String category = 'General',
    String? attachmentName,
    String? attachmentUrl,
    Uint8List? attachmentBytes,
    bool allowLateSubmission = true,
    bool isDraft = false,
    bool allowPeerReview = false,
    List<RubricCriterion> rubric = const [],
  }) {
    final items = _assignments.putIfAbsent(classroomId, () => []);
    final assignment = ClassroomAssignment(
      id: 'asg_${DateTime.now().microsecondsSinceEpoch}',
      classroomId: classroomId,
      teacherId: teacherId,
      title: title,
      instructions: instructions,
      maxMarks: maxMarks,
      dueAt: dueAt,
      category: category,
      createdAt: DateTime.now(),
      attachmentName: attachmentName,
      attachmentUrl: attachmentUrl,
      attachmentBytes: attachmentBytes,
      allowLateSubmission: allowLateSubmission,
      isDraft: isDraft,
      allowPeerReview: allowPeerReview,
      rubric: rubric,
    );
    items.insert(0, assignment);

    // Notify all students
    final classroom = _classrooms[classroomId];
    if (classroom != null && !isDraft) {
      for (final sId in classroom.studentIds) {
        addNotification(
          recipientUserId: sId,
          classroomId: classroomId,
          classroomName: classroom.name,
          title: 'New Assignment: $title',
          message: '$title has been posted. Due: ${dueAt != null ? "${dueAt.day}/${dueAt.month}/${dueAt.year}" : "No deadline"}.',
          type: 'assignment',
        );
      }
    }

    _saveToPrefs();
    notifyListeners();
  }

  void updateAssignment(
    String classroomId,
    String assignmentId,
    String title,
    String instructions,
    int maxMarks,
    DateTime? dueAt, {
    String? category,
    String? attachmentName,
    String? attachmentUrl,
    Uint8List? attachmentBytes,
    bool clearAttachment = false,
    bool? allowLateSubmission,
    bool? isDraft,
    bool? allowPeerReview,
    List<RubricCriterion>? rubric,
  }) {
    final assignments = _assignments[classroomId];
    if (assignments == null) return;
    final index = assignments.indexWhere((a) => a.id == assignmentId);
    if (index < 0) return;

    final wasDraft = assignments[index].isDraft;
    assignments[index] = assignments[index].copyWith(
      title: title,
      instructions: instructions,
      maxMarks: maxMarks,
      dueAt: dueAt,
      category: category,
      attachmentName: attachmentName,
      attachmentUrl: attachmentUrl,
      attachmentBytes: attachmentBytes,
      clearAttachment: clearAttachment,
      allowLateSubmission: allowLateSubmission,
      isDraft: isDraft,
      allowPeerReview: allowPeerReview,
      rubric: rubric,
    );
    final updatedAssignment = assignments[index];
    if (wasDraft && !updatedAssignment.isDraft) {
      final classroom = _classrooms[classroomId];
      if (classroom != null) {
        for (final studentId in classroom.studentIds) {
          addNotification(
            recipientUserId: studentId,
            classroomId: classroom.id,
            classroomName: classroom.name,
            title: 'New Assignment: ${updatedAssignment.title}',
            message: 'An assignment is now available in ${classroom.name}.',
            type: 'assignment',
          );
        }
      }
    }
    _saveToPrefs();
    notifyListeners();
  }

  bool setAssignmentDraft(String classroomId, String assignmentId, bool isDraft) {
    final assignments = _assignments[classroomId];
    final index = assignments?.indexWhere((item) => item.id == assignmentId) ?? -1;
    if (assignments == null || index < 0) return false;
    assignments[index] = assignments[index].copyWith(isDraft: isDraft);
    final classroom = _classrooms[classroomId];
    if (!isDraft && classroom != null) {
      for (final studentId in classroom.studentIds) {
        addNotification(
          recipientUserId: studentId,
          classroomId: classroomId,
          classroomName: classroom.name,
          title: 'New Assignment: ${assignments[index].title}',
          message: 'An assignment is now available in ${classroom.name}.',
          type: 'assignment',
        );
      }
    }
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  List<ClassroomQuiz> quizzesFor(String classroomId, {bool includeDrafts = false}) =>
      List.unmodifiable((_quizzes[classroomId] ?? const []).where((quiz) => includeDrafts || !quiz.isDraft));

  ClassroomQuiz? quizById(String quizId) {
    for (final quizzes in _quizzes.values) {
      for (final quiz in quizzes) {
        if (quiz.id == quizId) return quiz;
      }
    }
    return null;
  }

  void addQuiz(ClassroomQuiz quiz) {
    _quizzes.putIfAbsent(quiz.classroomId, () => []).insert(0, quiz);
    if (!quiz.isDraft) {
      final classroom = _classrooms[quiz.classroomId];
      if (classroom != null) {
        for (final studentId in classroom.studentIds) {
          addNotification(
            recipientUserId: studentId,
            classroomId: classroom.id,
            classroomName: classroom.name,
            title: 'New Quiz: ${quiz.title}',
            message: 'A timed quiz is ready. Duration: ${quiz.durationMinutes} minutes.',
            type: 'quiz',
          );
        }
      }
    }
    _saveToPrefs();
    notifyListeners();
  }

  bool publishQuiz(String classroomId, String quizId) {
    final quizzes = _quizzes[classroomId];
    final index = quizzes?.indexWhere((quiz) => quiz.id == quizId) ?? -1;
    if (quizzes == null || index < 0) return false;
    final old = quizzes[index];
    quizzes[index] = ClassroomQuiz(
      id: old.id,
      classroomId: old.classroomId,
      title: old.title,
      instructions: old.instructions,
      teacherId: old.teacherId,
      durationMinutes: old.durationMinutes,
      questions: old.questions,
      createdAt: old.createdAt,
      dueAt: old.dueAt,
      isDraft: false,
    );
    final classroom = _classrooms[classroomId];
    if (classroom != null) {
      for (final studentId in classroom.studentIds) {
        addNotification(
          recipientUserId: studentId,
          classroomId: classroomId,
          classroomName: classroom.name,
          title: 'New Quiz: ${old.title}',
          message: 'A timed quiz is now available.',
          type: 'quiz',
        );
      }
    }
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  List<QuizAttempt> quizAttemptsFor(String quizId) =>
      List.unmodifiable(_quizAttempts[quizId] ?? const []);

  QuizAttempt? quizAttemptFor(String quizId, String studentId) {
    for (final attempt in _quizAttempts[quizId] ?? const <QuizAttempt>[]) {
      if (attempt.studentId == studentId) return attempt;
    }
    return null;
  }

  QuizAttempt? submitQuiz({
    required ClassroomQuiz quiz,
    required String studentId,
    required Map<int, int> answers,
    required DateTime startedAt,
    DateTime? submittedAt,
  }) {
    final classroom = _classrooms[quiz.classroomId];
    if (classroom == null || !classroom.studentIds.contains(studentId) || quiz.isDraft) return null;
    if (quizAttemptFor(quiz.id, studentId) != null) return null;
    final end = submittedAt ?? DateTime.now();
    if (quiz.dueAt != null && end.isAfter(quiz.dueAt!)) return null;
    var score = 0;
    for (var i = 0; i < quiz.questions.length; i++) {
      final question = quiz.questions[i];
      if (answers[i] == question.correctOptionIndex) score += question.points;
    }
    final attempt = QuizAttempt(
      id: 'attempt_${DateTime.now().microsecondsSinceEpoch}',
      quizId: quiz.id,
      studentId: studentId,
      answers: Map.unmodifiable(answers),
      score: score,
      maxScore: quiz.maxScore,
      startedAt: startedAt,
      submittedAt: end,
    );
    _quizAttempts.putIfAbsent(quiz.id, () => []).add(attempt);
    addNotification(
      recipientUserId: classroom.teacherId,
      classroomId: classroom.id,
      classroomName: classroom.name,
      title: 'Quiz Attempt Submitted',
      message: 'A student completed ${quiz.title}.',
      type: 'quiz',
    );
    _saveToPrefs();
    notifyListeners();
    return attempt;
  }

  List<ClassroomPoll> pollsFor(String classroomId) => List.unmodifiable(_polls[classroomId] ?? const []);

  void addPoll(ClassroomPoll poll) {
    _polls.putIfAbsent(poll.classroomId, () => []).insert(0, poll);
    final classroom = _classrooms[poll.classroomId];
    if (classroom != null) {
      for (final studentId in classroom.studentIds) {
        addNotification(
          recipientUserId: studentId,
          classroomId: classroom.id,
          classroomName: classroom.name,
          title: 'New Classroom Poll',
          message: poll.question,
          type: 'poll',
        );
      }
    }
    _saveToPrefs();
    notifyListeners();
  }

  bool votePoll(String classroomId, String pollId, String studentId, int optionIndex) {
    final classroom = _classrooms[classroomId];
    final polls = _polls[classroomId];
    final index = polls?.indexWhere((poll) => poll.id == pollId) ?? -1;
    if (classroom == null || !classroom.studentIds.contains(studentId) || polls == null || index < 0) return false;
    final poll = polls[index];
    if (poll.isClosed || optionIndex < 0 || optionIndex >= poll.options.length) return false;
    final votes = Map<String, int>.from(poll.votes)..[studentId] = optionIndex;
    polls[index] = poll.copyWith(votes: votes);
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  bool closePoll(String classroomId, String pollId) {
    final polls = _polls[classroomId];
    final index = polls?.indexWhere((poll) => poll.id == pollId) ?? -1;
    if (polls == null || index < 0) return false;
    polls[index] = polls[index].copyWith(isClosed: true);
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  List<ClassroomGroup> groupsFor(String classroomId) => List.unmodifiable(_groups[classroomId] ?? const []);

  bool addGroup(String classroomId, String name, List<String> memberIds) {
    final classroom = _classrooms[classroomId];
    final cleanName = name.trim();
    final members = memberIds.toSet().toList();
    if (classroom == null || cleanName.isEmpty || members.isEmpty ||
        members.any((id) => !classroom.studentIds.contains(id)) ||
        groupsFor(classroomId).any((group) => group.name.toLowerCase() == cleanName.toLowerCase())) {
      return false;
    }
    _groups.putIfAbsent(classroomId, () => []).add(ClassroomGroup(
          id: 'group_${DateTime.now().microsecondsSinceEpoch}',
          classroomId: classroomId,
          name: cleanName,
          memberIds: members,
        ));
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  List<PeerReview> peerReviewsFor(String assignmentId) =>
      List.unmodifiable(_peerReviews[assignmentId] ?? const []);

  List<PeerReview> peerReviewsForReviewer(String reviewerId) => List.unmodifiable(
        _peerReviews.values.expand((reviews) => reviews).where((review) => review.reviewerId == reviewerId),
      );

  bool submitPeerReview({
    required ClassroomAssignment assignment,
    required String reviewerId,
    required String revieweeId,
    required int rating,
    required String feedback,
  }) {
    final classroom = _classrooms[assignment.classroomId];
    if (!assignment.allowPeerReview || classroom == null || reviewerId == revieweeId ||
        !classroom.studentIds.contains(reviewerId) || !classroom.studentIds.contains(revieweeId) ||
        submissionFor(assignment.id, reviewerId) == null || submissionFor(assignment.id, revieweeId) == null ||
        rating < 1 || rating > 5 || feedback.trim().isEmpty ||
        peerReviewsFor(assignment.id).any((review) => review.reviewerId == reviewerId && review.revieweeId == revieweeId)) {
      return false;
    }
    _peerReviews.putIfAbsent(assignment.id, () => []).add(PeerReview(
          id: 'peer_${DateTime.now().microsecondsSinceEpoch}',
          assignmentId: assignment.id,
          reviewerId: reviewerId,
          revieweeId: revieweeId,
          rating: rating,
          feedback: feedback.trim(),
          createdAt: DateTime.now(),
        ));
    addNotification(
      recipientUserId: revieweeId,
      classroomId: classroom.id,
      classroomName: classroom.name,
      title: 'Peer Review Received',
      message: 'A classmate reviewed your submission for ${assignment.title}.',
      type: 'assignment',
    );
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  List<RecentlyViewedItem> recentlyViewedFor(String userId) =>
      List.unmodifiable(_recentlyViewed[userId] ?? const []);

  void recordRecentlyViewed(String userId, String type, String id, String title, String classroomId) {
    if (userId.isEmpty || id.isEmpty) return;
    final items = _recentlyViewed.putIfAbsent(userId, () => []);
    items.removeWhere((item) => item.type == type && item.id == id);
    items.insert(0, RecentlyViewedItem(
          type: type,
          id: id,
          title: title,
          classroomId: classroomId,
          viewedAt: DateTime.now(),
        ));
    if (items.length > 20) items.removeRange(20, items.length);
    _saveToPrefs();
    notifyListeners();
  }

  List<ClassroomActivity> activitiesFor(String classroomId) {
    final activities = <ClassroomActivity>[];
    for (final post in _posts[classroomId] ?? const <ClassroomPost>[]) {
      activities.add(ClassroomActivity(type: post.authorRole == 'student' ? 'question' : 'announcement', title: post.isPinned ? 'Pinned announcement' : (post.authorRole == 'student' ? 'Classroom question' : 'Announcement'), description: post.text, timestamp: post.createdAt));
    }
    for (final assignment in _assignments[classroomId] ?? const <ClassroomAssignment>[]) {
      activities.add(ClassroomActivity(type: 'assignment', title: assignment.isDraft ? 'Assignment draft' : 'Assignment published', description: assignment.title, timestamp: assignment.createdAt ?? DateTime.now()));
    }
    for (final quiz in _quizzes[classroomId] ?? const <ClassroomQuiz>[]) {
      activities.add(ClassroomActivity(type: 'quiz', title: quiz.isDraft ? 'Quiz draft' : 'Quiz published', description: quiz.title, timestamp: quiz.createdAt));
    }
    for (final poll in _polls[classroomId] ?? const <ClassroomPoll>[]) {
      activities.add(ClassroomActivity(type: 'poll', title: 'Classroom poll', description: poll.question, timestamp: poll.createdAt));
    }
    for (final material in _materials[classroomId] ?? const <ClassroomMaterial>[]) {
      activities.add(ClassroomActivity(type: 'material', title: 'Learning resource added', description: material.title, timestamp: material.uploadedAt));
    }
    for (final session in _attendanceSessions[classroomId] ?? const <ClassroomAttendanceSession>[]) {
      activities.add(ClassroomActivity(type: 'attendance', title: 'Attendance recorded', description: session.topic, timestamp: session.date));
    }
    for (final submissions in _submissions.values) {
      for (final submission in submissions.where((item) => item.classroomId == classroomId)) {
        activities.add(ClassroomActivity(type: 'submission', title: 'Assignment submitted', description: submission.studentName.isEmpty ? submission.studentId : submission.studentName, timestamp: submission.submittedAt));
        for (final grade in submission.gradeHistory) {
          activities.add(ClassroomActivity(type: 'grade', title: 'Grade returned', description: '${grade.marks} marks · ${grade.gradedBy}', timestamp: grade.gradedAt));
        }
      }
    }
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(activities);
  }

  void deleteAssignment(String classroomId, String assignmentId) {
    _assignments[classroomId]?.removeWhere((a) => a.id == assignmentId);
    _submissions.remove(assignmentId);
    _peerReviews.remove(assignmentId);
    _saveToPrefs();
    notifyListeners();
  }

  // ==========================================
  // Submissions & Grading
  // ==========================================

  List<ClassroomSubmission> submissionsFor(String assignmentId) =>
      List.unmodifiable(_submissions[assignmentId] ?? const []);

  ClassroomSubmission? submissionFor(String assignmentId, String studentId) {
    final subs = _submissions[assignmentId] ?? const [];
    for (final s in subs) {
      if (s.studentId == studentId) return s;
    }
    return null;
  }

  void submit(
    String assignmentId,
    String studentId,
    String comment, {
    String classroomId = '',
    String studentName = '',
    String studentRoll = '',
    String? attachmentName,
    String? attachmentUrl,
    Uint8List? attachmentBytes,
  }) {
    final submissions = _submissions.putIfAbsent(assignmentId, () => []);
    final existingIndex = submissions.indexWhere((s) => s.studentId == studentId);
    final priorMarks = existingIndex >= 0 ? submissions[existingIndex].marks : null;
    final priorFeedback = existingIndex >= 0 ? submissions[existingIndex].feedback : null;

    final submission = ClassroomSubmission(
      id: 'sub_${DateTime.now().microsecondsSinceEpoch}',
      assignmentId: assignmentId,
      classroomId: classroomId,
      studentId: studentId,
      studentName: studentName,
      studentRoll: studentRoll,
      comment: comment,
      submittedAt: DateTime.now(),
      attachmentName: attachmentName,
      attachmentUrl: attachmentUrl,
      attachmentBytes: attachmentBytes,
      marks: priorMarks,
      feedback: priorFeedback,
      status: priorMarks != null ? SubmissionStatus.graded : SubmissionStatus.submitted,
    );

    submissions.removeWhere((s) => s.studentId == studentId);
    submissions.add(submission);

    // Notify teacher
    final classroom = _classrooms[classroomId];
    if (classroom != null) {
      addNotification(
        recipientUserId: classroom.teacherId,
        classroomId: classroomId,
        classroomName: classroom.name,
        title: 'Assignment Submitted',
        message: '${studentName.isNotEmpty ? studentName : "A student"} submitted their assignment.',
        type: 'assignment',
      );
    }

    _saveToPrefs();
    notifyListeners();
  }

  void unsubmit(String assignmentId, String studentId) {
    final submissions = _submissions[assignmentId];
    if (submissions == null) return;
    submissions.removeWhere((s) => s.studentId == studentId && s.marks == null);
    _saveToPrefs();
    notifyListeners();
  }

  void grade(
    String assignmentId,
    String studentId,
    int marks,
    String feedback, {
    String gradedBy = '',
    Map<String, int> rubricScores = const {},
  }) {
    final submissions = _submissions.putIfAbsent(assignmentId, () => []);
    final index = submissions.indexWhere((s) => s.studentId == studentId);
    if (index < 0) return;
    final prior = submissions[index];

    final gradeRecord = GradeRecord(
      marks: marks,
      feedback: feedback,
      gradedAt: DateTime.now(),
      gradedBy: gradedBy,
      rubricScores: Map.unmodifiable(rubricScores),
    );
    submissions[index] = prior.copyWith(
      marks: marks,
      feedback: feedback,
      gradedAt: gradeRecord.gradedAt,
      gradedBy: gradedBy,
      status: SubmissionStatus.graded,
      gradeHistory: [...prior.gradeHistory, gradeRecord],
    );

    // Notify student
    final classroom = _classrooms[prior.classroomId];
    addNotification(
      recipientUserId: studentId,
      classroomId: prior.classroomId,
      classroomName: classroom?.name ?? 'Classroom',
      title: 'Assignment Graded: $marks marks',
      message: 'Your work has been graded with score $marks. Feedback: $feedback',
      type: 'grade',
    );

    _saveToPrefs();
    notifyListeners();
  }

  // ==========================================
  // Attendance System
  // ==========================================

  List<ClassroomAttendanceSession> attendanceSessionsFor(String classroomId) {
    final list = _attendanceSessions[classroomId] ?? const [];
    final sorted = List<ClassroomAttendanceSession>.from(list);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  void recordAttendanceSession({
    required String classroomId,
    required DateTime date,
    required String topic,
    required String takenByTeacherId,
    required Map<String, AttendanceStatus> records,
    Map<String, String>? notes,
  }) {
    final sessions = _attendanceSessions.putIfAbsent(classroomId, () => []);
    final session = ClassroomAttendanceSession(
      id: 'att_${DateTime.now().microsecondsSinceEpoch}',
      classroomId: classroomId,
      date: date,
      topic: topic,
      takenByTeacherId: takenByTeacherId,
      records: records,
      notes: notes,
    );
    sessions.insert(0, session);

    // Notify absent / late students
    final classroom = _classrooms[classroomId];
    records.forEach((sId, status) {
      if (status == AttendanceStatus.absent || status == AttendanceStatus.late) {
        addNotification(
          recipientUserId: sId,
          classroomId: classroomId,
          classroomName: classroom?.name ?? 'Classroom',
          title: 'Attendance Marked: ${status.label}',
          message: 'You were marked ${status.label} for session "$topic" on ${date.day}/${date.month}/${date.year}.',
          type: 'attendance',
        );
      }
    });

    _saveToPrefs();
    notifyListeners();
  }

  void updateAttendanceSession(ClassroomAttendanceSession session) {
    final sessions = _attendanceSessions[session.classroomId];
    if (sessions == null) return;
    final index = sessions.indexWhere((s) => s.id == session.id);
    if (index < 0) return;
    sessions[index] = session;
    _saveToPrefs();
    notifyListeners();
  }

  void deleteAttendanceSession(String classroomId, String sessionId) {
    _attendanceSessions[classroomId]?.removeWhere((s) => s.id == sessionId);
    _saveToPrefs();
    notifyListeners();
  }

  /// Calculate student's personal attendance percentage in a class
  double calculateStudentAttendance(String classroomId, String studentId) {
    final sessions = _attendanceSessions[classroomId] ?? const [];
    if (sessions.isEmpty) return 100.0;
    int presentCount = 0;
    int totalCount = 0;
    for (final s in sessions) {
      if (s.records.containsKey(studentId)) {
        totalCount++;
        final status = s.records[studentId];
        if (status == AttendanceStatus.present || status == AttendanceStatus.excused) {
          presentCount++;
        } else if (status == AttendanceStatus.late) {
          presentCount += 1; // Counted with late penalty or full
        }
      }
    }
    return totalCount == 0 ? 100.0 : (presentCount / totalCount) * 100.0;
  }

  /// Overall attendance rate for entire class
  double calculateClassAttendanceRate(String classroomId) {
    final sessions = _attendanceSessions[classroomId] ?? const [];
    if (sessions.isEmpty) return 100.0;
    int presentSum = 0;
    int totalSum = 0;
    for (final s in sessions) {
      s.records.forEach((_, status) {
        totalSum++;
        if (status == AttendanceStatus.present || status == AttendanceStatus.excused || status == AttendanceStatus.late) {
          presentSum++;
        }
      });
    }
    return totalSum == 0 ? 100.0 : (presentSum / totalSum) * 100.0;
  }

  // ==========================================
  // Learning Materials
  // ==========================================

  List<ClassroomMaterial> materialsFor(String classroomId, [String? topic]) {
    final items = _materials[classroomId] ?? const [];
    if (topic == null || topic.isEmpty || topic == 'All Topics') {
      return List.unmodifiable(items);
    }
    return items.where((m) => m.topic.toLowerCase() == topic.toLowerCase()).toList();
  }

  List<String> topicsFor(String classroomId) {
    final items = _materials[classroomId] ?? const [];
    final set = <String>{'All Topics'};
    for (final m in items) {
      if (m.topic.isNotEmpty) set.add(m.topic);
    }
    return set.toList();
  }

  void addMaterial({
    required String classroomId,
    required String title,
    required String description,
    required String topic,
    required String uploadedBy,
    String? attachmentName,
    String? attachmentUrl,
    Uint8List? attachmentBytes,
    String? linkUrl,
    String fileType = 'document',
  }) {
    final items = _materials.putIfAbsent(classroomId, () => []);
    final material = ClassroomMaterial(
      id: 'mat_${DateTime.now().microsecondsSinceEpoch}',
      classroomId: classroomId,
      title: title,
      description: description,
      topic: topic,
      uploadedBy: uploadedBy,
      uploadedAt: DateTime.now(),
      attachmentName: attachmentName,
      attachmentUrl: attachmentUrl,
      attachmentBytes: attachmentBytes,
      linkUrl: linkUrl,
      fileType: fileType,
    );
    items.insert(0, material);

    // Notify students
    final classroom = _classrooms[classroomId];
    if (classroom != null) {
      for (final sId in classroom.studentIds) {
        addNotification(
          recipientUserId: sId,
          classroomId: classroomId,
          classroomName: classroom.name,
          title: 'New Material: $title',
          message: '$uploadedBy uploaded new study resources for $topic.',
          type: 'material',
        );
      }
    }

    _saveToPrefs();
    notifyListeners();
  }

  void updateMaterial(ClassroomMaterial material) {
    final items = _materials[material.classroomId];
    if (items == null) return;
    final index = items.indexWhere((m) => m.id == material.id);
    if (index < 0) return;
    items[index] = material;
    _saveToPrefs();
    notifyListeners();
  }

  void deleteMaterial(String classroomId, String materialId) {
    _materials[classroomId]?.removeWhere((m) => m.id == materialId);
    _saveToPrefs();
    notifyListeners();
  }

  // ==========================================
  // Notifications
  // ==========================================

  List<ClassroomNotification> notificationsFor(String userId) {
    final list = _notifications[userId] ?? const [];
    final sorted = List<ClassroomNotification>.from(list);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(sorted);
  }

  int unreadNotificationsCount(String userId) {
    final list = _notifications[userId] ?? const [];
    return list.where((n) => !n.isRead).length;
  }

  void addNotification({
    required String recipientUserId,
    required String classroomId,
    required String classroomName,
    required String title,
    required String message,
    required String type,
  }) {
    if (recipientUserId.isEmpty) return;
    final list = _notifications.putIfAbsent(recipientUserId, () => []);
    list.insert(
      0,
      ClassroomNotification(
        id: 'notif_${DateTime.now().microsecondsSinceEpoch}',
        recipientUserId: recipientUserId,
        classroomId: classroomId,
        classroomName: classroomName,
        title: title,
        message: message,
        type: type,
        timestamp: DateTime.now(),
      ),
    );
    _saveToPrefs();
  }

  void markNotificationAsRead(String notificationId, String userId) {
    final list = _notifications[userId];
    if (list == null) return;
    final index = list.indexWhere((n) => n.id == notificationId);
    if (index < 0) return;
    list[index] = list[index].copyWith(isRead: true);
    _saveToPrefs();
    notifyListeners();
  }

  void markAllNotificationsAsRead(String userId) {
    final list = _notifications[userId];
    if (list == null) return;
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(isRead: true);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void clearNotifications(String userId) {
    _notifications.remove(userId);
    _saveToPrefs();
    notifyListeners();
  }

  // ==========================================
  // Analytics & Progress Calculations
  // ==========================================

  ClassroomAnalyticsSummary getClassroomAnalytics(String classroomId) {
    final classroom = _classrooms[classroomId];
    if (classroom == null) {
      return const ClassroomAnalyticsSummary(
        totalStudents: 0,
        totalAssignments: 0,
        totalSubmissions: 0,
        submissionRate: 0,
        averageScorePercentage: 0,
        attendanceRate: 0,
        gradeDistribution: {},
        atRiskStudentIds: [],
      );
    }

    final assignments = (_assignments[classroomId] ?? const [])
        .where((assignment) => !assignment.isDraft)
        .toList();
    final totalStudents = classroom.studentIds.length;
    final totalAssignments = assignments.length;

    int totalSubmissions = 0;
    double totalScoresPercentSum = 0;
    int gradedCount = 0;
    final gradeDistribution = <String, int>{'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0};

    final studentScores = <String, List<double>>{};
    for (final a in assignments) {
      final subs = _submissions[a.id] ?? const [];
      totalSubmissions += subs.length;
      for (final s in subs) {
        if (s.marks != null && a.maxMarks > 0) {
          final pct = (s.marks! / a.maxMarks) * 100.0;
          totalScoresPercentSum += pct;
          gradedCount++;
          studentScores.putIfAbsent(s.studentId, () => []).add(pct);

          if (pct >= 85) {
            gradeDistribution['A'] = (gradeDistribution['A'] ?? 0) + 1;
          } else if (pct >= 70) {
            gradeDistribution['B'] = (gradeDistribution['B'] ?? 0) + 1;
          } else if (pct >= 55) {
            gradeDistribution['C'] = (gradeDistribution['C'] ?? 0) + 1;
          } else if (pct >= 40) {
            gradeDistribution['D'] = (gradeDistribution['D'] ?? 0) + 1;
          } else {
            gradeDistribution['F'] = (gradeDistribution['F'] ?? 0) + 1;
          }
        }
      }
    }

    final expectedSubmissions = totalStudents * totalAssignments;
    final submissionRate = expectedSubmissions > 0
        ? (totalSubmissions / expectedSubmissions) * 100.0
        : 100.0;
    final averageScore = gradedCount > 0 ? (totalScoresPercentSum / gradedCount) : 0.0;
    final attendanceRate = calculateClassAttendanceRate(classroomId);

    // Identify at-risk students (<75% attendance or average score < 50%)
    final atRiskList = <String>[];
    for (final sId in classroom.studentIds) {
      final att = calculateStudentAttendance(classroomId, sId);
      final scores = studentScores[sId] ?? [];
      final avg = scores.isEmpty
          ? 0.0
          : scores.reduce((a, b) => a + b) / scores.length;
      if (att < 75.0 || (scores.isNotEmpty && avg < 50.0)) {
        atRiskList.add(sId);
      }
    }

    return ClassroomAnalyticsSummary(
      totalStudents: totalStudents,
      totalAssignments: totalAssignments,
      totalSubmissions: totalSubmissions,
      submissionRate: submissionRate.clamp(0.0, 100.0),
      averageScorePercentage: averageScore.clamp(0.0, 100.0),
      attendanceRate: attendanceRate.clamp(0.0, 100.0),
      gradeDistribution: gradeDistribution,
      atRiskStudentIds: atRiskList,
    );
  }

  StudentProgressSummary getStudentProgress(String classroomId, String studentId) {
    final assignments = (_assignments[classroomId] ?? const [])
        .where((assignment) => !assignment.isDraft)
        .toList();
    int submittedCount = 0;
    int gradedCount = 0;
    int missingCount = 0;
    double scoreSum = 0;
    int gradedPoints = 0;

    final now = DateTime.now();

    for (final a in assignments) {
      final sub = submissionFor(a.id, studentId);
      if (sub != null) {
        submittedCount++;
        if (sub.marks != null) {
          gradedCount++;
          scoreSum += sub.marks!;
          gradedPoints += a.maxMarks;
        }
      } else {
        if (a.dueAt != null && a.dueAt!.isBefore(now)) {
          missingCount++;
        }
      }
    }

    final avgPercent = gradedPoints > 0 ? (scoreSum / gradedPoints) * 100.0 : 0.0;
    final letterGrade = avgPercent >= 90
        ? 'A+'
        : avgPercent >= 80
        ? 'A'
        : avgPercent >= 70
        ? 'B'
        : avgPercent >= 60
        ? 'C'
        : avgPercent >= 45
        ? 'D'
        : 'F';

    final sessions = _attendanceSessions[classroomId] ?? const [];
    int presentCount = 0;
    int totalSessions = 0;
    for (final s in sessions) {
      if (s.records.containsKey(studentId)) {
        totalSessions++;
        final status = s.records[studentId];
        if (status == AttendanceStatus.present || status == AttendanceStatus.excused || status == AttendanceStatus.late) {
          presentCount++;
        }
      }
    }

    final attPercent = totalSessions == 0 ? 100.0 : (presentCount / totalSessions) * 100.0;

    return StudentProgressSummary(
      studentId: studentId,
      classroomId: classroomId,
      totalAssignments: assignments.length,
      submittedCount: submittedCount,
      gradedCount: gradedCount,
      missingCount: missingCount,
      averageGradePercentage: avgPercent,
      letterGrade: gradedCount == 0 ? 'N/A' : letterGrade,
      attendancePercentage: attPercent,
      totalAttendanceSessions: totalSessions,
      presentCount: presentCount,
    );
  }

  // ==========================================
  // SharedPreferences Persistence
  // ==========================================

  Future<void> loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Classrooms
      final classroomsJson = prefs.getString(_storageKeyClassrooms);
      if (classroomsJson != null && classroomsJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(classroomsJson);
        _classrooms.clear();
        for (final item in list) {
          final c = ClassroomModel.fromJson(item as Map<String, dynamic>);
          _classrooms[c.id] = c;
        }
      }

      // Posts
      final postsJson = prefs.getString(_storageKeyPosts);
      if (postsJson != null && postsJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(postsJson);
        _posts.clear();
        map.forEach((k, v) {
          _posts[k] = (v as List<dynamic>)
              .map((p) => ClassroomPost.fromJson(p as Map<String, dynamic>))
              .toList();
        });
      }

      // Assignments
      final asgJson = prefs.getString(_storageKeyAssignments);
      if (asgJson != null && asgJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(asgJson);
        _assignments.clear();
        map.forEach((k, v) {
          _assignments[k] = (v as List<dynamic>)
              .map((a) => ClassroomAssignment.fromJson(a as Map<String, dynamic>))
              .toList();
        });
      }

      // Submissions
      final subJson = prefs.getString(_storageKeySubmissions);
      if (subJson != null && subJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(subJson);
        _submissions.clear();
        map.forEach((k, v) {
          _submissions[k] = (v as List<dynamic>)
              .map((s) => ClassroomSubmission.fromJson(s as Map<String, dynamic>))
              .toList();
        });
      }

      // Materials
      final matJson = prefs.getString(_storageKeyMaterials);
      if (matJson != null && matJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(matJson);
        _materials.clear();
        map.forEach((k, v) {
          _materials[k] = (v as List<dynamic>)
              .map((m) => ClassroomMaterial.fromJson(m as Map<String, dynamic>))
              .toList();
        });
      }

      // Attendance
      final attJson = prefs.getString(_storageKeyAttendance);
      if (attJson != null && attJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(attJson);
        _attendanceSessions.clear();
        map.forEach((k, v) {
          _attendanceSessions[k] = (v as List<dynamic>)
              .map((a) => ClassroomAttendanceSession.fromJson(a as Map<String, dynamic>))
              .toList();
        });
      }

      // Notifications
      final notifJson = prefs.getString(_storageKeyNotifications);
      if (notifJson != null && notifJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(notifJson);
        _notifications.clear();
        map.forEach((k, v) {
          _notifications[k] = (v as List<dynamic>)
              .map((n) => ClassroomNotification.fromJson(n as Map<String, dynamic>))
              .toList();
        });
      }

      final quizJson = prefs.getString(_storageKeyQuizzes);
      if (quizJson != null && quizJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(quizJson);
        _quizzes
          ..clear()
          ..addAll(map.map((key, value) => MapEntry(
                key,
                (value as List<dynamic>).map((item) => ClassroomQuiz.fromJson(item as Map<String, dynamic>)).toList(),
              )));
      }
      final attemptsJson = prefs.getString(_storageKeyQuizAttempts);
      if (attemptsJson != null && attemptsJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(attemptsJson);
        _quizAttempts
          ..clear()
          ..addAll(map.map((key, value) => MapEntry(
                key,
                (value as List<dynamic>).map((item) => QuizAttempt.fromJson(item as Map<String, dynamic>)).toList(),
              )));
      }
      final pollsJson = prefs.getString(_storageKeyPolls);
      if (pollsJson != null && pollsJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(pollsJson);
        _polls
          ..clear()
          ..addAll(map.map((key, value) => MapEntry(
                key,
                (value as List<dynamic>).map((item) => ClassroomPoll.fromJson(item as Map<String, dynamic>)).toList(),
              )));
      }
      final groupsJson = prefs.getString(_storageKeyGroups);
      if (groupsJson != null && groupsJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(groupsJson);
        _groups
          ..clear()
          ..addAll(map.map((key, value) => MapEntry(
                key,
                (value as List<dynamic>).map((item) => ClassroomGroup.fromJson(item as Map<String, dynamic>)).toList(),
              )));
      }
      final reviewsJson = prefs.getString(_storageKeyPeerReviews);
      if (reviewsJson != null && reviewsJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(reviewsJson);
        _peerReviews
          ..clear()
          ..addAll(map.map((key, value) => MapEntry(
                key,
                (value as List<dynamic>).map((item) => PeerReview.fromJson(item as Map<String, dynamic>)).toList(),
              )));
      }
      final recentJson = prefs.getString(_storageKeyRecentlyViewed);
      if (recentJson != null && recentJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(recentJson);
        _recentlyViewed
          ..clear()
          ..addAll(map.map((key, value) => MapEntry(
                key,
                (value as List<dynamic>).map((item) => RecentlyViewedItem.fromJson(item as Map<String, dynamic>)).toList(),
              )));
      }
    } catch (_) {}

    // Remove the original bundled demo classrooms and their sample activity.
    // Newly opened accounts should start empty; only user-created records remain.
    const legacyDemoIds = {'cls_ds_401', 'cls_db_303', 'cls_ai_502'};
    final removedClassIds = legacyDemoIds.where(_classrooms.containsKey).toSet();
    if (removedClassIds.isNotEmpty) {
      _classrooms.removeWhere((id, _) => removedClassIds.contains(id));
      for (final id in removedClassIds) {
        _posts.remove(id);
        _materials.remove(id);
        _attendanceSessions.remove(id);
        _polls.remove(id);
        _groups.remove(id);
        for (final assignment in _assignments.remove(id) ?? const <ClassroomAssignment>[]) {
          _submissions.remove(assignment.id);
          _peerReviews.remove(assignment.id);
        }
        for (final quiz in _quizzes.remove(id) ?? const <ClassroomQuiz>[]) {
          _quizAttempts.remove(quiz.id);
        }
      }
      for (final notifications in _notifications.values) {
        notifications.removeWhere((notification) => removedClassIds.contains(notification.classroomId));
      }
      _saveToPrefs();
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveToPrefs() {
    // Serialize writes so a slower earlier save cannot overwrite newer state.
    _pendingSave = _pendingSave.then((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final classroomsList = _classrooms.values.map((c) => c.toJson()).toList();
        await prefs.setString(_storageKeyClassrooms, jsonEncode(classroomsList));
        final postsMap = _posts.map((k, v) => MapEntry(k, v.map((p) => p.toJson()).toList()));
        await prefs.setString(_storageKeyPosts, jsonEncode(postsMap));
        final asgMap = _assignments.map((k, v) => MapEntry(k, v.map((a) => a.toJson()).toList()));
        await prefs.setString(_storageKeyAssignments, jsonEncode(asgMap));
        final subMap = _submissions.map((k, v) => MapEntry(k, v.map((s) => s.toJson()).toList()));
        await prefs.setString(_storageKeySubmissions, jsonEncode(subMap));
        final matMap = _materials.map((k, v) => MapEntry(k, v.map((m) => m.toJson()).toList()));
        await prefs.setString(_storageKeyMaterials, jsonEncode(matMap));
        final attMap = _attendanceSessions.map((k, v) => MapEntry(k, v.map((a) => a.toJson()).toList()));
        await prefs.setString(_storageKeyAttendance, jsonEncode(attMap));
        final notifMap = _notifications.map((k, v) => MapEntry(k, v.map((n) => n.toJson()).toList()));
        await prefs.setString(_storageKeyNotifications, jsonEncode(notifMap));
        final quizMap = _quizzes.map((k, v) => MapEntry(k, v.map((item) => item.toJson()).toList()));
        await prefs.setString(_storageKeyQuizzes, jsonEncode(quizMap));
        final attemptMap = _quizAttempts.map((k, v) => MapEntry(k, v.map((item) => item.toJson()).toList()));
        await prefs.setString(_storageKeyQuizAttempts, jsonEncode(attemptMap));
        final pollMap = _polls.map((k, v) => MapEntry(k, v.map((item) => item.toJson()).toList()));
        await prefs.setString(_storageKeyPolls, jsonEncode(pollMap));
        final groupMap = _groups.map((k, v) => MapEntry(k, v.map((item) => item.toJson()).toList()));
        await prefs.setString(_storageKeyGroups, jsonEncode(groupMap));
        final reviewMap = _peerReviews.map((k, v) => MapEntry(k, v.map((item) => item.toJson()).toList()));
        await prefs.setString(_storageKeyPeerReviews, jsonEncode(reviewMap));
        final recentMap = _recentlyViewed.map((k, v) => MapEntry(k, v.map((item) => item.toJson()).toList()));
        await prefs.setString(_storageKeyRecentlyViewed, jsonEncode(recentMap));
      } catch (_) {}
    });
    return _pendingSave;
  }
}
