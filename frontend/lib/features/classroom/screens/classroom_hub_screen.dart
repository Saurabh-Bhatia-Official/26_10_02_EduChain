import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/instructor_provider.dart';
import '../models/classroom_model.dart';
import '../providers/classroom_provider.dart';
import '../widgets/classroom_card.dart';

/// Modern EduChain Google Classroom LMS Hub with Strict Role-Based Access Control (RBAC)
class ClassroomHubScreen extends StatefulWidget {
  const ClassroomHubScreen({
    super.key,
    this.isTeacher,
    this.userRole,
    required this.userId,
    required this.userName,
    this.userEmail,
  });

  /// True if teacher, false if student (backward compatible)
  final bool? isTeacher;

  /// Explicit role: 'student', 'teacher', 'admin'
  final String? userRole;

  final String userId;
  final String userName;
  final String? userEmail;

  @override
  State<ClassroomHubScreen> createState() => _ClassroomHubScreenState();
}

class _QuizQuestionEditor {
  final TextEditingController prompt = TextEditingController();
  final List<TextEditingController> options = List.generate(4, (_) => TextEditingController());
  int correctIndex = 0;

  void dispose() {
    prompt.dispose();
    for (final controller in options) {
      controller.dispose();
    }
  }
}

class _RubricEditor {
  _RubricEditor({String title = '', int? points}) {
    this.title.text = title;
    this.points.text = points?.toString() ?? '';
  }

  final TextEditingController title = TextEditingController();
  final TextEditingController points = TextEditingController();

  void dispose() {
    title.dispose();
    points.dispose();
  }
}

class _ClassroomHubScreenState extends State<ClassroomHubScreen> {
  ClassroomModel? _selected;
  String _query = '';
  String _subject = 'All subjects';
  bool _showArchived = false;
  int _activeDetailTab = 0; // 0: Stream, 1: Classwork, 2: Grades, 3: Attendance, 4: Materials, 5: People, 6: Analytics

  ClassroomRole get _role {
    if (widget.userRole != null && widget.userRole!.isNotEmpty) {
      return ClassroomRole.fromString(widget.userRole);
    }
    if (widget.isTeacher == true) {
      return ClassroomRole.teacher;
    }
    return ClassroomRole.student;
  }

  bool get _isTeacher => _role == ClassroomRole.teacher;
  bool get _isAdmin => _role == ClassroomRole.admin;
  bool get _isStudent => _role == ClassroomRole.student;

  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  String _materialTopic = 'All Topics';
  final Map<String, TextEditingController> _commentControllers = {};

  @override
  void dispose() {
    for (final controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ClassroomHubScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId || oldWidget.userRole != widget.userRole) {
      _selected = null;
      _query = '';
      _subject = 'All subjects';
      _showArchived = false;
      _activeDetailTab = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClassroomProvider>();
    if (!provider.isLoaded) {
      return const Material(
        color: Colors.transparent,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final classrooms = _showArchived
        ? provider.archivedForRole(_role, widget.userId)
        : provider.forRole(_role, widget.userId);
    final selectedCandidate = _selected == null ? null : provider.byId(_selected!.id);
    final selected = selectedCandidate != null && provider.canAccessClass(selectedCandidate, _role, widget.userId)
        ? selectedCandidate
        : null;

    // Portal pages render their content directly inside a Scaffold body, which
    // does not itself provide a Material ancestor. Classroom controls such as
    // TextField and DropdownButtonFormField require one to paint and interact.
    return Material(
      color: Colors.transparent,
      child: selected != null
          ? _buildClassroomDetails(selected, provider)
          : _buildClassroomsGrid(classrooms, provider),
    );
  }

  // ==========================================
  // 1. Grid of Classrooms
  // ==========================================

  Widget _buildClassroomsGrid(List<ClassroomModel> source, ClassroomProvider provider) {
    final subjects = <String>{
      'All subjects',
      ...source.map((e) => e.subject).where((s) => s.isNotEmpty),
    }.toList();

    final filtered = source.where((item) {
      final matchesQuery = '${item.name} ${item.subject} ${item.section} ${item.teacherName} ${item.code}'
          .toLowerCase()
          .contains(_query.toLowerCase());
      final matchesSubject = _subject == 'All subjects' || item.subject == _subject;
      return matchesQuery && matchesSubject;
    }).toList();

    final unreadCount = provider.unreadNotificationsCount(widget.userId);
    final pageTitle = _showArchived
        ? 'Archived Classrooms'
        : _isTeacher
            ? 'Teacher Classrooms'
            : _isAdmin
                ? 'Classroom Oversight & LMS'
                : 'My Enrolled Classrooms';
    final roleColor = _isTeacher
        ? AppColors.secondary
        : _isAdmin
            ? AppColors.adminPrimary
            : AppColors.primary;
    final pageSummary = _isTeacher
        ? 'Manage your assigned classes, create coursework, grade submissions, and track attendance.'
        : _isAdmin
            ? 'Institution-wide view across all active faculty classes, rosters, and academic performance.'
            : 'Access your coursework, turn in assignments, check grades, and view study materials.';
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(pageTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Text(_role.name.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: roleColor)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(pageSummary, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 4),
        const Text('Classroom changes are saved on this device only.', style: TextStyle(color: AppColors.textLight, fontSize: 11)),
      ],
    );
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          tooltip: 'Class Notifications',
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text('$unreadCount'),
            child: const Icon(Icons.notifications_outlined, size: 24),
          ),
          onPressed: () => _showNotificationsSheet(provider),
        ),
        if (_isTeacher || _isAdmin)
          FilledButton.icon(
            onPressed: _showArchived ? null : () => _showClassroomFormDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Classroom'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          ),
        if (_isStudent)
          FilledButton.icon(
            onPressed: _showJoinClassDialog,
            icon: const Icon(Icons.vpn_key_outlined, size: 18),
            label: const Text('Join with Code'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          ),
        if (_isTeacher || _isAdmin)
          IconButton(
            tooltip: _showArchived ? 'Show active classrooms' : 'Show archived classrooms',
            onPressed: () => setState(() {
              _showArchived = !_showArchived;
              _selected = null;
            }),
            icon: Icon(_showArchived ? Icons.inventory_2 : Icons.archive_outlined),
          ),
      ],
    );
    final searchField = TextField(
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        hintText: 'Search classes by name, subject, teacher, code...',
        prefixIcon: const Icon(Icons.search, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      ),
    );
    final subjectField = DropdownButtonFormField<String>(
      initialValue: subjects.contains(_subject) ? _subject : 'All subjects',
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      ),
      items: subjects.map((subject) => DropdownMenuItem(value: subject, child: Text(subject, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: (value) => setState(() => _subject = value ?? 'All subjects'),
    );
    final adminJoinAction = OutlinedButton.icon(
      onPressed: _showJoinClassDialog,
      icon: const Icon(Icons.add_link, size: 16),
      label: const Text('Join by Code'),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner / Action Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final icon = Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 30),
                );
                final intro = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [icon, const SizedBox(width: 16), Expanded(child: titleBlock)],
                );
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [intro, const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: actions)],
                  );
                }
                return Row(children: [Expanded(child: intro), const SizedBox(width: 12), actions]);
              },
            ),
          ),

          const SizedBox(height: 18),

          // Filters adapt to narrow portal widths.
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 640) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    searchField,
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: subjectField),
                        if (_isAdmin) ...[const SizedBox(width: 8), adminJoinAction],
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(flex: 2, child: searchField),
                  const SizedBox(width: 12),
                  Expanded(flex: 1, child: subjectField),
                  if (_isAdmin) ...[const SizedBox(width: 12), adminJoinAction],
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Classroom Cards Grid
          if (filtered.isEmpty)
            _buildEmptyState(source.isEmpty)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 1050
                    ? 3
                    : constraints.maxWidth >= 650
                    ? 2
                    : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 310,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final canManage = provider.canManageClass(item, _role, widget.userId);
                    final assignments = provider.assignmentsFor(item.id, includeDrafts: !_isStudent);
                    final attRate = provider.calculateClassAttendanceRate(item.id);

                    return ClassroomCard(
                      classroom: item,
                      role: _role,
                      canManage: canManage,
                      assignmentCount: assignments.length,
                      attendanceRate: attRate,
                      onTap: () => setState(() {
                        _selected = item;
                        _activeDetailTab = 0;
                        _materialTopic = 'All Topics';
                        provider.recordRecentlyViewed(widget.userId, 'classroom', item.id, item.name, item.id);
                      }),
                      onEdit: () => _showClassroomFormDialog(existing: item),
                      onDelete: () => _confirmDeleteClass(item),
                      onLeave: _isStudent ? () => _confirmLeaveClass(item) : null,
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool hasNoClasses) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            hasNoClasses ? Icons.school_outlined : Icons.search_off,
            size: 54,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 14),
          Text(
            hasNoClasses
                ? (_showArchived
                    ? 'No archived classrooms'
                    : _isTeacher
                    ? 'No assigned classrooms yet'
                    : _isStudent
                    ? 'You are not enrolled in any classrooms'
                    : 'No active classrooms found')
                : 'No classrooms match your query',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            hasNoClasses
                ? (_showArchived
                    ? 'Archived classrooms you manage will appear here.'
                    : _isTeacher
                    ? 'Click "Create Classroom" to configure your first course and syllabus.'
                    : 'Click "Join with Code" and enter the 6-character code provided by your instructor.')
                : 'Try adjusting your search terms or subject filter.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          if (hasNoClasses && !_showArchived && (_isTeacher || _isAdmin))
            FilledButton.icon(
              onPressed: () => _showClassroomFormDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Classroom'),
            ),
          if (hasNoClasses && _isStudent)
            FilledButton.icon(
              onPressed: _showJoinClassDialog,
              icon: const Icon(Icons.key, size: 18),
              label: const Text('Enter Classroom Code'),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. Classroom Details (Inside a Classroom)
  // ==========================================

  Widget _buildClassroomDetails(ClassroomModel classroom, ClassroomProvider provider) {
    final canManage = provider.canManageClass(classroom, _role, widget.userId);
    final canGrade = provider.canGrade(classroom, _role, widget.userId);
    final canTakeAttendance = provider.canTakeAttendance(classroom, _role, widget.userId);

    final assignments = provider.assignmentsFor(classroom.id, includeDrafts: !_isStudent);
    final materials = provider.materialsFor(classroom.id);
    final analytics = provider.getClassroomAnalytics(classroom.id);
    final studentProgress = _isStudent ? provider.getStudentProgress(classroom.id, widget.userId) : null;

    final tabs = [
      {'title': 'Activity', 'icon': Icons.timeline},
      {'title': 'Stream', 'icon': Icons.forum_outlined},
      {'title': 'Calendar', 'icon': Icons.calendar_month_outlined},
      {'title': 'Classwork', 'icon': Icons.assignment_outlined},
      {'title': 'Quizzes', 'icon': Icons.quiz_outlined},
      {'title': 'Polls', 'icon': Icons.poll_outlined},
      {'title': 'Grades', 'icon': Icons.grade_outlined},
      {'title': 'Attendance', 'icon': Icons.how_to_reg_outlined},
      {'title': 'Materials', 'icon': Icons.folder_open_outlined},
      {'title': 'People', 'icon': Icons.people_outline},
      {'title': 'Groups', 'icon': Icons.groups_outlined},
      {'title': 'Progress', 'icon': Icons.emoji_events_outlined},
      {'title': 'Analytics', 'icon': Icons.analytics_outlined},
      {'title': 'Recently Viewed', 'icon': Icons.history},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb & Action Row
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _selected = null),
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back to Classrooms',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            classroom.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            classroom.section.isNotEmpty ? classroom.section : classroom.subject,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Instructor: ${classroom.teacherName} · Code: ${classroom.code}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              // Copy Code Pill
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: classroom.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Classroom Code ${classroom.code} copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 14),
                label: Text('Code: ${classroom.code}'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              if (canManage)
                PopupMenuButton<String>(
                  tooltip: 'Classroom Settings',
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (val) {
                    if (val == 'edit') _showClassroomFormDialog(existing: classroom);
                    if (val == 'regen_code') {
                      final newCode = provider.regenerateCode(classroom.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Regenerated new class code: $newCode')),
                      );
                    }
                    if (val == 'delete') _confirmDeleteClass(classroom);
                    if (val == 'archive') {
                      provider.toggleArchive(classroom.id);
                      setState(() {
                        _showArchived = !_showArchived;
                        _selected = null;
                      });
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit Details')])),
                    PopupMenuItem(value: 'regen_code', child: Row(children: [Icon(Icons.refresh, size: 16), SizedBox(width: 8), Text('Regenerate Code')])),
                    PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: AppColors.error), SizedBox(width: 8), Text('Delete Classroom', style: TextStyle(color: AppColors.error))])),
                    PopupMenuItem(value: 'archive', child: Row(children: [Icon(Icons.archive_outlined, size: 16), SizedBox(width: 8), Text(_showArchived ? 'Restore Classroom' : 'Archive Classroom')])),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Classroom Banner Card with Metrics
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClassroomBanner(
                  index: classroom.bannerIndex,
                  height: 150,
                  bytes: classroom.bannerBytes,
                  url: classroom.bannerUrl,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  classroom.name,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${classroom.subject} · ${classroom.section}${classroom.room.isNotEmpty ? " · ${classroom.room}" : ""}',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                                ),
                                if (classroom.description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    classroom.description,
                                    style: const TextStyle(fontSize: 13, color: AppColors.textMain),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _isTeacher
                                  ? AppColors.secondary.withValues(alpha: 0.12)
                                  : _isAdmin
                                  ? AppColors.adminPrimary.withValues(alpha: 0.12)
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _isTeacher
                                  ? 'Teacher Owner'
                                  : _isAdmin
                                  ? 'Admin Access'
                                  : 'Enrolled Student',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _isTeacher
                                    ? AppColors.secondary
                                    : _isAdmin
                                    ? AppColors.adminPrimary
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 14),
                      // Stats Row
                      Wrap(
                        spacing: 24,
                        runSpacing: 10,
                        children: [
                          _buildDetailStat(Icons.people_outline, '${classroom.studentIds.length} Students', 'Enrolled Roster'),
                          _buildDetailStat(Icons.assignment_outlined, '${assignments.length} Assignments', 'Coursework'),
                          _buildDetailStat(Icons.folder_outlined, '${materials.length} Resources', 'Learning Materials'),
                          _buildDetailStat(
                            Icons.check_circle_outline,
                            '${analytics.attendanceRate.round()}% Attendance',
                            'Class Presence',
                            analytics.attendanceRate >= 75 ? AppColors.success : AppColors.warning,
                          ),
                          if (_isStudent && studentProgress != null)
                            _buildDetailStat(
                              Icons.grade_outlined,
                              studentProgress.letterGrade == 'N/A'
                                  ? 'Pending Grades'
                                  : '${studentProgress.letterGrade} (${studentProgress.averageGradePercentage.round()}%)',
                              'My Course Grade',
                              AppColors.primary,
                            )
                          else
                            _buildDetailStat(
                              Icons.insights_outlined,
                              '${analytics.averageScorePercentage.round()}% Avg Score',
                              'Class Performance',
                              AppColors.secondary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Navigation Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: List.generate(tabs.length, (idx) {
                  final isSelected = _activeDetailTab == idx;
                  final item = tabs[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => _activeDetailTab = idx),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryLight : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: 17,
                              color: isSelected ? AppColors.primary : AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected ? AppColors.primary : AppColors.textMain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Active Tab Content
          IndexedStack(
            index: _activeDetailTab,
            children: [
              _buildActivityTab(classroom, provider),
              _buildStreamTab(classroom, provider, canManage),
              _buildCalendarTab(classroom, provider),
              _buildClassworkTab(classroom, provider, canManage),
              _buildQuizzesTab(classroom, provider, canManage),
              _buildPollsTab(classroom, provider, canManage),
              _buildGradesTab(classroom, provider, canManage, canGrade),
              _buildAttendanceTab(classroom, provider, canTakeAttendance),
              _buildMaterialsTab(classroom, provider, canManage),
              _buildPeopleTab(classroom, provider, canManage),
              _buildGroupsTab(classroom, provider, canManage),
              _buildProgressTab(classroom, provider, studentProgress),
              _buildAnalyticsTab(classroom, provider, analytics, studentProgress),
              _buildRecentlyViewedTab(provider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab(ClassroomModel classroom, ClassroomProvider provider) {
    final events = provider.activitiesFor(classroom.id);
    if (events.isEmpty) return _buildSectionEmpty('Classroom activity will appear here as people post, submit, and share resources.', Icons.timeline);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Classroom Activity Feed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Updates are derived from activity saved in this device workspace.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 12),
        ...events.map((event) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(_activityIcon(event.type), color: AppColors.primary, size: 18),
                ),
                title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${event.description}\n${_dateFormat.format(event.timestamp)}', maxLines: 3, overflow: TextOverflow.ellipsis),
                isThreeLine: true,
              ),
            )),
      ],
    );
  }

  IconData _activityIcon(String type) => switch (type) {
        'assignment' => Icons.assignment_outlined,
        'quiz' => Icons.quiz_outlined,
        'poll' => Icons.poll_outlined,
        'material' => Icons.folder_open_outlined,
        'attendance' => Icons.how_to_reg_outlined,
        'submission' => Icons.upload_file_outlined,
        'grade' => Icons.grade_outlined,
        'question' => Icons.help_outline,
        _ => Icons.campaign_outlined,
      };

  Widget _buildCalendarTab(ClassroomModel classroom, ClassroomProvider provider) {
    final assignments = provider.assignmentsFor(classroom.id, includeDrafts: !_isStudent)
        .where((assignment) => assignment.dueAt != null)
        .toList()
      ..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
    if (assignments.isEmpty) return _buildSectionEmpty('Assignments with due dates will appear here.', Icons.calendar_month_outlined);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Assignment Calendar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Deadlines are shown in local time. The Notification Center creates local reminders for assignments due today or tomorrow; it does not send push alerts.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 12),
        ...assignments.map((assignment) {
          final submission = provider.submissionFor(assignment.id, widget.userId);
          final now = DateTime.now();
          final dueAt = assignment.dueAt!;
          final days = DateTime(dueAt.year, dueAt.month, dueAt.day)
              .difference(DateTime(now.year, now.month, now.day))
              .inDays;
          final status = assignment.isDraft
              ? 'Draft'
              : submission?.marks != null
                  ? 'Graded'
                  : submission != null
                      ? 'Submitted'
                      : days < 0
                          ? 'Past due'
                          : days == 0
                              ? 'Due today'
                              : 'Due in $days day${days == 1 ? '' : 's'}';
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.event, color: days < 0 && submission == null ? AppColors.error : AppColors.primary),
              title: Text(assignment.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${_dateFormat.format(assignment.dueAt!)} · $status'),
              trailing: _isStudent && submission == null && !assignment.isDraft && provider.canSubmitAssignment(assignment, classroom, widget.userId)
                  ? TextButton(onPressed: () => setState(() => _activeDetailTab = 3), child: const Text('Submit'))
                  : null,
              onTap: () {
                provider.recordRecentlyViewed(widget.userId, 'assignment', assignment.id, assignment.title, classroom.id);
                setState(() => _activeDetailTab = 3);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuizzesTab(ClassroomModel classroom, ClassroomProvider provider, bool canManage) {
    final quizzes = provider.quizzesFor(classroom.id, includeDrafts: canManage);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Text('Online Quizzes & Tests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
            if (canManage) FilledButton.icon(onPressed: () => _showQuizDialog(classroom, provider), icon: const Icon(Icons.add, size: 16), label: const Text('Create Quiz')),
          ],
        ),
        const SizedBox(height: 12),
        if (quizzes.isEmpty)
          _buildSectionEmpty('No quizzes are available in this classroom yet.', Icons.quiz_outlined)
        else
          ...quizzes.map((quiz) {
            final attempt = provider.quizAttemptFor(quiz.id, widget.userId);
            final attempts = provider.quizAttemptsFor(quiz.id);
            final canTake = provider.canTakeQuiz(quiz, widget.userId);
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(quiz.isDraft ? Icons.edit_note : Icons.quiz_outlined, color: AppColors.primary)),
                title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${quiz.questions.length} questions · ${quiz.durationMinutes} min · ${quiz.isDraft ? 'Draft' : (attempt == null ? (canTake ? 'Not attempted' : 'Closed') : 'Score ${attempt.score}/${attempt.maxScore}')}${canManage ? ' · ${attempts.length} attempts' : ''}'),
                trailing: canManage
                    ? (quiz.isDraft ? TextButton(onPressed: () => provider.publishQuiz(classroom.id, quiz.id), child: const Text('Publish')) : null)
                    : (attempt == null ? FilledButton(onPressed: canTake ? () => _showQuizAttemptDialog(quiz, provider) : null, child: const Text('Start')) : const Icon(Icons.check_circle, color: AppColors.success)),
                onTap: canManage && !quiz.isDraft && attempts.isNotEmpty
                    ? () => _showQuizResultsDialog(quiz, attempts)
                    : null,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildPollsTab(ClassroomModel classroom, ClassroomProvider provider, bool canManage) {
    final polls = provider.pollsFor(classroom.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Text('Classroom Polls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
            if (canManage) FilledButton.icon(onPressed: () => _showPollDialog(classroom, provider), icon: const Icon(Icons.add, size: 16), label: const Text('Create Poll')),
          ],
        ),
        const SizedBox(height: 12),
        if (polls.isEmpty)
          _buildSectionEmpty('Polls created by the classroom team will appear here.', Icons.poll_outlined)
        else
          ...polls.map((poll) {
            final selected = poll.votes[widget.userId];
            final totalVotes = poll.votes.length;
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [Expanded(child: Text(poll.question, style: const TextStyle(fontWeight: FontWeight.w700))), if (canManage && !poll.isClosed) IconButton(tooltip: 'Close poll', onPressed: () => provider.closePoll(classroom.id, poll.id), icon: const Icon(Icons.lock_outline))]),
                    const SizedBox(height: 8),
                    ...List.generate(poll.options.length, (index) {
                      final count = poll.votes.values.where((vote) => vote == index).length;
                      final percentage = totalVotes == 0 ? 0.0 : count / totalVotes;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: _isStudent && selected == null && !poll.isClosed
                            ? Radio<int>(value: index, groupValue: selected, onChanged: (value) { if (value != null) provider.votePoll(classroom.id, poll.id, widget.userId, value); })
                            : Icon(selected == index ? Icons.check_circle : Icons.circle_outlined, color: selected == index ? AppColors.primary : AppColors.textLight),
                        title: Text(poll.options[index]),
                        subtitle: selected != null || canManage || poll.isClosed
                            ? LinearProgressIndicator(value: percentage, minHeight: 5)
                            : null,
                        trailing: selected != null || canManage || poll.isClosed ? Text('$count') : null,
                        onTap: _isStudent && selected == null && !poll.isClosed ? () => provider.votePoll(classroom.id, poll.id, widget.userId, index) : null,
                      );
                    }),
                    Text(poll.isClosed ? 'Poll closed · $totalVotes votes' : (selected == null ? 'Select an option to vote' : 'Your vote is saved on this device · $totalVotes votes'), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildGroupsTab(ClassroomModel classroom, ClassroomProvider provider, bool canManage) {
    final groups = provider.groupsFor(classroom.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [const Expanded(child: Text('Classroom Groups', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))), if (canManage && classroom.studentIds.isNotEmpty) FilledButton.icon(onPressed: () => _showGroupDialog(classroom, provider), icon: const Icon(Icons.group_add, size: 16), label: const Text('Create Group'))]),
        const SizedBox(height: 12),
        if (groups.isEmpty)
          _buildSectionEmpty('No student groups have been created.', Icons.groups_outlined)
        else
          ...groups.map((group) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.groups_outlined, color: AppColors.primary),
                  title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(group.memberIds.join(', ')),
                  trailing: Text('${group.memberIds.length} members'),
                ),
              )),
      ],
    );
  }

  Widget _buildProgressTab(ClassroomModel classroom, ClassroomProvider provider, StudentProgressSummary? studentProgress) {
    final scoreRows = classroom.studentIds
        .map((id) => MapEntry(id, provider.getStudentProgress(classroom.id, id)))
        .toList()
      ..sort((a, b) => b.value.averageGradePercentage.compareTo(a.value.averageGradePercentage));
    final earnedBadges = <(String, IconData)>[];
    if (_isStudent && studentProgress != null) {
      if (studentProgress.submittedCount > 0) earnedBadges.add(('First submission', Icons.upload_file));
      if (studentProgress.totalAttendanceSessions > 0 && studentProgress.attendancePercentage == 100) earnedBadges.add(('Perfect attendance', Icons.event_available));
      if (provider.quizzesFor(classroom.id).any((quiz) => provider.quizAttemptFor(quiz.id, widget.userId) != null)) earnedBadges.add(('Quiz finisher', Icons.quiz));
      if (provider.peerReviewsForReviewer(widget.userId).isNotEmpty) earnedBadges.add(('Peer helper', Icons.rate_review));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_isStudent ? 'My Learning Progress' : 'Student Progress & Leaderboard', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (_isStudent && studentProgress != null) ...[
          Wrap(spacing: 12, runSpacing: 12, children: [
            _buildMetricTile('Completion', '${studentProgress.completionRate.round()}%', Icons.checklist, AppColors.primary),
            _buildMetricTile('Attendance', '${studentProgress.attendancePercentage.round()}%', Icons.event_available, AppColors.secondary),
            _buildMetricTile('Grade', studentProgress.letterGrade, Icons.grade, AppColors.success),
          ]),
          const SizedBox(height: 16),
          const Text('Achievements earned from your saved activity', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (earnedBadges.isEmpty) const Text('No badges earned yet. Submit work, attend sessions, or take a quiz to unlock one.', style: TextStyle(color: AppColors.textMuted))
          else Wrap(spacing: 8, runSpacing: 8, children: earnedBadges.map((badge) => Chip(avatar: Icon(badge.$2, size: 16, color: AppColors.primary), label: Text(badge.$1))).toList()),
        ] else ...[
          const Text('Leaderboard based on graded work saved in this classroom.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 10),
          ...scoreRows.asMap().entries.map((entry) => ListTile(
                leading: CircleAvatar(child: Text('${entry.key + 1}')),
                title: Text(entry.value.key),
                subtitle: LinearProgressIndicator(value: entry.value.value.averageGradePercentage / 100),
                trailing: Text('${entry.value.value.averageGradePercentage.round()}%'),
              )),
        ],
      ],
    );
  }

  Widget _buildRecentlyViewedTab(ClassroomProvider provider) {
    final items = provider.recentlyViewedFor(widget.userId).where((item) => item.classroomId == _selected?.id).toList();
    if (items.isEmpty) return _buildSectionEmpty('Items you open in this classroom will appear here.', Icons.history);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Recently Viewed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...items.map((item) => ListTile(
              leading: Icon(item.type == 'material' ? Icons.folder_open : (item.type == 'assignment' ? Icons.assignment_outlined : Icons.school_outlined)),
              title: Text(item.title),
              subtitle: Text('${item.type} · ${_dateFormat.format(item.viewedAt)}'),
              onTap: () => setState(() => _activeDetailTab = item.type == 'material' ? 8 : (item.type == 'assignment' ? 3 : 0)),
            )),
      ],
    );
  }

  Widget _buildDetailStat(IconData icon, String title, String subtitle, [Color? iconColor]) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor ?? AppColors.textMuted),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMain)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: Stream (Announcements & Discussions)
  // ==========================================

  Widget _buildStreamTab(ClassroomModel classroom, ClassroomProvider provider, bool canManage) {
    final posts = provider.postsFor(classroom.id);
    final assignments = provider.assignmentsFor(classroom.id, includeDrafts: !_isStudent);
    final upcoming = assignments.where((a) => !a.isDraft && a.dueAt != null && a.dueAt!.isAfter(DateTime.now())).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Stream Column
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Announce Box (Only for Teachers / Admin)
              if (canManage)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'T',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: InkWell(
                            onTap: () => _showAnnouncementDialog(classroom, provider),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.bgSurface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Text(
                                'Announce something to your class...',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Post Announcement',
                          onPressed: () => _showAnnouncementDialog(classroom, provider),
                          icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_isStudent)
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.help_outline)),
                    title: const Text('Ask the class a question', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Your question is visible to enrolled classmates and the teacher.'),
                    trailing: FilledButton(
                      onPressed: () => _showAnnouncementDialog(classroom, provider),
                      child: const Text('Ask'),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Posts List
              if (posts.isEmpty)
                _buildSectionEmpty('No announcements posted yet.', Icons.forum_outlined)
              else
                ...posts.map((post) => _buildPostCard(post, classroom, provider, canManage)),
            ],
          ),
        ),

        // Right Sidebar: Upcoming Deadlines (Desktop)
        if (MediaQuery.of(context).size.width >= 800) ...[
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.event_outlined, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Upcoming Deadlines', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (upcoming.isEmpty)
                      const Text(
                        'Woohoo, no upcoming deadlines this week!',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      )
                    else
                      ...upcoming.take(4).map((asg) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              asg.title,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Due ${_dateFormat.format(asg.dueAt!)}',
                              style: const TextStyle(fontSize: 11, color: AppColors.warning),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPostCard(ClassroomPost post, ClassroomModel classroom, ClassroomProvider provider, bool canManage) {
    final commentCtrl = _commentControllers.putIfAbsent(
      post.id,
      TextEditingController.new,
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: post.isPinned ? AppColors.primary : AppColors.border, width: post.isPinned ? 1.5 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pinned indicator
            if (post.isPinned) ...[
              Row(
                children: [
                  const Icon(Icons.push_pin, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  const Text('Pinned Announcement', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // Post Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    post.author.isNotEmpty ? post.author[0].toUpperCase() : 'U',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(post.author, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: post.authorRole == 'teacher'
                                  ? AppColors.secondary.withValues(alpha: 0.12)
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              post.authorRole.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: post.authorRole == 'teacher' ? AppColors.secondary : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _dateFormat.format(post.createdAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (canManage)
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'pin') provider.togglePinPost(classroom.id, post.id);
                      if (val == 'edit') _showAnnouncementDialog(classroom, provider, existing: post);
                      if (val == 'delete') provider.deletePost(classroom.id, post.id);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'pin',
                        child: Text(post.isPinned ? 'Unpin Announcement' : 'Pin to Top'),
                      ),
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Text Body
            SelectableText(
              post.text,
              style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textMain),
            ),
            // Attachment (if any)
            if (post.attachmentName != null || post.attachmentUrl != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.attach_file, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      post.attachmentName ?? 'Attached Resource',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            // Comments List
            if (post.comments.isNotEmpty) ...[
              ...post.comments.map((comm) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.border,
                      child: Text(
                        comm.authorName.isNotEmpty ? comm.authorName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMain),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(comm.authorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                              const SizedBox(width: 6),
                              Text(_dateFormat.format(comm.createdAt), style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                            ],
                          ),
                          Text(comm.text, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    if (canManage || comm.authorId == widget.userId)
                      IconButton(
                        icon: const Icon(Icons.close, size: 14, color: AppColors.textLight),
                        onPressed: () => provider.deleteComment(classroom.id, post.id, comm.id),
                      ),
                  ],
                ),
              )),
              const SizedBox(height: 8),
            ],
            // Add Comment Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentCtrl,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Add a class comment...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      filled: true,
                      fillColor: AppColors.bgSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.send, size: 16, color: AppColors.primary),
                  onPressed: () {
                    final text = commentCtrl.text.trim();
                    if (text.isEmpty) return;
                    provider.addComment(
                      classroom.id,
                      post.id,
                      authorId: widget.userId,
                      authorName: widget.userName,
                      authorRole: _role.name,
                      text: text,
                    );
                    commentCtrl.clear();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: Classwork (Assignments & Submissions)
  // ==========================================

  Widget _buildClassworkTab(ClassroomModel classroom, ClassroomProvider provider, bool canManage) {
    final assignments = provider.assignmentsFor(classroom.id, includeDrafts: canManage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Assignments & Coursework (${assignments.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            if (canManage)
              FilledButton.icon(
                onPressed: () => _showAssignmentDialog(classroom, provider),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Create Assignment'),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (assignments.isEmpty)
          _buildSectionEmpty('No classwork assignments assigned yet.', Icons.assignment_outlined)
        else
          ...assignments.map((asg) {
            final subs = provider.submissionsFor(asg.id);
            final mySub = provider.submissionFor(asg.id, widget.userId);
            final canTurnIn = provider.canSubmitAssignment(asg, classroom, widget.userId);

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              child: ExpansionTile(
                onExpansionChanged: (expanded) {
                  if (expanded) {
                    provider.recordRecentlyViewed(widget.userId, 'assignment', asg.id, asg.title, classroom.id);
                  }
                },
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.assignment_outlined, color: AppColors.primary, size: 20),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        asg.title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        asg.category,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  '${asg.isDraft ? 'Draft · ' : ''}${asg.maxMarks} Points · '
                  '${asg.dueAt != null ? "Due ${_dateFormat.format(asg.dueAt!)}" : "No Due Date"} · '
                  '${canManage ? "${subs.length} Turned In" : (mySub == null ? "Not Submitted" : (mySub.marks != null ? "Graded: ${mySub.marks}/${asg.maxMarks}" : "Turned In"))}',
                  style: TextStyle(
                    fontSize: 12,
                    color: mySub?.marks != null ? AppColors.success : AppColors.textMuted,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 12),
                        SelectableText(
                          asg.instructions.isNotEmpty ? asg.instructions : 'No additional instructions provided.',
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                        if (asg.attachmentName != null || asg.attachmentUrl != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.bgSurface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: InkWell(
                              onTap: () => _openResource(
                                name: asg.attachmentName,
                                url: asg.attachmentUrl,
                                bytes: asg.attachmentBytes,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.download_rounded, size: 15, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    asg.attachmentName ?? asg.attachmentUrl!,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        // Actions
                        Row(
                          children: [
                            if (_isStudent && mySub?.marks == null) ...[
                              FilledButton.icon(
                                onPressed: canTurnIn ? () => _showStudentSubmissionDialog(asg, provider) : null,
                                icon: Icon(mySub == null ? Icons.upload_file : Icons.check_circle, size: 16),
                                label: Text(
                                  !canTurnIn
                                      ? 'Submission Closed'
                                      : (mySub == null ? 'Turn In Work' : 'View / Edit Submission'),
                                ),
                              ),
                              if (mySub != null && mySub.marks == null && canTurnIn) ...[
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    provider.unsubmit(asg.id, widget.userId);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Submission unsubmitted.')),
                                    );
                                  },
                                  child: const Text('Unsubmit'),
                                ),
                              ],
                            ],
                            if (canManage) ...[
                              if (asg.isDraft)
                                OutlinedButton.icon(
                                  onPressed: () => provider.setAssignmentDraft(classroom.id, asg.id, false),
                                  icon: const Icon(Icons.publish_outlined, size: 16),
                                  label: const Text('Publish'),
                                ),
                              FilledButton.icon(
                                onPressed: () => _showTeacherSubmissionsRosterDialog(asg, classroom, provider),
                                icon: const Icon(Icons.people_outline, size: 16),
                                label: Text('Review Submissions (${subs.length})'),
                              ),
                              const Spacer(),
                              IconButton(
                                tooltip: 'Edit Assignment',
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => _showAssignmentDialog(classroom, provider, existing: asg),
                              ),
                              IconButton(
                                tooltip: 'Delete Assignment',
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                onPressed: () => _confirmDeleteAssignment(classroom, asg, provider),
                              ),
                            ],
                          ],
                        ),
                        if (_isStudent && asg.allowPeerReview && mySub != null) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => _showPeerReviewDialog(asg, classroom, provider),
                            icon: const Icon(Icons.rate_review_outlined, size: 16),
                            label: const Text('Review a classmate'),
                          ),
                          ...provider.peerReviewsFor(asg.id)
                              .where((review) => review.revieweeId == widget.userId)
                              .map((review) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.rate_review, color: AppColors.primary),
                                    title: Text('Peer feedback · ${review.rating}/5'),
                                    subtitle: Text(review.feedback),
                                  )),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // TAB 3: Grades & Gradebook
  // ==========================================

  Widget _buildGradesTab(ClassroomModel classroom, ClassroomProvider provider, bool canManage, bool canGrade) {
    final assignments = provider.assignmentsFor(classroom.id, includeDrafts: false);

    // TEACHER / ADMIN VIEW: Comprehensive Gradebook Table
    if (canManage || _isAdmin) {
      if (assignments.isEmpty) {
        return _buildSectionEmpty('Create assignments in the Classwork tab to track grades.', Icons.grade_outlined);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Class Gradebook Matrix', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(
                '${classroom.studentIds.length} Students · ${assignments.length} Assignments',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bgSurface),
              columns: [
                const DataColumn(label: Text('Student', style: TextStyle(fontWeight: FontWeight.bold))),
                ...assignments.map((asg) => DataColumn(
                  label: Text(
                    '${asg.title}\n(${asg.maxMarks} pts)',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                )),
                const DataColumn(label: Text('Overall %', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: classroom.studentIds.map((sId) {
                final studentProgress = provider.getStudentProgress(classroom.id, sId);
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primaryLight,
                            child: Text(sId.length >= 2 ? sId.substring(sId.length - 2) : 'S', style: const TextStyle(fontSize: 10)),
                          ),
                          const SizedBox(width: 8),
                          Text(sId, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    ...assignments.map((asg) {
                      final sub = provider.submissionFor(asg.id, sId);
                      final marks = sub?.marks;
                      return DataCell(
                        InkWell(
                          onTap: canGrade && sub != null
                              ? () => _showGradingDialog(asg, sub, provider)
                              : null,
                          child: Text(
                            marks != null
                                ? '$marks/${asg.maxMarks}'
                                : (sub != null ? 'Turned in' : 'â€”'),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: marks != null ? AppColors.success : (sub != null ? AppColors.primary : AppColors.textLight),
                            ),
                          ),
                        ),
                      );
                    }),
                    DataCell(
                      Text(
                        '${studentProgress.averageGradePercentage.round()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          studentProgress.letterGrade,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    // STUDENT VIEW: Personal Grade Card & History
    final myProgress = provider.getStudentProgress(classroom.id, widget.userId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Overall Grade Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  myProgress.letterGrade,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Overall Course Grade', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '${myProgress.averageGradePercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Completed ${myProgress.submittedCount} of ${myProgress.totalAssignments} assignments',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text('Assignment Grade Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),

        if (assignments.isEmpty)
          _buildSectionEmpty('No assignments found.', Icons.grade_outlined)
        else
          ...assignments.map((asg) {
            final sub = provider.submissionFor(asg.id, widget.userId);
            final marks = sub?.marks;

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: marks != null ? AppColors.success.withValues(alpha: 0.12) : AppColors.bgSurface,
                  child: Icon(
                    marks != null ? Icons.check_circle : Icons.hourglass_top,
                    color: marks != null ? AppColors.success : AppColors.textMuted,
                  ),
                ),
                title: Text(asg.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub == null
                          ? 'Not submitted'
                          : (marks != null ? 'Graded on ${_dateFormat.format(sub.gradedAt ?? DateTime.now())}' : 'Turned in · Awaiting grading'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (sub?.feedback != null && sub!.feedback!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Teacher Feedback: "${sub.feedback}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.primary)),
                    ],
                  ],
                ),
                trailing: Text(
                  marks != null ? '$marks / ${asg.maxMarks}' : 'â€” / ${asg.maxMarks}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // TAB 4: Attendance Tracking
  // ==========================================

  Widget _buildAttendanceTab(ClassroomModel classroom, ClassroomProvider provider, bool canTakeAttendance) {
    final sessions = provider.attendanceSessionsFor(classroom.id);

    // TEACHER VIEW: Take attendance, view session history, track students
    if (canTakeAttendance) {
      final overallClassRate = provider.calculateClassAttendanceRate(classroom.id);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Class Attendance Records (${sessions.length} Sessions)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showTakeAttendanceDialog(classroom, provider),
                icon: const Icon(Icons.add_task, size: 16),
                label: const Text('Take Attendance'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Overview banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _buildAttendanceMetric(
                  '${overallClassRate.round()}%',
                  'Overall Presence Rate',
                  overallClassRate >= 75 ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: 24),
                _buildAttendanceMetric('${sessions.length}', 'Sessions Conducted', AppColors.primary),
                const SizedBox(width: 24),
                _buildAttendanceMetric('${classroom.studentIds.length}', 'Active Students', AppColors.secondary),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (sessions.isEmpty)
            _buildSectionEmpty('No attendance sessions recorded yet. Click "Take Attendance" to begin.', Icons.how_to_reg_outlined)
          else
            ...sessions.map((sess) {
              int present = 0, absent = 0, late = 0;
              sess.records.forEach((_, st) {
                if (st == AttendanceStatus.present || st == AttendanceStatus.excused) present++;
                if (st == AttendanceStatus.absent) absent++;
                if (st == AttendanceStatus.late) late++;
              });

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                  ),
                  title: Text(sess.topic, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '${_dateFormat.format(sess.date)} · $present Present · $absent Absent · $late Late',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit Session',
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showTakeAttendanceDialog(classroom, provider, existing: sess),
                      ),
                      IconButton(
                        tooltip: 'Delete Session',
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        onPressed: () => provider.deleteAttendanceSession(classroom.id, sess.id),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      );
    }

    // STUDENT VIEW: Personal Attendance
    final myAttendanceRate = provider.calculateStudentAttendance(classroom.id, widget.userId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Personal Attendance Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: myAttendanceRate >= 75 ? AppColors.success.withValues(alpha: 0.12) : AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${myAttendanceRate.round()}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: myAttendanceRate >= 75 ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Attendance Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      myAttendanceRate >= 75
                          ? 'Great job! Your attendance is above the mandatory 75% institutional threshold.'
                          : 'Attention: Your attendance is below 75%. Please contact your teacher.',
                      style: TextStyle(
                        fontSize: 12,
                        color: myAttendanceRate >= 75 ? AppColors.textMuted : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Text('Attendance Session History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),

        if (sessions.isEmpty)
          _buildSectionEmpty('No attendance recorded for this class yet.', Icons.how_to_reg_outlined)
        else
          ...sessions.map((sess) {
            final myStatus = sess.records[widget.userId];
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: ListTile(
                leading: Icon(
                  myStatus == AttendanceStatus.present
                      ? Icons.check_circle
                      : (myStatus == AttendanceStatus.absent
                          ? Icons.cancel
                          : (myStatus == null ? Icons.help_outline : Icons.access_time)),
                  color: myStatus == AttendanceStatus.present
                      ? AppColors.success
                      : (myStatus == AttendanceStatus.absent
                          ? AppColors.error
                          : (myStatus == null ? AppColors.textMuted : AppColors.warning)),
                ),
                title: Text(sess.topic, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(_dateFormat.format(sess.date)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (myStatus == AttendanceStatus.present
                            ? AppColors.success
                            : (myStatus == AttendanceStatus.absent ? AppColors.error : AppColors.warning))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    myStatus?.label ?? 'Not recorded',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: myStatus == AttendanceStatus.present
                          ? AppColors.success
                          : (myStatus == AttendanceStatus.absent
                              ? AppColors.error
                              : (myStatus == null ? AppColors.textMuted : AppColors.warning)),
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAttendanceMetric(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  // ==========================================
  // TAB 5: Learning Materials
  // ==========================================

  Widget _buildMaterialsTab(ClassroomModel classroom, ClassroomProvider provider, bool canManage) {
    final topics = provider.topicsFor(classroom.id);
    final selectedTopic = topics.contains(_materialTopic) ? _materialTopic : 'All Topics';
    final materials = provider.materialsFor(classroom.id, selectedTopic);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Course Learning Materials (${materials.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (canManage)
              FilledButton.icon(
                onPressed: () => _showMaterialDialog(classroom, provider),
                icon: const Icon(Icons.upload_file, size: 16),
                label: const Text('Add Material'),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 260,
            child: DropdownButtonFormField<String>(
              initialValue: selectedTopic,
              decoration: const InputDecoration(labelText: 'Filter by topic'),
              items: topics.map((topic) => DropdownMenuItem(value: topic, child: Text(topic))).toList(),
              onChanged: (value) => setState(() => _materialTopic = value ?? 'All Topics'),
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (materials.isEmpty)
          _buildSectionEmpty('No learning materials uploaded yet.', Icons.folder_open_outlined)
        else
          ...materials.map((mat) {
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        mat.fileType == 'pdf'
                            ? Icons.picture_as_pdf
                            : (mat.fileType == 'link' ? Icons.link : Icons.description),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(mat.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.bgSurface,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(mat.topic, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(mat.description, style: const TextStyle(fontSize: 12, color: AppColors.textMain)),
                          const SizedBox(height: 6),
                          Text(
                            'Uploaded by ${mat.uploadedBy} on ${_dateFormat.format(mat.uploadedAt)}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          if (mat.attachmentName != null ||
                              (mat.linkUrl?.trim().isNotEmpty ?? false) ||
                              (mat.attachmentUrl?.trim().isNotEmpty ?? false)) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                provider.recordRecentlyViewed(widget.userId, 'material', mat.id, mat.title, classroom.id);
                                _openResource(
                                  name: mat.attachmentName,
                                  url: mat.linkUrl ?? mat.attachmentUrl,
                                  bytes: mat.attachmentBytes,
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.download_rounded, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    mat.attachmentName ?? mat.linkUrl ?? mat.attachmentUrl ?? 'View Asset',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (canManage)
                      PopupMenuButton<String>(
                        onSelected: (val) {
                          if (val == 'edit') _showMaterialDialog(classroom, provider, existing: mat);
                          if (val == 'delete') provider.deleteMaterial(classroom.id, mat.id);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // TAB 6: People (Class Roster & Enrollment)
  // ==========================================

  Widget _buildPeopleTab(ClassroomModel classroom, ClassroomProvider provider, bool canManage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Teacher Section
        const Text('Teacher & Instructors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text(classroom.teacherName.isNotEmpty ? classroom.teacherName[0].toUpperCase() : 'T'),
            ),
            title: Text(classroom.teacherName, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(classroom.teacherEmail.isNotEmpty ? classroom.teacherEmail : 'Primary Faculty Member'),
            trailing: const Chip(label: Text('Instructor', style: TextStyle(fontSize: 11))),
          ),
        ),

        const SizedBox(height: 20),

        // Students Section
        Row(
          children: [
            Text('Enrolled Classmates (${classroom.studentIds.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (canManage)
              OutlinedButton.icon(
                onPressed: () => _showAddStudentDialog(classroom, provider),
                icon: const Icon(Icons.person_add_outlined, size: 16),
                label: const Text('Add Student'),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (classroom.studentIds.isEmpty)
          _buildSectionEmpty('No students have joined yet. Share the class code to invite.', Icons.people_outline)
        else
          ...classroom.studentIds.map((sId) {
            final att = provider.calculateStudentAttendance(classroom.id, sId);
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.bgSurface,
                  child: const Icon(Icons.person, color: AppColors.textMuted),
                ),
                title: Text(sId, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('Enrolled Student · ${att.round()}% Attendance'),
                trailing: canManage
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 18),
                        tooltip: 'Remove from class',
                        onPressed: () {
                          provider.removeStudent(classroom.id, sId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Removed $sId from class.')),
                          );
                        },
                      )
                    : null,
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // TAB 7: Analytics & Progress
  // ==========================================

  Widget _buildAnalyticsTab(
    ClassroomModel classroom,
    ClassroomProvider provider,
    ClassroomAnalyticsSummary analytics,
    StudentProgressSummary? studentProgress,
  ) {
    // If Student, show their personal learning analytics
    if (_isStudent && studentProgress != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Personal Progress Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildMetricTile('Grade Letter', studentProgress.letterGrade, Icons.grade, AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricTile('Grade Avg', '${studentProgress.averageGradePercentage.round()}%', Icons.trending_up, AppColors.secondary)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricTile('Attendance', '${studentProgress.attendancePercentage.round()}%', Icons.how_to_reg, studentProgress.attendancePercentage >= 75 ? AppColors.success : AppColors.warning)),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Assignments Completion', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: studentProgress.completionRate / 100.0,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                    backgroundColor: AppColors.bgSurface,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${studentProgress.completionRate.round()}% Completed · ${studentProgress.submittedCount}/${studentProgress.totalAssignments} turned in',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Teacher / Admin Class Analytics
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Class Performance Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildMetricTile('Class Avg', '${analytics.averageScorePercentage.round()}%', Icons.analytics, AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricTile('Turn In Rate', '${analytics.submissionRate.round()}%', Icons.assignment_turned_in, AppColors.secondary)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricTile('Attendance', '${analytics.attendanceRate.round()}%', Icons.how_to_reg, analytics.attendanceRate >= 75 ? AppColors.success : AppColors.warning)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricTile('At Risk', '${analytics.atRiskStudentIds.length}', Icons.warning_amber, analytics.atRiskStudentIds.isNotEmpty ? AppColors.error : AppColors.success)),
          ],
        ),
        const SizedBox(height: 18),
        // Grade Distribution
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Score & Grade Distribution', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: analytics.gradeDistribution.entries.map((e) {
                    return Column(
                      children: [
                        Text('${e.value}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Text('Grade ${e.key}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildSectionEmpty(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textLight),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  // ==========================================
  // DIALOGS & ACTION HANDLERS
  // ==========================================

  Future<void> _showQuizDialog(ClassroomModel classroom, ClassroomProvider provider) async {
    final titleCtrl = TextEditingController();
    final instructionsCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '15');
    final editors = <_QuizQuestionEditor>[_QuizQuestionEditor()];
    DateTime? dueAt;
    Future<void> save(StateSetter setDialogState, BuildContext dialogCtx, {required bool draft}) async {
      final title = titleCtrl.text.trim();
      final duration = int.tryParse(durationCtrl.text.trim());
      final questions = <QuizQuestion>[];
      for (final editor in editors) {
        final prompt = editor.prompt.text.trim();
        final options = editor.options.map((controller) => controller.text.trim()).toList();
        if (prompt.isNotEmpty && options.every((option) => option.isNotEmpty)) {
          questions.add(QuizQuestion(prompt: prompt, options: options, correctOptionIndex: editor.correctIndex));
        }
      }
      if (title.isEmpty || duration == null || duration < 1 || questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add a title, a positive time limit, and at least one complete multiple-choice question.')),
        );
        return;
      }
      provider.addQuiz(ClassroomQuiz(
        id: 'quiz_${DateTime.now().microsecondsSinceEpoch}',
        classroomId: classroom.id,
        title: title,
        instructions: instructionsCtrl.text.trim(),
        teacherId: widget.userId,
        durationMinutes: duration,
        questions: questions,
        createdAt: DateTime.now(),
        dueAt: dueAt,
        isDraft: draft,
      ));
      Navigator.pop(dialogCtx);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(draft ? 'Quiz draft saved on this device.' : 'Quiz published to this device workspace.')),
      );
    }

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: const Text('Create Multiple-Choice Quiz'),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Quiz title *')),
                    const SizedBox(height: 8),
                    TextField(controller: instructionsCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Instructions')),
                    const SizedBox(height: 8),
                    TextField(controller: durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Time limit (minutes) *')),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dueAt ?? DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setDialogState(() => dueAt = picked);
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: Text(dueAt == null ? 'Set optional closing date' : 'Closes ${_dateFormat.format(dueAt!)}'),
                      ),
                    ),
                    ...List.generate(editors.length, (index) {
                      final editor = editors[index];
                      return Card(
                        margin: const EdgeInsets.only(top: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Question ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w700)),
                              TextField(controller: editor.prompt, decoration: const InputDecoration(labelText: 'Question *')),
                              ...List.generate(4, (optionIndex) => Row(
                                    children: [
                                      Radio<int>(value: optionIndex, groupValue: editor.correctIndex, onChanged: (value) => setDialogState(() => editor.correctIndex = value ?? 0)),
                                      Expanded(child: TextField(controller: editor.options[optionIndex], decoration: InputDecoration(labelText: 'Option ${String.fromCharCode(65 + optionIndex)} *'))),
                                    ],
                                  )),
                              Text('Choose the radio button beside the correct answer.', style: Theme.of(context).textTheme.bodySmall),
                              if (editors.length > 1)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => setDialogState(() => editors.removeAt(index).dispose()),
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text('Remove question'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                    TextButton.icon(onPressed: () => setDialogState(() => editors.add(_QuizQuestionEditor())), icon: const Icon(Icons.add), label: const Text('Add question')),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
              OutlinedButton(onPressed: () => save(setDialogState, dialogCtx, draft: true), child: const Text('Save Draft')),
              FilledButton(onPressed: () => save(setDialogState, dialogCtx, draft: false), child: const Text('Publish Quiz')),
            ],
          ),
        ),
      );
    } finally {
      titleCtrl.dispose();
      instructionsCtrl.dispose();
      durationCtrl.dispose();
      for (final editor in editors) {
        editor.dispose();
      }
    }
  }

  Future<void> _showQuizAttemptDialog(ClassroomQuiz quiz, ClassroomProvider provider) async {
    final startedAt = DateTime.now();
    var remainingSeconds = quiz.durationMinutes * 60;
    final answers = <int, int>{};
    Timer? timer;
    var isSubmitting = false;
    final attempt = await showDialog<QuizAttempt>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          timer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
            if (remainingSeconds <= 1) {
              timer.cancel();
              if (!isSubmitting && dialogCtx.mounted) {
                isSubmitting = true;
                final result = provider.submitQuiz(quiz: quiz, studentId: widget.userId, answers: answers, startedAt: startedAt);
                if (result != null) Navigator.pop(dialogCtx, result);
              }
            } else if (dialogCtx.mounted) {
              setDialogState(() => remainingSeconds--);
            }
          });
          return AlertDialog(
            title: Text(quiz.title),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')} remaining', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.error)),
                    if (quiz.instructions.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(quiz.instructions)),
                    ...List.generate(quiz.questions.length, (questionIndex) {
                      final question = quiz.questions[questionIndex];
                      return Card(
                        margin: const EdgeInsets.only(top: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${questionIndex + 1}. ${question.prompt}', style: const TextStyle(fontWeight: FontWeight.w700)),
                              ...List.generate(question.options.length, (optionIndex) => RadioListTile<int>(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    value: optionIndex,
                                    groupValue: answers[questionIndex],
                                    title: Text(question.options[optionIndex]),
                                    onChanged: (value) => setDialogState(() { if (value != null) answers[questionIndex] = value; }),
                                  )),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel attempt')),
              FilledButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        isSubmitting = true;
                        final result = provider.submitQuiz(quiz: quiz, studentId: widget.userId, answers: answers, startedAt: startedAt);
                        if (result != null) Navigator.pop(dialogCtx, result);
                      },
                child: const Text('Submit Quiz'),
              ),
            ],
          );
        },
      ),
    );
    timer?.cancel();
    if (!mounted || attempt == null) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quiz Result'),
        content: Text('You scored ${attempt.score} / ${attempt.maxScore}. Your result is saved in this device workspace.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done'))],
      ),
    );
  }

  Future<void> _showQuizResultsDialog(ClassroomQuiz quiz, List<QuizAttempt> attempts) async {
    final sorted = List<QuizAttempt>.from(attempts)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    final average = sorted.isEmpty
        ? 0.0
        : sorted
                .map((attempt) => attempt.maxScore == 0 ? 0.0 : attempt.score / attempt.maxScore * 100)
                .reduce((left, right) => left + right) /
            sorted.length;
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('${quiz.title} results'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${sorted.length} attempt${sorted.length == 1 ? '' : 's'} · class average ${average.round()}%'),
              const SizedBox(height: 10),
              SizedBox(
                height: sorted.length > 5 ? 320 : sorted.length * 64.0,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final attempt = sorted[index];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(attempt.studentId),
                      subtitle: Text(_dateFormat.format(attempt.submittedAt)),
                      trailing: Text('${attempt.score}/${attempt.maxScore}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Close'))],
      ),
    );
  }

  Future<void> _showPollDialog(ClassroomModel classroom, ClassroomProvider provider) async {
    final questionCtrl = TextEditingController();
    final optionCtrls = List.generate(4, (_) => TextEditingController());
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Create Classroom Poll'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: questionCtrl, decoration: const InputDecoration(labelText: 'Question *')),
                  ...List.generate(optionCtrls.length, (index) => TextField(controller: optionCtrls[index], decoration: InputDecoration(labelText: 'Option ${index + 1} *'))),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final question = questionCtrl.text.trim();
                final options = optionCtrls.map((controller) => controller.text.trim()).where((text) => text.isNotEmpty).toList();
                if (question.isEmpty || options.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a poll question and at least two options.')));
                  return;
                }
                provider.addPoll(ClassroomPoll(
                  id: 'poll_${DateTime.now().microsecondsSinceEpoch}',
                  classroomId: classroom.id,
                  question: question,
                  options: options,
                  createdBy: widget.userId,
                  createdAt: DateTime.now(),
                ));
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Poll saved to this device workspace.')));
              },
              child: const Text('Publish Poll'),
            ),
          ],
        ),
      );
    } finally {
      questionCtrl.dispose();
      for (final controller in optionCtrls) {
        controller.dispose();
      }
    }
  }

  Future<void> _showGroupDialog(ClassroomModel classroom, ClassroomProvider provider) async {
    final nameCtrl = TextEditingController();
    final selectedIds = <String>{};
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: const Text('Create Student Group'),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Group name *')),
                    const SizedBox(height: 8),
                    ...classroom.studentIds.map((id) => CheckboxListTile(
                          value: selectedIds.contains(id),
                          title: Text(id),
                          dense: true,
                          onChanged: (value) => setDialogState(() { if (value == true) { selectedIds.add(id); } else { selectedIds.remove(id); } }),
                        )),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  final created = provider.addGroup(classroom.id, nameCtrl.text, selectedIds.toList());
                  if (!created) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a unique group name and select enrolled students.')));
                    return;
                  }
                  Navigator.pop(dialogCtx);
                },
                child: const Text('Create Group'),
              ),
            ],
          ),
        ),
      );
    } finally {
      nameCtrl.dispose();
    }
  }

  Future<void> _showClassroomFormDialog({ClassroomModel? existing}) async {
    final instructors = _isAdmin ? context.watch<InstructorProvider>().instructors : const [];
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final subjCtrl = TextEditingController(text: existing?.subject ?? '');
    final sectCtrl = TextEditingController(text: existing?.section ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final roomCtrl = TextEditingController(text: existing?.room ?? '');
    int bannerIdx = existing?.bannerIndex ?? 0;
    Uint8List? bannerBytes = existing?.bannerBytes;
    String? selectedTeacherId;
    if (_isAdmin && existing != null) {
      for (final instructor in instructors) {
        if (instructor.instructorId == existing.teacherId || instructor.id == existing.teacherId) {
          selectedTeacherId = instructor.instructorId.isNotEmpty ? instructor.instructorId : instructor.id;
          break;
        }
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Create Classroom' : 'Edit Classroom'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Classroom Name *', hintText: 'e.g. Distributed Systems 401'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: subjCtrl,
                    decoration: const InputDecoration(labelText: 'Subject / Department *', hintText: 'e.g. Computer Science'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: sectCtrl,
                          decoration: const InputDecoration(labelText: 'Section', hintText: 'e.g. CS-4A'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: roomCtrl,
                          decoration: const InputDecoration(labelText: 'Room / Virtual Link', hintText: 'Hall 302'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Description / Syllabus Overview'),
                  ),
                  if (_isAdmin) ...[
                    const SizedBox(height: 10),
                    if (instructors.isEmpty)
                      const Text('No instructors are loaded. Load faculty in the Admin dashboard before assigning a classroom.', style: TextStyle(color: AppColors.warning, fontSize: 12))
                    else
                      DropdownButtonFormField<String>(
                        initialValue: selectedTeacherId,
                        decoration: const InputDecoration(labelText: 'Assign instructor *'),
                        hint: const Text('Select an instructor'),
                        items: instructors.map((instructor) {
                          final value = instructor.instructorId.isNotEmpty ? instructor.instructorId : instructor.id;
                          return DropdownMenuItem(value: value, child: Text('${instructor.name} · ${instructor.department}', overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: (value) => setDialogState(() => selectedTeacherId = value),
                      ),
                  ],
                  const SizedBox(height: 16),
                  const Text('Select Theme Cover Banner:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(6, (idx) {
                      return InkWell(
                        onTap: () => setDialogState(() => bannerIdx = idx),
                        child: Container(
                          width: 45,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: bannerIdx == idx ? AppColors.primary : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: ClassroomBanner(index: idx, height: 35),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || subjCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Classroom name and subject are required.')),
                  );
                  return;
                }
                final instructor = _isAdmin && selectedTeacherId != null
                    ? instructors.cast<InstructorModel?>().firstWhere(
                        (item) => item!.instructorId == selectedTeacherId || item.id == selectedTeacherId,
                        orElse: () => null,
                      )
                    : null;
                if (_isAdmin && instructor == null && existing == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a loaded instructor to assign this classroom.')));
                  return;
                }
                final provider = context.read<ClassroomProvider>();
                if (existing == null) {
                  provider.create(
                    name: nameCtrl.text.trim(),
                    subject: subjCtrl.text.trim(),
                    section: sectCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    room: roomCtrl.text.trim(),
                    teacherId: instructor?.instructorId.isNotEmpty == true ? instructor!.instructorId : (instructor?.id ?? widget.userId),
                    teacherName: instructor?.name ?? widget.userName,
                    teacherEmail: instructor?.email ?? (widget.userEmail ?? ''),
                    bannerIndex: bannerIdx,
                    bannerBytes: bannerBytes,
                  );
                } else {
                  provider.update(
                    existing.copyWith(
                      name: nameCtrl.text.trim(),
                      subject: subjCtrl.text.trim(),
                      section: sectCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      room: roomCtrl.text.trim(),
                      bannerIndex: bannerIdx,
                      bannerBytes: bannerBytes,
                      teacherId: instructor?.instructorId.isNotEmpty == true ? instructor!.instructorId : (instructor?.id ?? existing.teacherId),
                      teacherName: instructor?.name ?? existing.teacherName,
                      teacherEmail: instructor?.email ?? existing.teacherEmail,
                    ),
                  );
                }
                Navigator.pop(dialogCtx);
              },
              child: Text(existing == null ? 'Create' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showJoinClassDialog() async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Join Classroom with Code'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the 6-character code provided by your course teacher to enroll.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Class Code',
                  hintText: 'e.g. ECD401',
                  prefixIcon: Icon(Icons.key_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final code = ctrl.text.trim();
              if (code.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a classroom code to continue.')),
                );
                return;
              }
              final joined = context.read<ClassroomProvider>().join(code, widget.userId);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    joined ? 'Successfully enrolled into classroom!' : 'Invalid code or already enrolled in this class.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Join Class'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAnnouncementDialog(ClassroomModel classroom, ClassroomProvider provider, {ClassroomPost? existing}) async {
    final textCtrl = TextEditingController(text: existing?.text ?? '');
    bool isPinned = existing?.isPinned ?? false;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? (_isStudent ? 'Ask a Classroom Question' : 'Post Class Announcement') : 'Edit Announcement'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Announcement Message',
                    hintText: 'Share updates, reminders, or links with the entire class...',
                  ),
                ),
                const SizedBox(height: 10),
                if (provider.canManageClass(classroom, _role, widget.userId))
                  CheckboxListTile(
                    value: isPinned,
                    title: const Text('Pin this announcement to top of class stream', style: TextStyle(fontSize: 13)),
                    onChanged: (val) => setDialogState(() => isPinned = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final txt = textCtrl.text.trim();
                if (txt.isEmpty) return;
                if (existing == null) {
                  provider.addPost(
                    classroom.id,
                    widget.userName,
                    txt,
                    authorId: widget.userId,
                    authorRole: _role.name,
                    isPinned: isPinned,
                  );
                } else {
                  provider.updatePost(classroom.id, existing.id, txt, isPinned: isPinned);
                }
                Navigator.pop(dialogCtx);
              },
              child: Text(_isStudent && existing == null ? 'Ask Question' : 'Post'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAssignmentDialog(ClassroomModel classroom, ClassroomProvider provider, {ClassroomAssignment? existing}) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final instCtrl = TextEditingController(text: existing?.instructions ?? '');
    final marksCtrl = TextEditingController(text: '${existing?.maxMarks ?? 100}');
    String category = existing?.category ?? 'General';
    DateTime? dueAt = existing?.dueAt ?? DateTime.now().add(const Duration(days: 7));
    String? attachName = existing?.attachmentName;
    Uint8List? attachBytes = existing?.attachmentBytes;
    bool allowLateSubmission = existing?.allowLateSubmission ?? true;
    bool allowPeerReview = existing?.allowPeerReview ?? false;
    final rubricEditors = (existing?.rubric ?? const <RubricCriterion>[])
        .map((item) => _RubricEditor(title: item.title, points: item.maxPoints))
        .toList();
    bool saveDraft = existing?.isDraft ?? false;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Create Assignment' : 'Edit Assignment'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Assignment Title *')),
                  const SizedBox(height: 10),
                  TextField(controller: instCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Instructions')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: category,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: ['General', 'Homework', 'Project', 'Lab Exercise', 'Quiz', 'Exam']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) => setDialogState(() => category = val ?? 'General'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: marksCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Max Marks *'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (attachName != null) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.attach_file, color: AppColors.primary),
                      title: Text(attachName!, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setDialogState(() {
                          attachName = null;
                          attachBytes = null;
                        }),
                      ),
                    ),
                  ],
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final result = await FilePicker.pickFiles(withData: true);
                        if (result != null && result.files.isNotEmpty) {
                          setDialogState(() {
                            attachName = result.files.single.name;
                            attachBytes = result.files.single.bytes;
                          });
                        }
                      } catch (error) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not select file: $error')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.attach_file, size: 16),
                    label: Text(attachName == null ? 'Attach assignment file' : 'Replace attachment'),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: allowLateSubmission,
                    title: const Text('Allow late submissions', style: TextStyle(fontSize: 13)),
                    onChanged: (value) => setDialogState(() => allowLateSubmission = value ?? false),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: allowPeerReview,
                    title: const Text('Allow peer review after submission', style: TextStyle(fontSize: 13)),
                    onChanged: (value) => setDialogState(() => allowPeerReview = value ?? false),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(child: Text('Grading rubric (optional)', style: TextStyle(fontWeight: FontWeight.w700))),
                      TextButton.icon(onPressed: () => setDialogState(() => rubricEditors.add(_RubricEditor())), icon: const Icon(Icons.add, size: 16), label: const Text('Criterion')),
                    ],
                  ),
                  ...rubricEditors.asMap().entries.map((entry) => Row(
                        children: [
                          Expanded(child: TextField(controller: entry.value.title, decoration: InputDecoration(labelText: 'Criterion ${entry.key + 1}'))),
                          const SizedBox(width: 8),
                          SizedBox(width: 92, child: TextField(controller: entry.value.points, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Points'))),
                          IconButton(tooltip: 'Remove criterion', onPressed: () => setDialogState(() => rubricEditors.removeAt(entry.key).dispose()), icon: const Icon(Icons.close)),
                        ],
                      )),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dueAt != null ? 'Due Date: ${_dateFormat.format(dueAt!)}' : 'No Deadline',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_month, size: 16),
                        label: const Text('Change Date'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dueAt ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 3650)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setDialogState(() => dueAt = picked);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            OutlinedButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                final marks = int.tryParse(marksCtrl.text.trim());
                final rubric = <RubricCriterion>[];
                var rubricTotal = 0;
                var invalidRubric = false;
                for (final editor in rubricEditors) {
                  final criterionTitle = editor.title.text.trim();
                  final points = int.tryParse(editor.points.text.trim());
                  if (criterionTitle.isEmpty && (editor.points.text.trim().isEmpty)) continue;
                  if (criterionTitle.isEmpty || points == null || points <= 0) {
                    invalidRubric = true;
                    break;
                  }
                  rubric.add(RubricCriterion(title: criterionTitle, maxPoints: points));
                  rubricTotal += points;
                }
                if (title.isEmpty || marks == null || marks <= 0 || invalidRubric || (rubric.isNotEmpty && rubricTotal != marks)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a title and positive marks. Rubric criteria must be complete and add up to max marks.')),
                  );
                  return;
                }

                if (existing == null) {
                  provider.addAssignment(
                    classroom.id,
                    title,
                    instCtrl.text.trim(),
                    marks,
                    dueAt,
                    teacherId: widget.userId,
                    category: category,
                    attachmentName: attachName,
                    attachmentBytes: attachBytes,
                    allowLateSubmission: allowLateSubmission,
                    isDraft: true,
                    allowPeerReview: allowPeerReview,
                    rubric: rubric,
                  );
                } else {
                  provider.updateAssignment(
                    classroom.id,
                    existing.id,
                    title,
                    instCtrl.text.trim(),
                    marks,
                    dueAt,
                    category: category,
                    attachmentName: attachName,
                    attachmentBytes: attachBytes,
                    clearAttachment: attachName == null && attachBytes == null,
                    allowLateSubmission: allowLateSubmission,
                    isDraft: true,
                    allowPeerReview: allowPeerReview,
                    rubric: rubric,
                  );
                }
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Assignment draft saved on this device.')),
                );
              },
              child: const Text('Save Draft'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                final marks = int.tryParse(marksCtrl.text.trim());
                final rubric = <RubricCriterion>[];
                var rubricTotal = 0;
                for (final editor in rubricEditors) {
                  final criterionTitle = editor.title.text.trim();
                  final points = int.tryParse(editor.points.text.trim());
                  if (criterionTitle.isEmpty && editor.points.text.trim().isEmpty) continue;
                  if (criterionTitle.isEmpty || points == null || points <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete each rubric criterion with a positive point value.')));
                    return;
                  }
                  rubric.add(RubricCriterion(title: criterionTitle, maxPoints: points));
                  rubricTotal += points;
                }
                if (title.isEmpty || marks == null || marks <= 0 || (rubric.isNotEmpty && rubricTotal != marks)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a title and positive marks. Rubric points must add up to max marks.')));
                  return;
                }
                if (existing == null) {
                  provider.addAssignment(classroom.id, title, instCtrl.text.trim(), marks, dueAt,
                      teacherId: widget.userId, category: category, attachmentName: attachName, attachmentBytes: attachBytes,
                      allowLateSubmission: allowLateSubmission, isDraft: false, allowPeerReview: allowPeerReview, rubric: rubric);
                } else {
                  provider.updateAssignment(classroom.id, existing.id, title, instCtrl.text.trim(), marks, dueAt,
                      category: category, attachmentName: attachName, attachmentBytes: attachBytes,
                      clearAttachment: attachName == null && attachBytes == null, allowLateSubmission: allowLateSubmission,
                      isDraft: false, allowPeerReview: allowPeerReview, rubric: rubric);
                }
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(existing?.isDraft == true ? 'Assignment published in this device workspace.' : 'Assignment saved in this device workspace.')));
              },
              child: Text(existing == null || saveDraft ? 'Publish Assignment' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStudentSubmissionDialog(ClassroomAssignment assignment, ClassroomProvider provider) async {
    final prior = provider.submissionFor(assignment.id, widget.userId);
    final notesCtrl = TextEditingController(text: prior?.comment ?? '');
    String? attachName = prior?.attachmentName;
    Uint8List? attachBytes = prior?.attachmentBytes;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(assignment.title),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(assignment.instructions, style: const TextStyle(fontSize: 13, height: 1.4)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Submission Notes / Solution Remarks',
                      hintText: 'Enter your response or explanations...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (attachName != null) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.attach_file, color: AppColors.primary),
                      title: Text(attachName!, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setDialogState(() {
                          attachName = null;
                          attachBytes = null;
                        }),
                      ),
                    ),
                  ],
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final picked = await FilePicker.pickFiles(withData: true);
                        if (picked != null && picked.files.isNotEmpty) {
                          setDialogState(() {
                            attachName = picked.files.single.name;
                            attachBytes = picked.files.single.bytes;
                          });
                        }
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: Text(attachName == null ? 'Attach Document / Solution' : 'Replace File'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final saved = provider.submit(
                  assignment.id,
                  widget.userId,
                  notesCtrl.text.trim(),
                  classroomId: assignment.classroomId,
                  studentName: widget.userName,
                  studentRoll: widget.userId,
                  attachmentName: attachName,
                  attachmentBytes: attachBytes,
                );
                if (!saved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This work could not be submitted. Check the deadline and try again.')),
                  );
                  return;
                }
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Assignment saved on this device and available to the classroom teacher here.')),
                );
              },
              child: const Text('Turn In Work'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPeerReviewDialog(ClassroomAssignment assignment, ClassroomModel classroom, ClassroomProvider provider) async {
    final feedbackCtrl = TextEditingController();
    final alreadyReviewed = provider.peerReviewsFor(assignment.id)
        .where((review) => review.reviewerId == widget.userId)
        .map((review) => review.revieweeId)
        .toSet();
    final candidates = classroom.studentIds
        .where((id) => id != widget.userId && provider.submissionFor(assignment.id, id) != null && !alreadyReviewed.contains(id))
        .toList();
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('There are no eligible classmate submissions left to review.')));
      feedbackCtrl.dispose();
      return;
    }
    var revieweeId = candidates.first;
    var rating = 5;
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text('Peer Review · ${assignment.title}'),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: revieweeId,
                    decoration: const InputDecoration(labelText: 'Classmate submission'),
                    items: candidates.map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
                    onChanged: (value) => setDialogState(() => revieweeId = value ?? revieweeId),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: rating,
                    decoration: const InputDecoration(labelText: 'Rating'),
                    items: List.generate(5, (index) => DropdownMenuItem(value: index + 1, child: Text('${index + 1} / 5'))),
                    onChanged: (value) => setDialogState(() => rating = value ?? 5),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: feedbackCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Constructive feedback *')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  final saved = provider.submitPeerReview(
                    assignment: assignment,
                    reviewerId: widget.userId,
                    revieweeId: revieweeId,
                    rating: rating,
                    feedback: feedbackCtrl.text,
                  );
                  if (!saved) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The review needs feedback and a valid submitted classmate.')));
                    return;
                  }
                  Navigator.pop(dialogCtx);
                },
                child: const Text('Send Review'),
              ),
            ],
          ),
        ),
      );
    } finally {
      feedbackCtrl.dispose();
    }
  }

  Future<void> _showTeacherSubmissionsRosterDialog(
    ClassroomAssignment assignment,
    ClassroomModel classroom,
    ClassroomProvider provider,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Submissions for ${assignment.title}'),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: classroom.studentIds.map((sId) {
                final sub = provider.submissionFor(assignment.id, sId);
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
                  child: ListTile(
                    leading: Icon(
                      sub != null ? Icons.check_circle : Icons.pending_outlined,
                      color: sub != null ? (sub.marks != null ? AppColors.success : AppColors.primary) : AppColors.textLight,
                    ),
                    title: Text(sId, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      sub == null
                          ? 'Missing / Not submitted'
                          : '${sub.attachmentName ?? "Text solution"} · ${sub.marks != null ? "Score: ${sub.marks}/${assignment.maxMarks}" : "Turned in"}',
                    ),
                    trailing: sub != null
                        ? FilledButton(
                            onPressed: () {
                              Navigator.pop(dialogCtx);
                              _showGradingDialog(assignment, sub, provider);
                            },
                            child: Text(sub.marks == null ? 'Grade' : 'Edit Grade'),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _showGradingDialog(ClassroomAssignment assignment, ClassroomSubmission submission, ClassroomProvider provider) async {
    final marksCtrl = TextEditingController(text: submission.marks != null ? '${submission.marks}' : '');
    final feedbackCtrl = TextEditingController(text: submission.feedback ?? '');
    final rubricCtrls = assignment.rubric.map((criterion) => TextEditingController(
          text: submission.gradeHistory.isEmpty ? '' : '${submission.gradeHistory.last.rubricScores[criterion.title] ?? ''}',
        )).toList();
    try {
      await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Grade: ${submission.studentName.isNotEmpty ? submission.studentName : submission.studentId}'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text('Assignment: ${assignment.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (submission.attachmentName != null || submission.attachmentUrl != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _openResource(
                    name: submission.attachmentName,
                    url: submission.attachmentUrl,
                    bytes: submission.attachmentBytes,
                  ),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: Text(submission.attachmentName ?? 'Open submitted file'),
                ),
              ],
              if (submission.comment.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Student Solution Remarks: "${submission.comment}"', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
              const SizedBox(height: 14),
              if (assignment.rubric.isEmpty)
                TextField(
                  controller: marksCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Marks Awarded (out of ${assignment.maxMarks}) *'),
                )
              else ...[
                Text('Rubric · total ${assignment.maxMarks} marks', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...List.generate(assignment.rubric.length, (index) => TextField(
                      controller: rubricCtrls[index],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: '${assignment.rubric[index].title} (0-${assignment.rubric[index].maxPoints})'),
                    )),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: feedbackCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Qualitative Feedback', hintText: 'Enter praise, corrections, and improvement notes...'),
              ),
              if (submission.gradeHistory.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Grading History', style: TextStyle(fontWeight: FontWeight.w700)),
                ...submission.gradeHistory.map((record) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('${record.marks}/${assignment.maxMarks} · ${_dateFormat.format(record.gradedAt)}${record.gradedBy.isEmpty ? '' : ' · ${record.gradedBy}'}${record.feedback.isEmpty ? '' : '\n${record.feedback}'}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              int? marks = int.tryParse(marksCtrl.text.trim());
              final rubricScores = <String, int>{};
              if (assignment.rubric.isNotEmpty) {
                var rubricTotal = 0;
                for (var index = 0; index < assignment.rubric.length; index++) {
                  final criterion = assignment.rubric[index];
                  final score = int.tryParse(rubricCtrls[index].text.trim());
                  if (score == null || score < 0 || score > criterion.maxPoints) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enter a score from 0 to ${criterion.maxPoints} for ${criterion.title}.')));
                    return;
                  }
                  rubricScores[criterion.title] = score;
                  rubricTotal += score;
                }
                marks = rubricTotal;
              }
              if (marks == null || marks < 0 || marks > assignment.maxMarks) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter marks between 0 and ${assignment.maxMarks}')));
                return;
              }
              provider.grade(assignment.id, submission.studentId, marks, feedbackCtrl.text.trim(), gradedBy: widget.userName, rubricScores: rubricScores);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grade saved on this device and shown to the student.')));
            },
            child: const Text('Return Grade'),
          ),
        ],
      ),
      );
    } finally {
      marksCtrl.dispose();
      feedbackCtrl.dispose();
      for (final controller in rubricCtrls) {
        controller.dispose();
      }
    }
  }

  Future<void> _showTakeAttendanceDialog(ClassroomModel classroom, ClassroomProvider provider, {ClassroomAttendanceSession? existing}) async {
    final topicCtrl = TextEditingController(text: existing?.topic ?? 'Lecture Session');
    DateTime date = existing?.date ?? DateTime.now();
    final records = Map<String, AttendanceStatus>.from(existing?.records ?? {});

    // Default all students to present if new
    if (existing == null) {
      for (final sId in classroom.studentIds) {
        records[sId] = AttendanceStatus.present;
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Record Class Attendance' : 'Edit Attendance Session'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: topicCtrl, decoration: const InputDecoration(labelText: 'Session Topic / Lecture Title *')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Session Date: ${_dateFormat.format(date)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_month, size: 16),
                        label: const Text('Change'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime.now().subtract(const Duration(days: 90)),
                            lastDate: DateTime.now().add(const Duration(days: 7)),
                          );
                          if (picked != null) setDialogState(() => date = picked);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Quick "Mark All Present" button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('Mark All Present'),
                      onPressed: () {
                        setDialogState(() {
                          for (final sId in classroom.studentIds) {
                            records[sId] = AttendanceStatus.present;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...classroom.studentIds.map((sId) {
                    final current = records[sId] ?? AttendanceStatus.present;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(sId, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                          SegmentedButton<AttendanceStatus>(
                            segments: const [
                              ButtonSegment(value: AttendanceStatus.present, label: Text('P')),
                              ButtonSegment(value: AttendanceStatus.absent, label: Text('A')),
                              ButtonSegment(value: AttendanceStatus.late, label: Text('L')),
                              ButtonSegment(value: AttendanceStatus.excused, label: Text('E')),
                            ],
                            selected: {current},
                            onSelectionChanged: (val) => setDialogState(() => records[sId] = val.first),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (existing == null) {
                  provider.recordAttendanceSession(
                    classroomId: classroom.id,
                    date: date,
                    topic: topicCtrl.text.trim().isNotEmpty ? topicCtrl.text.trim() : 'Lecture Session',
                    takenByTeacherId: widget.userId,
                    records: records,
                  );
                } else {
                  provider.updateAttendanceSession(
                    existing.copyWith(date: date, topic: topicCtrl.text.trim(), records: records),
                  );
                }
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attendance recorded successfully!')),
                );
              },
              child: const Text('Save Attendance'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMaterialDialog(ClassroomModel classroom, ClassroomProvider provider, {ClassroomMaterial? existing}) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final topicCtrl = TextEditingController(text: existing?.topic ?? 'General Resources');
    final linkCtrl = TextEditingController(text: existing?.linkUrl ?? '');
    String? attachName = existing?.attachmentName;
    Uint8List? attachBytes = existing?.attachmentBytes;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Upload Learning Material' : 'Edit Material'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title *')),
                  const SizedBox(height: 10),
                  TextField(controller: topicCtrl, decoration: const InputDecoration(labelText: 'Module / Topic Grouping *')),
                  const SizedBox(height: 10),
                  TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
                  const SizedBox(height: 10),
                  TextField(controller: linkCtrl, decoration: const InputDecoration(labelText: 'External URL (Optional)')),
                  const SizedBox(height: 12),
                  if (attachName != null) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.attach_file, color: AppColors.primary),
                      title: Text(attachName!),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setDialogState(() {
                          attachName = null;
                          attachBytes = null;
                        }),
                      ),
                    ),
                  ],
                  OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: Text(attachName == null ? 'Attach PDF or Slides' : 'Replace File'),
                    onPressed: () async {
                      try {
                        final picked = await FilePicker.pickFiles(withData: true);
                        if (picked != null && picked.files.isNotEmpty) {
                          setDialogState(() {
                            attachName = picked.files.single.name;
                            attachBytes = picked.files.single.bytes;
                          });
                        }
                      } catch (error) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not select file: $error')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                final link = linkCtrl.text.trim();
                final parsedLink = link.isEmpty ? null : Uri.tryParse(link);
                final validLink = link.isEmpty ||
                    (parsedLink != null &&
                        (parsedLink.scheme == 'http' || parsedLink.scheme == 'https') &&
                        parsedLink.host.isNotEmpty);
                if (title.isEmpty || topicCtrl.text.trim().isEmpty || !validLink) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a material title and topic, and use a valid HTTP or HTTPS link.')),
                  );
                  return;
                }
                if (existing == null) {
                  provider.addMaterial(
                    classroomId: classroom.id,
                    title: title,
                    description: descCtrl.text.trim(),
                    topic: topicCtrl.text.trim(),
                    uploadedBy: widget.userName,
                    attachmentName: attachName,
                    attachmentBytes: attachBytes,
                    linkUrl: linkCtrl.text.trim(),
                    fileType: _resourceFileType(attachName),
                  );
                } else {
                  provider.updateMaterial(
                    existing.copyWith(
                      title: title,
                      description: descCtrl.text.trim(),
                      topic: topicCtrl.text.trim(),
                      attachmentName: attachName,
                      attachmentBytes: attachBytes,
                      clearAttachment: attachName == null && attachBytes == null,
                      linkUrl: linkCtrl.text.trim(),
                      fileType: _resourceFileType(attachName),
                    ),
                  );
                }
                Navigator.pop(dialogCtx);
              },
              child: const Text('Save Material'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddStudentDialog(ClassroomModel classroom, ClassroomProvider provider) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Enroll Student'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter student ID or roll number to enroll them into this class:', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(labelText: 'Student Roll / ID', hintText: 'e.g. STU-2025-005'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final sId = ctrl.text.trim();
              if (sId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a student ID or roll number.')),
                );
                return;
              }
              final enrolled = provider.enrollStudent(classroom.id, sId);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(enrolled ? 'Enrolled student $sId.' : '$sId is already enrolled or the class no longer exists.')),
              );
            },
            child: const Text('Enroll'),
          ),
        ],
      ),
    );
  }

  String _resourceFileType(String? fileName) {
    final extension = fileName?.split('.').last.toLowerCase() ?? '';
    if (extension == 'pdf') return 'pdf';
    if (extension == 'ppt' || extension == 'pptx' || extension == 'key') return 'slides';
    if (extension == 'zip' || extension == 'dart' || extension == 'java' || extension == 'cpp') return 'code';
    return fileName == null ? 'link' : 'document';
  }

  Future<void> _openResource({String? name, String? url, Uint8List? bytes}) async {
    try {
      final cleanUrl = url?.trim() ?? '';
      if (cleanUrl.isNotEmpty) {
        final uri = Uri.tryParse(cleanUrl);
        if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
          throw const FormatException('Only valid HTTP or HTTPS links can be opened.');
        }
        final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!opened) throw Exception('The link could not be opened.');
        return;
      }

      if (bytes != null && bytes.isNotEmpty) {
        await FilePicker.saveFile(
          dialogTitle: 'Save classroom resource',
          fileName: name ?? 'classroom-resource',
          bytes: bytes,
        );
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This resource has no downloadable file or valid link.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open resource: $error')),
        );
      }
    }
  }

  Future<void> _showNotificationsSheet(ClassroomProvider provider) async {
    provider.refreshDeadlineNotifications(widget.userId);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final notifications = provider.notificationsFor(widget.userId);
          return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text('Classroom Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      provider.markAllNotificationsAsRead(widget.userId);
                      setSheetState(() {});
                    },
                    child: const Text('Mark all as read'),
                  ),
                ],
              ),
              const Divider(color: AppColors.border),
              const SizedBox(height: 8),
              if (notifications.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No notifications yet!')))
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, idx) {
                      final notif = notifications[idx];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: notif.isRead ? AppColors.bgSurface : AppColors.primaryLight,
                          child: Icon(
                            notif.type == 'grade'
                                ? Icons.grade
                                : (notif.type == 'assignment'
                                    ? Icons.assignment
                                    : (notif.type == 'attendance'
                                        ? Icons.event_available
                                        : (notif.type == 'material' ? Icons.folder_open : Icons.campaign))),
                            color: notif.isRead ? AppColors.textMuted : AppColors.primary,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          notif.title,
                          style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Text(
                          '${notif.classroomName} · ${notif.message}\n${_dateFormat.format(notif.timestamp)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: notif.isRead
                            ? null
                            : const Icon(Icons.circle, size: 8, color: AppColors.primary),
                        onTap: () {
                          provider.markNotificationAsRead(notif.id, widget.userId);
                          setSheetState(() {});
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteClass(ClassroomModel classroom) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Classroom?'),
        content: Text('Are you sure you want to permanently delete "${classroom.name}" and all associated coursework?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<ClassroomProvider>().delete(classroom.id);
      setState(() => _selected = null);
    }
  }

  Future<void> _confirmLeaveClass(ClassroomModel classroom) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Leave Classroom?'),
        content: Text('Are you sure you want to leave "${classroom.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Leave Class'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<ClassroomProvider>().leaveClass(classroom.id, widget.userId);
      setState(() => _selected = null);
    }
  }

  Future<void> _confirmDeleteAssignment(ClassroomModel classroom, ClassroomAssignment assignment, ClassroomProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Assignment?'),
        content: Text('Delete "${assignment.title}" and all student submissions?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      provider.deleteAssignment(classroom.id, assignment.id);
    }
  }
}
