import 'dart:convert';
import 'dart:typed_data';

/// Role-based access control roles for Classroom
enum ClassroomRole {
  student,
  teacher,
  admin;

  static ClassroomRole fromString(String? role) {
    if (role == null) return ClassroomRole.student;
    final r = role.toLowerCase().trim();
    if (r == 'teacher' || r == 'faculty' || r == 'instructor') {
      return ClassroomRole.teacher;
    }
    if (r == 'admin' || r == 'institute') {
      return ClassroomRole.admin;
    }
    return ClassroomRole.student;
  }
}

/// Status for attendance sessions
enum AttendanceStatus {
  present,
  absent,
  late,
  excused;

  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }

  static AttendanceStatus fromString(String? val) {
    if (val == null) return AttendanceStatus.present;
    switch (val.toLowerCase().trim()) {
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'excused':
        return AttendanceStatus.excused;
      default:
        return AttendanceStatus.present;
    }
  }
}

/// Status for assignment submissions
enum SubmissionStatus {
  assigned,
  submitted,
  graded,
  late,
  missing;

  String get label {
    switch (this) {
      case SubmissionStatus.assigned:
        return 'Assigned';
      case SubmissionStatus.submitted:
        return 'Submitted';
      case SubmissionStatus.graded:
        return 'Graded';
      case SubmissionStatus.late:
        return 'Late';
      case SubmissionStatus.missing:
        return 'Missing';
    }
  }

  static SubmissionStatus fromString(String? val) {
    if (val == null) return SubmissionStatus.assigned;
    switch (val.toLowerCase().trim()) {
      case 'submitted':
        return SubmissionStatus.submitted;
      case 'graded':
        return SubmissionStatus.graded;
      case 'late':
        return SubmissionStatus.late;
      case 'missing':
        return SubmissionStatus.missing;
      default:
        return SubmissionStatus.assigned;
    }
  }
}

/// Comment on an announcement or stream post
class ClassroomComment {
  const ClassroomComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorId': authorId,
    'authorName': authorName,
    'authorRole': authorRole,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ClassroomComment.fromJson(Map<String, dynamic> json) => ClassroomComment(
    id: json['id'] as String,
    authorId: (json['authorId'] ?? '') as String,
    authorName: (json['authorName'] ?? 'Anonymous') as String,
    authorRole: (json['authorRole'] ?? 'student') as String,
    text: (json['text'] ?? '') as String,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

/// Classroom stream announcement post
class ClassroomPost {
  const ClassroomPost({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    this.authorId = '',
    this.authorRole = 'teacher',
    this.classroomId = '',
    this.isPinned = false,
    this.attachmentName,
    this.attachmentUrl,
    this.attachmentBytes,
    this.comments = const [],
  });

  final String id;
  final String author;
  final String text;
  final DateTime createdAt;
  final String authorId;
  final String authorRole;
  final String classroomId;
  final bool isPinned;
  final String? attachmentName;
  final String? attachmentUrl;
  final Uint8List? attachmentBytes;
  final List<ClassroomComment> comments;

  ClassroomPost copyWith({
    String? author,
    String? text,
    DateTime? createdAt,
    String? authorId,
    String? authorRole,
    String? classroomId,
    bool? isPinned,
    String? attachmentName,
    String? attachmentUrl,
    Uint8List? attachmentBytes,
    List<ClassroomComment>? comments,
  }) => ClassroomPost(
    id: id,
    author: author ?? this.author,
    text: text ?? this.text,
    createdAt: createdAt ?? this.createdAt,
    authorId: authorId ?? this.authorId,
    authorRole: authorRole ?? this.authorRole,
    classroomId: classroomId ?? this.classroomId,
    isPinned: isPinned ?? this.isPinned,
    attachmentName: attachmentName ?? this.attachmentName,
    attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    attachmentBytes: attachmentBytes ?? this.attachmentBytes,
    comments: comments ?? this.comments,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'authorId': authorId,
    'authorRole': authorRole,
    'classroomId': classroomId,
    'isPinned': isPinned,
    'attachmentName': attachmentName,
    'attachmentUrl': attachmentUrl,
    'attachmentBase64': attachmentBytes != null ? base64Encode(attachmentBytes!) : null,
    'comments': comments.map((c) => c.toJson()).toList(),
  };

  factory ClassroomPost.fromJson(Map<String, dynamic> json) => ClassroomPost(
    id: json['id'] as String,
    author: (json['author'] ?? '') as String,
    text: (json['text'] ?? '') as String,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    authorId: (json['authorId'] ?? '') as String,
    authorRole: (json['authorRole'] ?? 'teacher') as String,
    classroomId: (json['classroomId'] ?? '') as String,
    isPinned: json['isPinned'] == true,
    attachmentName: json['attachmentName'] as String?,
    attachmentUrl: json['attachmentUrl'] as String?,
    attachmentBytes: json['attachmentBase64'] != null ? base64Decode(json['attachmentBase64'] as String) : null,
    comments: (json['comments'] as List<dynamic>?)
            ?.map((c) => ClassroomComment.fromJson(c as Map<String, dynamic>))
            .toList() ??
        const [],
  );
}

/// Course assignment model
class ClassroomAssignment {
  const ClassroomAssignment({
    required this.id,
    required this.title,
    required this.instructions,
    required this.maxMarks,
    this.dueAt,
    this.classroomId = '',
    this.teacherId = '',
    this.category = 'General',
    this.createdAt,
    this.attachmentName,
    this.attachmentUrl,
    this.attachmentBytes,
    this.allowLateSubmission = true,
    this.isDraft = false,
    this.allowPeerReview = false,
    this.rubric = const [],
  });

  final String id;
  final String title;
  final String instructions;
  final int maxMarks;
  final DateTime? dueAt;
  final String classroomId;
  final String teacherId;
  final String category; // 'Homework', 'Project', 'Quiz', 'Lab', 'General'
  final DateTime? createdAt;
  final String? attachmentName;
  final String? attachmentUrl;
  final Uint8List? attachmentBytes;
  final bool allowLateSubmission;
  final bool isDraft;
  final bool allowPeerReview;
  final List<RubricCriterion> rubric;

  ClassroomAssignment copyWith({
    String? title,
    String? instructions,
    int? maxMarks,
    DateTime? dueAt,
    String? classroomId,
    String? teacherId,
    String? category,
    DateTime? createdAt,
    String? attachmentName,
    String? attachmentUrl,
    Uint8List? attachmentBytes,
    bool clearAttachment = false,
    bool? allowLateSubmission,
    bool? isDraft,
    bool? allowPeerReview,
    List<RubricCriterion>? rubric,
  }) => ClassroomAssignment(
    id: id,
    title: title ?? this.title,
    instructions: instructions ?? this.instructions,
    maxMarks: maxMarks ?? this.maxMarks,
    dueAt: dueAt ?? this.dueAt,
    classroomId: classroomId ?? this.classroomId,
    teacherId: teacherId ?? this.teacherId,
    category: category ?? this.category,
    createdAt: createdAt ?? this.createdAt,
    attachmentName: clearAttachment ? null : (attachmentName ?? this.attachmentName),
    attachmentUrl: clearAttachment ? null : (attachmentUrl ?? this.attachmentUrl),
    attachmentBytes: clearAttachment ? null : (attachmentBytes ?? this.attachmentBytes),
    allowLateSubmission: allowLateSubmission ?? this.allowLateSubmission,
    isDraft: isDraft ?? this.isDraft,
    allowPeerReview: allowPeerReview ?? this.allowPeerReview,
    rubric: rubric ?? this.rubric,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'instructions': instructions,
    'maxMarks': maxMarks,
    'dueAt': dueAt?.toIso8601String(),
    'classroomId': classroomId,
    'teacherId': teacherId,
    'category': category,
    'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    'attachmentName': attachmentName,
    'attachmentUrl': attachmentUrl,
    'attachmentBase64': attachmentBytes != null ? base64Encode(attachmentBytes!) : null,
    'allowLateSubmission': allowLateSubmission,
    'isDraft': isDraft,
    'allowPeerReview': allowPeerReview,
    'rubric': rubric.map((criterion) => criterion.toJson()).toList(),
  };

  factory ClassroomAssignment.fromJson(Map<String, dynamic> json) => ClassroomAssignment(
    id: json['id'] as String,
    title: (json['title'] ?? '') as String,
    instructions: (json['instructions'] ?? '') as String,
    maxMarks: (json['maxMarks'] as num?)?.toInt() ?? 100,
    dueAt: json['dueAt'] != null ? DateTime.tryParse(json['dueAt'] as String) : null,
    classroomId: (json['classroomId'] ?? '') as String,
    teacherId: (json['teacherId'] ?? '') as String,
    category: (json['category'] ?? 'General') as String,
    createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    attachmentName: json['attachmentName'] as String?,
    attachmentUrl: json['attachmentUrl'] as String?,
    attachmentBytes: json['attachmentBase64'] != null ? base64Decode(json['attachmentBase64'] as String) : null,
    allowLateSubmission: json['allowLateSubmission'] != false,
    isDraft: json['isDraft'] == true,
    allowPeerReview: json['allowPeerReview'] == true,
    rubric: (json['rubric'] as List<dynamic>?)
            ?.map((item) => RubricCriterion.fromJson(item as Map<String, dynamic>))
            .toList() ??
        const [],
  );
}

/// Student assignment submission
class ClassroomSubmission {
  const ClassroomSubmission({
    required this.assignmentId,
    required this.studentId,
    required this.comment,
    required this.submittedAt,
    this.id = '',
    this.classroomId = '',
    this.studentName = '',
    this.studentRoll = '',
    this.attachmentName,
    this.attachmentUrl,
    this.attachmentBytes,
    this.marks,
    this.feedback,
    this.gradedAt,
    this.gradedBy,
    this.status = SubmissionStatus.submitted,
    this.gradeHistory = const [],
  });

  final String id;
  final String assignmentId;
  final String classroomId;
  final String studentId;
  final String studentName;
  final String studentRoll;
  final String comment;
  final DateTime submittedAt;
  final String? attachmentName;
  final String? attachmentUrl;
  final Uint8List? attachmentBytes;
  final int? marks;
  final String? feedback;
  final DateTime? gradedAt;
  final String? gradedBy;
  final SubmissionStatus status;
  final List<GradeRecord> gradeHistory;

  ClassroomSubmission copyWith({
    String? id,
    String? assignmentId,
    String? classroomId,
    String? studentId,
    String? studentName,
    String? studentRoll,
    String? comment,
    DateTime? submittedAt,
    String? attachmentName,
    String? attachmentUrl,
    Uint8List? attachmentBytes,
    int? marks,
    String? feedback,
    DateTime? gradedAt,
    String? gradedBy,
    SubmissionStatus? status,
    List<GradeRecord>? gradeHistory,
  }) => ClassroomSubmission(
    id: id ?? this.id,
    assignmentId: assignmentId ?? this.assignmentId,
    classroomId: classroomId ?? this.classroomId,
    studentId: studentId ?? this.studentId,
    studentName: studentName ?? this.studentName,
    studentRoll: studentRoll ?? this.studentRoll,
    comment: comment ?? this.comment,
    submittedAt: submittedAt ?? this.submittedAt,
    attachmentName: attachmentName ?? this.attachmentName,
    attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    attachmentBytes: attachmentBytes ?? this.attachmentBytes,
    marks: marks ?? this.marks,
    feedback: feedback ?? this.feedback,
    gradedAt: gradedAt ?? this.gradedAt,
    gradedBy: gradedBy ?? this.gradedBy,
    status: status ?? this.status,
    gradeHistory: gradeHistory ?? this.gradeHistory,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'assignmentId': assignmentId,
    'classroomId': classroomId,
    'studentId': studentId,
    'studentName': studentName,
    'studentRoll': studentRoll,
    'comment': comment,
    'submittedAt': submittedAt.toIso8601String(),
    'attachmentName': attachmentName,
    'attachmentUrl': attachmentUrl,
    'attachmentBase64': attachmentBytes != null ? base64Encode(attachmentBytes!) : null,
    'marks': marks,
    'feedback': feedback,
    'gradedAt': gradedAt?.toIso8601String(),
    'gradedBy': gradedBy,
    'status': status.name,
    'gradeHistory': gradeHistory.map((record) => record.toJson()).toList(),
  };

  factory ClassroomSubmission.fromJson(Map<String, dynamic> json) => ClassroomSubmission(
    id: (json['id'] ?? '') as String,
    assignmentId: (json['assignmentId'] ?? '') as String,
    classroomId: (json['classroomId'] ?? '') as String,
    studentId: (json['studentId'] ?? '') as String,
    studentName: (json['studentName'] ?? '') as String,
    studentRoll: (json['studentRoll'] ?? '') as String,
    comment: (json['comment'] ?? '') as String,
    submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? '') ?? DateTime.now(),
    attachmentName: json['attachmentName'] as String?,
    attachmentUrl: json['attachmentUrl'] as String?,
    attachmentBytes: json['attachmentBase64'] != null ? base64Decode(json['attachmentBase64'] as String) : null,
    marks: (json['marks'] as num?)?.toInt(),
    feedback: json['feedback'] as String?,
    gradedAt: json['gradedAt'] != null ? DateTime.tryParse(json['gradedAt'] as String) : null,
    gradedBy: json['gradedBy'] as String?,
    status: SubmissionStatus.fromString(json['status'] as String?),
    gradeHistory: (json['gradeHistory'] as List<dynamic>?)
            ?.map((item) => GradeRecord.fromJson(item as Map<String, dynamic>))
            .toList() ??
        const [],
  );
}

/// Learning materials / course resources
class ClassroomMaterial {
  const ClassroomMaterial({
    required this.id,
    required this.classroomId,
    required this.title,
    required this.description,
    required this.topic,
    required this.uploadedBy,
    required this.uploadedAt,
    this.attachmentName,
    this.attachmentUrl,
    this.attachmentBytes,
    this.linkUrl,
    this.fileType = 'document',
  });

  final String id;
  final String classroomId;
  final String title;
  final String description;
  final String topic; // Module / Unit name
  final String uploadedBy;
  final DateTime uploadedAt;
  final String? attachmentName;
  final String? attachmentUrl;
  final Uint8List? attachmentBytes;
  final String? linkUrl;
  final String fileType; // 'pdf', 'document', 'slides', 'link', 'code', 'other'

  ClassroomMaterial copyWith({
    String? title,
    String? description,
    String? topic,
    String? uploadedBy,
    DateTime? uploadedAt,
    String? attachmentName,
    String? attachmentUrl,
    Uint8List? attachmentBytes,
    String? linkUrl,
    String? fileType,
    bool clearAttachment = false,
  }) => ClassroomMaterial(
    id: id,
    classroomId: classroomId,
    title: title ?? this.title,
    description: description ?? this.description,
    topic: topic ?? this.topic,
    uploadedBy: uploadedBy ?? this.uploadedBy,
    uploadedAt: uploadedAt ?? this.uploadedAt,
    attachmentName: clearAttachment ? null : (attachmentName ?? this.attachmentName),
    attachmentUrl: clearAttachment ? null : (attachmentUrl ?? this.attachmentUrl),
    attachmentBytes: clearAttachment ? null : (attachmentBytes ?? this.attachmentBytes),
    linkUrl: linkUrl ?? this.linkUrl,
    fileType: fileType ?? this.fileType,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'classroomId': classroomId,
    'title': title,
    'description': description,
    'topic': topic,
    'uploadedBy': uploadedBy,
    'uploadedAt': uploadedAt.toIso8601String(),
    'attachmentName': attachmentName,
    'attachmentUrl': attachmentUrl,
    'attachmentBase64': attachmentBytes != null ? base64Encode(attachmentBytes!) : null,
    'linkUrl': linkUrl,
    'fileType': fileType,
  };

  factory ClassroomMaterial.fromJson(Map<String, dynamic> json) => ClassroomMaterial(
    id: json['id'] as String,
    classroomId: (json['classroomId'] ?? '') as String,
    title: (json['title'] ?? '') as String,
    description: (json['description'] ?? '') as String,
    topic: (json['topic'] ?? 'General Resources') as String,
    uploadedBy: (json['uploadedBy'] ?? 'Teacher') as String,
    uploadedAt: DateTime.tryParse(json['uploadedAt'] as String? ?? '') ?? DateTime.now(),
    attachmentName: json['attachmentName'] as String?,
    attachmentUrl: json['attachmentUrl'] as String?,
    attachmentBytes: json['attachmentBase64'] != null ? base64Decode(json['attachmentBase64'] as String) : null,
    linkUrl: json['linkUrl'] as String?,
    fileType: (json['fileType'] ?? 'document') as String,
  );
}

/// Session-based attendance record for an entire classroom
class ClassroomAttendanceSession {
  ClassroomAttendanceSession({
    required this.id,
    required this.classroomId,
    required this.date,
    required this.topic,
    required this.takenByTeacherId,
    Map<String, AttendanceStatus>? records,
    Map<String, String>? notes,
  })  : records = Map.unmodifiable(records ?? {}),
        notes = Map.unmodifiable(notes ?? {});

  final String id;
  final String classroomId;
  final DateTime date;
  final String topic;
  final String takenByTeacherId;
  final Map<String, AttendanceStatus> records; // studentId -> status
  final Map<String, String> notes; // studentId -> note

  ClassroomAttendanceSession copyWith({
    DateTime? date,
    String? topic,
    Map<String, AttendanceStatus>? records,
    Map<String, String>? notes,
  }) => ClassroomAttendanceSession(
    id: id,
    classroomId: classroomId,
    date: date ?? this.date,
    topic: topic ?? this.topic,
    takenByTeacherId: takenByTeacherId,
    records: records ?? this.records,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'classroomId': classroomId,
    'date': date.toIso8601String(),
    'topic': topic,
    'takenByTeacherId': takenByTeacherId,
    'records': records.map((k, v) => MapEntry(k, v.name)),
    'notes': notes,
  };

  factory ClassroomAttendanceSession.fromJson(Map<String, dynamic> json) {
    final rawRec = json['records'] as Map<String, dynamic>? ?? {};
    final parsedRec = rawRec.map(
      (k, v) => MapEntry(k, AttendanceStatus.fromString(v as String?)),
    );
    final rawNotes = json['notes'] as Map<String, dynamic>? ?? {};
    final parsedNotes = rawNotes.map((k, v) => MapEntry(k, v.toString()));

    return ClassroomAttendanceSession(
      id: json['id'] as String,
      classroomId: (json['classroomId'] ?? '') as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      topic: (json['topic'] ?? 'Class Lecture') as String,
      takenByTeacherId: (json['takenByTeacherId'] ?? '') as String,
      records: parsedRec,
      notes: parsedNotes,
    );
  }
}

/// Notification model for class events
class ClassroomNotification {
  const ClassroomNotification({
    required this.id,
    required this.recipientUserId,
    required this.classroomId,
    required this.classroomName,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  final String id;
  final String recipientUserId;
  final String classroomId;
  final String classroomName;
  final String title;
  final String message;
  final String type; // 'assignment', 'grade', 'announcement', 'attendance', 'material'
  final DateTime timestamp;
  final bool isRead;

  ClassroomNotification copyWith({bool? isRead}) => ClassroomNotification(
    id: id,
    recipientUserId: recipientUserId,
    classroomId: classroomId,
    classroomName: classroomName,
    title: title,
    message: message,
    type: type,
    timestamp: timestamp,
    isRead: isRead ?? this.isRead,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipientUserId': recipientUserId,
    'classroomId': classroomId,
    'classroomName': classroomName,
    'title': title,
    'message': message,
    'type': type,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory ClassroomNotification.fromJson(Map<String, dynamic> json) => ClassroomNotification(
    id: json['id'] as String,
    recipientUserId: (json['recipientUserId'] ?? '') as String,
    classroomId: (json['classroomId'] ?? '') as String,
    classroomName: (json['classroomName'] ?? '') as String,
    title: (json['title'] ?? '') as String,
    message: (json['message'] ?? '') as String,
    type: (json['type'] ?? 'announcement') as String,
    timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    isRead: json['isRead'] == true,
  );
}

/// Main Classroom Model
class ClassroomModel {
  ClassroomModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.section,
    required this.description,
    required this.code,
    required this.teacherId,
    required this.teacherName,
    this.teacherEmail = '',
    this.room = '',
    this.bannerIndex = 0,
    List<String> studentIds = const [],
    this.bannerBytes,
    this.bannerUrl,
    this.isArchived = false,
    DateTime? createdAt,
  })  : studentIds = List.unmodifiable(studentIds),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final String subject;
  final String section;
  final String description;
  final String code;
  final String teacherId;
  final String teacherName;
  final String teacherEmail;
  final String room;
  final int bannerIndex;
  final List<String> studentIds;
  final Uint8List? bannerBytes;
  final String? bannerUrl;
  final bool isArchived;
  final DateTime createdAt;

  ClassroomModel copyWith({
    String? name,
    String? subject,
    String? section,
    String? description,
    String? code,
    String? teacherId,
    String? teacherName,
    String? teacherEmail,
    String? room,
    int? bannerIndex,
    List<String>? studentIds,
    Uint8List? bannerBytes,
    String? bannerUrl,
    bool clearBannerBytes = false,
    bool? isArchived,
  }) => ClassroomModel(
    id: id,
    name: name ?? this.name,
    subject: subject ?? this.subject,
    section: section ?? this.section,
    description: description ?? this.description,
    code: code ?? this.code,
    teacherId: teacherId ?? this.teacherId,
    teacherName: teacherName ?? this.teacherName,
    teacherEmail: teacherEmail ?? this.teacherEmail,
    room: room ?? this.room,
    bannerIndex: bannerIndex ?? this.bannerIndex,
    studentIds: studentIds ?? this.studentIds,
    bannerBytes: clearBannerBytes ? null : (bannerBytes ?? this.bannerBytes),
    bannerUrl: bannerUrl ?? this.bannerUrl,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subject': subject,
    'section': section,
    'description': description,
    'code': code,
    'teacherId': teacherId,
    'teacherName': teacherName,
    'teacherEmail': teacherEmail,
    'room': room,
    'bannerIndex': bannerIndex,
    'studentIds': studentIds,
    'bannerBase64': bannerBytes != null ? base64Encode(bannerBytes!) : null,
    'bannerUrl': bannerUrl,
    'isArchived': isArchived,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ClassroomModel.fromJson(Map<String, dynamic> json) => ClassroomModel(
    id: json['id'] as String,
    name: (json['name'] ?? '') as String,
    subject: (json['subject'] ?? '') as String,
    section: (json['section'] ?? '') as String,
    description: (json['description'] ?? '') as String,
    code: (json['code'] ?? '') as String,
    teacherId: (json['teacherId'] ?? '') as String,
    teacherName: (json['teacherName'] ?? '') as String,
    teacherEmail: (json['teacherEmail'] ?? '') as String,
    room: (json['room'] ?? '') as String,
    bannerIndex: (json['bannerIndex'] as num?)?.toInt() ?? 0,
    studentIds: (json['studentIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    bannerBytes: json['bannerBase64'] != null ? base64Decode(json['bannerBase64'] as String) : null,
    bannerUrl: json['bannerUrl'] as String?,
    isArchived: json['isArchived'] == true,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

/// Summary metrics for a classroom (Teacher / Admin analytics)
class ClassroomAnalyticsSummary {
  const ClassroomAnalyticsSummary({
    required this.totalStudents,
    required this.totalAssignments,
    required this.totalSubmissions,
    required this.submissionRate,
    required this.averageScorePercentage,
    required this.attendanceRate,
    required this.gradeDistribution,
    required this.atRiskStudentIds,
  });

  final int totalStudents;
  final int totalAssignments;
  final int totalSubmissions;
  final double submissionRate; // 0 - 100
  final double averageScorePercentage; // 0 - 100
  final double attendanceRate; // 0 - 100
  final Map<String, int> gradeDistribution; // 'A': count, 'B': count, etc.
  final List<String> atRiskStudentIds; // Students with <75% attendance or <50% score
}

/// Student's personal progress in a classroom
class StudentProgressSummary {
  const StudentProgressSummary({
    required this.studentId,
    required this.classroomId,
    required this.totalAssignments,
    required this.submittedCount,
    required this.gradedCount,
    required this.missingCount,
    required this.averageGradePercentage,
    required this.letterGrade,
    required this.attendancePercentage,
    required this.totalAttendanceSessions,
    required this.presentCount,
  });

  final String studentId;
  final String classroomId;
  final int totalAssignments;
  final int submittedCount;
  final int gradedCount;
  final int missingCount;
  final double averageGradePercentage;
  final String letterGrade; // A+, A, B, C, D, F
  final double attendancePercentage;
  final int totalAttendanceSessions;
  final int presentCount;

  double get completionRate => totalAssignments == 0 ? 100.0 : (submittedCount / totalAssignments) * 100.0;
}

class RubricCriterion {
  const RubricCriterion({required this.title, required this.maxPoints});
  final String title;
  final int maxPoints;

  Map<String, dynamic> toJson() => {'title': title, 'maxPoints': maxPoints};
  factory RubricCriterion.fromJson(Map<String, dynamic> json) => RubricCriterion(
        title: json['title'] as String? ?? '',
        maxPoints: (json['maxPoints'] as num?)?.toInt() ?? 0,
      );
}

class GradeRecord {
  const GradeRecord({required this.marks, required this.feedback, required this.gradedAt, required this.gradedBy, this.rubricScores = const {}});
  final int marks;
  final String feedback;
  final DateTime gradedAt;
  final String gradedBy;
  final Map<String, int> rubricScores;

  Map<String, dynamic> toJson() => {
        'marks': marks,
        'feedback': feedback,
        'gradedAt': gradedAt.toIso8601String(),
        'gradedBy': gradedBy,
        'rubricScores': rubricScores,
      };
  factory GradeRecord.fromJson(Map<String, dynamic> json) => GradeRecord(
        marks: (json['marks'] as num?)?.toInt() ?? 0,
        feedback: json['feedback'] as String? ?? '',
        gradedAt: DateTime.tryParse(json['gradedAt'] as String? ?? '') ?? DateTime.now(),
        gradedBy: json['gradedBy'] as String? ?? '',
        rubricScores: (json['rubricScores'] as Map<String, dynamic>? ?? const {})
            .map((key, value) => MapEntry(key, (value as num).toInt())),
      );
}

class QuizQuestion {
  const QuizQuestion({required this.prompt, required this.options, required this.correctOptionIndex, this.points = 1});
  final String prompt;
  final List<String> options;
  final int correctOptionIndex;
  final int points;

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'points': points,
      };
  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        prompt: json['prompt'] as String? ?? '',
        options: (json['options'] as List<dynamic>? ?? const []).map((value) => value.toString()).toList(),
        correctOptionIndex: (json['correctOptionIndex'] as num?)?.toInt() ?? 0,
        points: (json['points'] as num?)?.toInt() ?? 1,
      );
}

class ClassroomQuiz {
  ClassroomQuiz({
    required this.id,
    required this.classroomId,
    required this.title,
    required this.instructions,
    required this.teacherId,
    required this.durationMinutes,
    required this.questions,
    required this.createdAt,
    this.dueAt,
    this.isDraft = false,
  });
  final String id;
  final String classroomId;
  final String title;
  final String instructions;
  final String teacherId;
  final int durationMinutes;
  final List<QuizQuestion> questions;
  final DateTime createdAt;
  final DateTime? dueAt;
  final bool isDraft;
  int get maxScore => questions.fold(0, (sum, question) => sum + question.points);

  Map<String, dynamic> toJson() => {
        'id': id,
        'classroomId': classroomId,
        'title': title,
        'instructions': instructions,
        'teacherId': teacherId,
        'durationMinutes': durationMinutes,
        'questions': questions.map((question) => question.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'dueAt': dueAt?.toIso8601String(),
        'isDraft': isDraft,
      };
  factory ClassroomQuiz.fromJson(Map<String, dynamic> json) => ClassroomQuiz(
        id: json['id'] as String? ?? '',
        classroomId: json['classroomId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        instructions: json['instructions'] as String? ?? '',
        teacherId: json['teacherId'] as String? ?? '',
        durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 10,
        questions: (json['questions'] as List<dynamic>? ?? const [])
            .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        dueAt: DateTime.tryParse(json['dueAt'] as String? ?? ''),
        isDraft: json['isDraft'] == true,
      );
}

class QuizAttempt {
  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.answers,
    required this.score,
    required this.maxScore,
    required this.startedAt,
    required this.submittedAt,
  });
  final String id;
  final String quizId;
  final String studentId;
  final Map<int, int> answers;
  final int score;
  final int maxScore;
  final DateTime startedAt;
  final DateTime submittedAt;
  Map<String, dynamic> toJson() => {
        'id': id,
        'quizId': quizId,
        'studentId': studentId,
        'answers': answers.map((key, value) => MapEntry('$key', value)),
        'score': score,
        'maxScore': maxScore,
        'startedAt': startedAt.toIso8601String(),
        'submittedAt': submittedAt.toIso8601String(),
      };
  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
        id: json['id'] as String? ?? '',
        quizId: json['quizId'] as String? ?? '',
        studentId: json['studentId'] as String? ?? '',
        answers: (json['answers'] as Map<String, dynamic>? ?? const {})
            .map((key, value) => MapEntry(int.tryParse(key) ?? 0, (value as num).toInt())),
        score: (json['score'] as num?)?.toInt() ?? 0,
        maxScore: (json['maxScore'] as num?)?.toInt() ?? 0,
        startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ?? DateTime.now(),
        submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class ClassroomPoll {
  ClassroomPoll({
    required this.id,
    required this.classroomId,
    required this.question,
    required this.options,
    required this.createdBy,
    required this.createdAt,
    Map<String, int>? votes,
    this.isClosed = false,
  }) : votes = Map.unmodifiable(votes ?? {});
  final String id;
  final String classroomId;
  final String question;
  final List<String> options;
  final String createdBy;
  final DateTime createdAt;
  final Map<String, int> votes;
  final bool isClosed;
  ClassroomPoll copyWith({Map<String, int>? votes, bool? isClosed}) => ClassroomPoll(
        id: id,
        classroomId: classroomId,
        question: question,
        options: options,
        createdBy: createdBy,
        createdAt: createdAt,
        votes: votes ?? this.votes,
        isClosed: isClosed ?? this.isClosed,
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'classroomId': classroomId,
        'question': question,
        'options': options,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'votes': votes,
        'isClosed': isClosed,
      };
  factory ClassroomPoll.fromJson(Map<String, dynamic> json) => ClassroomPoll(
        id: json['id'] as String? ?? '',
        classroomId: json['classroomId'] as String? ?? '',
        question: json['question'] as String? ?? '',
        options: (json['options'] as List<dynamic>? ?? const []).map((value) => value.toString()).toList(),
        createdBy: json['createdBy'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        votes: (json['votes'] as Map<String, dynamic>? ?? const {})
            .map((key, value) => MapEntry(key, (value as num).toInt())),
        isClosed: json['isClosed'] == true,
      );
}

class ClassroomGroup {
  ClassroomGroup({required this.id, required this.classroomId, required this.name, required this.memberIds});
  final String id;
  final String classroomId;
  final String name;
  final List<String> memberIds;
  Map<String, dynamic> toJson() => {'id': id, 'classroomId': classroomId, 'name': name, 'memberIds': memberIds};
  factory ClassroomGroup.fromJson(Map<String, dynamic> json) => ClassroomGroup(
        id: json['id'] as String? ?? '',
        classroomId: json['classroomId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        memberIds: (json['memberIds'] as List<dynamic>? ?? const []).map((value) => value.toString()).toList(),
      );
}

class PeerReview {
  const PeerReview({required this.id, required this.assignmentId, required this.reviewerId, required this.revieweeId, required this.rating, required this.feedback, required this.createdAt});
  final String id;
  final String assignmentId;
  final String reviewerId;
  final String revieweeId;
  final int rating;
  final String feedback;
  final DateTime createdAt;
  Map<String, dynamic> toJson() => {
        'id': id,
        'assignmentId': assignmentId,
        'reviewerId': reviewerId,
        'revieweeId': revieweeId,
        'rating': rating,
        'feedback': feedback,
        'createdAt': createdAt.toIso8601String(),
      };
  factory PeerReview.fromJson(Map<String, dynamic> json) => PeerReview(
        id: json['id'] as String? ?? '',
        assignmentId: json['assignmentId'] as String? ?? '',
        reviewerId: json['reviewerId'] as String? ?? '',
        revieweeId: json['revieweeId'] as String? ?? '',
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        feedback: json['feedback'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class RecentlyViewedItem {
  const RecentlyViewedItem({required this.type, required this.id, required this.title, required this.classroomId, required this.viewedAt});
  final String type;
  final String id;
  final String title;
  final String classroomId;
  final DateTime viewedAt;
  Map<String, dynamic> toJson() => {'type': type, 'id': id, 'title': title, 'classroomId': classroomId, 'viewedAt': viewedAt.toIso8601String()};
  factory RecentlyViewedItem.fromJson(Map<String, dynamic> json) => RecentlyViewedItem(
        type: json['type'] as String? ?? '',
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        classroomId: json['classroomId'] as String? ?? '',
        viewedAt: DateTime.tryParse(json['viewedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class ClassroomActivity {
  const ClassroomActivity({required this.type, required this.title, required this.description, required this.timestamp});
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
}
