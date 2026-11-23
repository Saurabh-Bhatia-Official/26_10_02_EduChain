import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../services/api_service.dart';
import 'assignment_view_screen.dart';

class ClassroomDetailScreen extends StatefulWidget {
  final String classroomId;
  final String userRole;

  const ClassroomDetailScreen({
    super.key,
    required this.classroomId,
    required this.userRole,
  });

  @override
  State<ClassroomDetailScreen> createState() => _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends State<ClassroomDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _classroom;
  List<Map<String, dynamic>> _assignments = [];
  List<Map<String, dynamic>> _liveClasses = [];
  List<Map<String, dynamic>> _streamPosts = [];
  Map<String, dynamic>? _members;
  Map<String, dynamic>? _gradebook;
  bool _loading = true;
  String? _error;

  final TextEditingController _announcementController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadClassroom();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _announcementController.dispose();
    super.dispose();
  }

  Future<void> _loadClassroom() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getClassroomDetails(widget.classroomId),
        _apiService.getAssignments(widget.classroomId),
        _apiService.getClassroomLiveClasses(widget.classroomId),
        _apiService.getClassroomComments(widget.classroomId, targetType: 'STREAM_POST'),
        _apiService.getClassroomMembers(widget.classroomId),
      ]);

      if (!mounted) return;
      setState(() {
        _classroom = results[0] as Map<String, dynamic>;
        _assignments = results[1] as List<Map<String, dynamic>>;
        _liveClasses = results[2] as List<Map<String, dynamic>>;
        _streamPosts = results[3] as List<Map<String, dynamic>>;
        _members = results[4] as Map<String, dynamic>;
        _loading = false;
      });

      // If teacher/admin, also load gradebook
      if (widget.userRole == 'teacher' || widget.userRole == 'admin') {
        final gb = await _apiService.getClassGradebook(widget.classroomId);
        if (mounted) {
          setState(() => _gradebook = gb);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _postAnnouncement() async {
    final text = _announcementController.text.trim();
    if (text.isEmpty) return;

    try {
      await _apiService.addClassroomComment(widget.classroomId, {
        'content': text,
        'targetType': 'STREAM_POST',
      });
      _announcementController.clear();
      final posts = await _apiService.getClassroomComments(widget.classroomId, targetType: 'STREAM_POST');
      if (!mounted) return;
      setState(() => _streamPosts = posts);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement posted!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  void _showScheduleMeetDialog([Map<String, dynamic>? meeting]) {
    DateTime parseTime(dynamic value, DateTime fallback) =>
        DateTime.tryParse(value?.toString() ?? '') ?? fallback;
    final now = DateTime.now();
    final titleController = TextEditingController(
      text: meeting?['title']?.toString() ?? '',
    );
    final descController = TextEditingController(
      text: meeting?['description']?.toString() ?? '',
    );
    final linkController = TextEditingController(
      text: meeting?['meetLink']?.toString() ?? '',
    );
    var startDate = parseTime(meeting?['startTime'], now.add(const Duration(hours: 1)));
    var endDate = parseTime(meeting?['endTime'], now.add(const Duration(hours: 2)));
    var saving = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          String formatDateTime(DateTime value) =>
              '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}  ${TimeOfDay.fromDateTime(value).format(ctx)}';

          Future<void> chooseDate(bool isStart) async {
            final current = isStart ? startDate : endDate;
            final date = await showDatePicker(
              context: ctx,
              initialDate: current,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 5),
            );
            if (date == null || !ctx.mounted) return;
            final updated = DateTime(date.year, date.month, date.day, current.hour, current.minute);
            setDialogState(() {
              if (isStart) {
                startDate = updated;
                if (!endDate.isAfter(startDate)) endDate = startDate.add(const Duration(hours: 1));
              } else {
                endDate = updated;
              }
            });
          }

          Future<void> chooseTime(bool isStart) async {
            final current = isStart ? startDate : endDate;
            final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(current));
            if (time == null || !ctx.mounted) return;
            final updated = DateTime(current.year, current.month, current.day, time.hour, time.minute);
            setDialogState(() {
              if (isStart) {
                startDate = updated;
                if (!endDate.isAfter(startDate)) endDate = startDate.add(const Duration(hours: 1));
              } else {
                endDate = updated;
              }
            });
          }

          Widget timePickerRow(String label, DateTime value, bool isStart) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(children: [
                  Expanded(child: Text('$label: ${formatDateTime(value)}', style: const TextStyle(fontSize: 13))),
                  IconButton(tooltip: 'Choose date', onPressed: () => chooseDate(isStart), icon: const Icon(Icons.calendar_month_outlined)),
                  IconButton(tooltip: 'Choose time', onPressed: () => chooseTime(isStart), icon: const Icon(Icons.schedule)),
                ]),
              );

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(children: [
              const Icon(Icons.video_call, color: Colors.green),
              const SizedBox(width: 10),
              Text(meeting == null ? 'Schedule Google Meet' : 'Edit Google Meet', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ]),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Class / session name', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  Text('Subject: ${_classroom?['subject']?.toString().isNotEmpty == true ? _classroom!['subject'] : 'Not set for this class'}', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 12),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: 'Topic / agenda', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: linkController, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Google Meet URL', hintText: 'https://meet.google.com/abc-defg-hij', border: OutlineInputBorder())),
                  Align(alignment: Alignment.centerRight, child: TextButton.icon(
                    onPressed: () => launchUrl(Uri.parse('https://meet.google.com/new'), mode: LaunchMode.externalApplication),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Create a link in Google Meet'),
                  )),
                  const Text('Create the meeting in Google Meet, then paste its real link here. Only active class members will see it.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  timePickerRow('Starts', startDate, true),
                  timePickerRow('Ends', endDate, false),
                ]),
              ),
            ),
            actions: [
              TextButton(onPressed: saving ? null : () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: saving ? null : () async {
                  final link = linkController.text.trim();
                  final uri = Uri.tryParse(link);
                  if (titleController.text.trim().isEmpty ||
                      uri == null ||
                      uri.scheme.toLowerCase() != 'https' ||
                      uri.host.toLowerCase() != 'meet.google.com' ||
                      uri.hasPort ||
                      uri.userInfo.isNotEmpty ||
                      uri.path.length <= 1) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a class name and a valid https://meet.google.com link.')));
                    return;
                  }
                  if (!endDate.isAfter(startDate)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End time must be after start time.')));
                    return;
                  }
                  setDialogState(() => saving = true);
                  final data = {
                    'title': titleController.text.trim(),
                    'description': descController.text.trim(),
                    'meetLink': link,
                    'startTime': startDate.toIso8601String(),
                    'endTime': endDate.toIso8601String(),
                  };
                  try {
                    if (meeting == null) {
                      await _apiService.scheduleLiveClass(widget.classroomId, data);
                    } else {
                      await _apiService.updateLiveClass(meeting['id'].toString(), data);
                    }
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(meeting == null ? 'Google Meet scheduled.' : 'Google Meet updated.'), backgroundColor: Colors.green));
                    _loadClassroom();
                  } catch (e) {
                    if (ctx.mounted) setDialogState(() => saving = false);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red));
                  }
                },
                child: Text(saving ? 'Saving…' : meeting == null ? 'Schedule Meet' : 'Save Changes'),
              ),
            ],
          );
        },
      ),
    ).whenComplete(() {
      titleController.dispose();
      descController.dispose();
      linkController.dispose();
    });
  }

  Future<void> _deleteLiveClass(Map<String, dynamic> meeting) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete scheduled Meet?'),
        content: Text('“${meeting['title'] ?? 'This meeting'}” will be removed for all students in this class.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _apiService.deleteLiveClass(meeting['id'].toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meeting deleted.')));
      _loadClassroom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red));
    }
  }

  void _showCreateAssignmentDialog() {
    final titleController = TextEditingController();
    final instructionsController = TextEditingController();
    final pointsController = TextEditingController(text: '100');
    final topicController = TextEditingController(text: _classroom?['subject']?.toString() ?? 'General');
    final attachments = <Map<String, dynamic>>[];
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    bool allowLate = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.assignment_outlined, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Upload Assignment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title (required)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: instructionsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Instructions & Grading Rubric',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Class: ${_classroom?['name'] ?? 'Class'}  •  Subject: ${_classroom?['subject']?.toString().isNotEmpty == true ? _classroom!['subject'] : 'Not set'}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: pointsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Points Possible',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: topicController,
                          decoration: InputDecoration(
                            labelText: 'Subject / Topic',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text('Due date: ${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}'),
                    onPressed: () async {
                      final selected = await showDatePicker(
                        context: ctx,
                        initialDate: dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (selected != null && ctx.mounted) setDlgState(() => dueDate = DateTime(selected.year, selected.month, selected.day, 23, 59));
                    },
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: Text(attachments.isEmpty ? 'Choose assignment files' : 'Add more files (${attachments.length} selected)'),
                    onPressed: () async {
                      final picked = await FilePicker.platform.pickFiles(withData: true, allowMultiple: true);
                      if (picked == null) return;
                      try {
                        for (final file in picked.files) {
                          final bytes = file.bytes;
                          if (bytes == null) throw Exception('Could not read ${file.name}.');
                          final uploaded = await _apiService.uploadAssignmentAttachment(
                            classroomId: widget.classroomId,
                            purpose: 'ASSIGNMENT',
                            bytes: bytes,
                            fileName: file.name,
                          );
                          attachments.add(uploaded);
                        }
                        if (ctx.mounted) setDlgState(() {});
                      } catch (e) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red));
                      }
                    },
                  ),
                  if (attachments.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    ...attachments.map((file) => Text('• ${file['fileName']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
                  ],
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Allow Late Submissions', style: TextStyle(fontSize: 13)),
                    value: allowLate,
                    onChanged: (val) => setDlgState(() => allowLate = val ?? true),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final title = titleController.text.trim();
                final points = int.tryParse(pointsController.text) ?? 100;
                if (title.isEmpty || points <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a title and a positive points value.')));
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await _apiService.createAssignment(widget.classroomId, {
                    'title': title,
                    'instructions': instructionsController.text.trim(),
                    'pointsPossible': points,
                    'topic': topicController.text.trim(),
                    'allowLateSubmissions': allowLate,
                    'dueDate': dueDate.toIso8601String(),
                    'attachments': attachments,
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Assignment created!'), backgroundColor: Colors.green),
                  );
                  _loadClassroom();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Upload Assignment'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGradeDialog(Map<String, dynamic> submission) {
    final scoreController = TextEditingController(text: submission['grade']?['score']?.toString() ?? '100');
    final feedbackController = TextEditingController(text: submission['grade']?['feedback']?.toString() ?? '');
    bool returnToStudent = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Grade: ${submission['studentName']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Submission Text:\n${submission['submissionText'] ?? 'None'}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 16),
                TextField(
                  controller: scoreController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Score',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: feedbackController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Teacher Feedback',
                    hintText: 'Great work on...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Return Grade to Student', style: TextStyle(fontSize: 13)),
                  value: returnToStudent,
                  onChanged: (val) => setDlgState(() => returnToStudent = val ?? true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await _apiService.gradeSubmission(submission['id'].toString(), {
                    'score': double.tryParse(scoreController.text) ?? 0.0,
                    'feedback': feedbackController.text.trim(),
                    'isReturned': returnToStudent,
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grade saved and returned!'), backgroundColor: Colors.green),
                  );
                  _loadClassroom();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Save Grade'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _classroom == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Classroom')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(_error ?? 'Classroom not found', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadClassroom, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final hexColor = _classroom!['themeColor'] as String? ?? '#1967d2';
    final themeColor = Color(int.parse(hexColor.replaceFirst('#', '0xff')));
    final invitationCode = _classroom!['invitationCode'] as String? ?? '';
    final myRole = _classroom!['myRole']?.toString().toUpperCase();
    final isTeacher = widget.userRole == 'teacher' || widget.userRole == 'admin' || myRole == 'TEACHER' || myRole == 'CO_TEACHER';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          _classroom!['name'] ?? 'Classroom',
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadClassroom),
          if (isTeacher)
            IconButton(
              icon: const Icon(Icons.video_call, color: Colors.green),
              tooltip: 'Schedule Google Meet',
              onPressed: _showScheduleMeetDialog,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: themeColor,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: themeColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Stream'),
            Tab(text: 'Classwork'),
            Tab(text: 'People'),
            Tab(text: 'Grades'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStreamTab(themeColor, invitationCode, isTeacher),
          _buildClassworkTab(themeColor, isTeacher),
          _buildPeopleTab(themeColor, isTeacher),
          _buildGradesTab(themeColor, isTeacher),
        ],
      ),
    );
  }

  Widget _buildStreamTab(Color themeColor, String invitationCode, bool isTeacher) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Card (Google Classroom Top Banner)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _classroom!['name'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_classroom!['subject'] ?? ''} ${_classroom!['section'] != null && _classroom!['section'].toString().isNotEmpty ? '• ${_classroom!['section']}' : ''}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Instructor: ${_classroom!['creatorName'] ?? ''}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (invitationCode.isNotEmpty)
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: invitationCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Class Code $invitationCode copied!')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const Text('Class Code', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(invitationCode, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: themeColor)),
                              const SizedBox(width: 6),
                              Icon(Icons.copy, size: 14, color: themeColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_liveClasses.isNotEmpty) ...[
            ..._liveClasses.map((lc) {
              final isLive = lc['isLiveNow'] == true;
              final start = DateTime.tryParse(lc['startTime']?.toString() ?? '')?.toLocal();
              final end = DateTime.tryParse(lc['endTime']?.toString() ?? '')?.toLocal();
              final dateTime = start == null ? '' : '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}  ${TimeOfDay.fromDateTime(start).format(context)}${end == null ? '' : ' – ${TimeOfDay.fromDateTime(end).format(context)}'}';
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: isLive ? Colors.green.shade50 : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12), border: Border.all(color: isLive ? Colors.green : const Color(0xFFE2E8F0))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.video_camera_front, color: isLive ? Colors.green : AppColors.primary, size: 26),
                    const SizedBox(width: 12),
                    Expanded(child: Text(lc['title']?.toString() ?? 'Google Meet Session', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                    if (isLive) const Chip(label: Text('LIVE NOW'), visualDensity: VisualDensity.compact),
                    if (isTeacher) ...[
                      IconButton(tooltip: 'Edit meeting', onPressed: () => _showScheduleMeetDialog(lc), icon: const Icon(Icons.edit_outlined)),
                      IconButton(tooltip: 'Delete meeting', onPressed: () => _deleteLiveClass(lc), icon: const Icon(Icons.delete_outline, color: Colors.red)),
                    ],
                  ]),
                  const SizedBox(height: 6),
                  Text('Class: ${_classroom?['name'] ?? ''}  •  Subject: ${_classroom?['subject'] ?? '—'}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  Text('Teacher: ${lc['hostName'] ?? _classroom?['creatorName'] ?? ''}  •  $dateTime', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.video_call, size: 16),
                      label: const Text('Join Google Meet'),
                      style: ElevatedButton.styleFrom(backgroundColor: isLive ? Colors.green : AppColors.primary, foregroundColor: Colors.white),
                      onPressed: () async {
                        try {
                          final joinRes = await _apiService.joinLiveClass(lc['id'].toString());
                          final link = Uri.parse((joinRes['meetLink'] ?? lc['meetLink']).toString());
                          if (!await launchUrl(link, mode: LaunchMode.externalApplication) && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Google Meet.')));
                          }
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red));
                        }
                      },
                    ),
                    TextButton.icon(onPressed: () => Clipboard.setData(ClipboardData(text: lc['meetLink'].toString())), icon: const Icon(Icons.copy, size: 16), label: const Text('Copy link')),
                  ]),
                ]),
              );
            }),
          ],

          // Stream Announcement Composer
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 16,
                        child: Icon(Icons.person, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _announcementController,
                          decoration: const InputDecoration(
                            hintText: 'Announce something to your class...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send, size: 14),
                        label: const Text('Post to Stream'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _postAnnouncement,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Stream Posts Feed
          if (_streamPosts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('This is where you can talk to your class. Add an announcement above!', style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ..._streamPosts.map((post) {
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: themeColor,
                            radius: 16,
                            child: Text(
                              (post['authorName'] as String? ?? 'U').substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post['authorName'] ?? 'Author', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(post['createdAt'] ?? '', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(post['content'] ?? '', style: const TextStyle(fontSize: 14, color: AppColors.textMain)),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildClassworkTab(Color themeColor, bool isTeacher) {
    return Column(
      children: [
        // Action Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assignments & Coursework (${_assignments.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
              if (isTeacher)
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Upload Assignment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _showCreateAssignmentDialog,
                ),
            ],
          ),
        ),

        Expanded(
          child: _assignments.isEmpty
              ? const Center(
                  child: Text('No assignments published yet.', style: TextStyle(color: AppColors.textMuted)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _assignments.length,
                  itemBuilder: (ctx, idx) {
                    final a = _assignments[idx];
                    final submissionStatus = a['submissionStatus'] ?? '';
                    final points = a['pointsPossible'] ?? 100;
                    final dueDate = a['dueDate'] ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => AssignmentViewScreen(
                                assignmentId: a['id'].toString(),
                                classroomId: widget.classroomId,
                                userRole: widget.userRole,
                              ),
                            ),
                          ).then((_) => _loadClassroom());
                        },
                        leading: CircleAvatar(
                          backgroundColor: themeColor.withValues(alpha: 0.15),
                          child: Icon(Icons.assignment, color: themeColor),
                        ),
                        title: Text(a['title'] ?? 'Assignment', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Due: ${dueDate.isNotEmpty ? dueDate : "No deadline"} • $points pts\n${a['instructions'] ?? ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (submissionStatus.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: submissionStatus == 'TURNED_IN' || submissionStatus == 'GRADED'
                                      ? Colors.green.shade100
                                      : Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  submissionStatus,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: submissionStatus == 'TURNED_IN' || submissionStatus == 'GRADED'
                                        ? Colors.green.shade800
                                        : Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => AssignmentViewScreen(
                                      assignmentId: a['id'].toString(),
                                      classroomId: widget.classroomId,
                                      userRole: widget.userRole,
                                    ),
                                  ),
                                ).then((_) => _loadClassroom());
                              },
                              child: Text(isTeacher ? 'Review Work' : (submissionStatus == 'TURNED_IN' ? 'View Work' : 'Open')),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPeopleTab(Color themeColor, bool isTeacher) {
    final teachers = (_members?['teachers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final students = (_members?['students'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final pending = (_members?['pendingApprovals'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Pending Approvals Queue (Teacher only)
        if (isTeacher && pending.isNotEmpty) ...[
          Row(
            children: [
              Text('Pending Enrollment Approvals (${pending.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            ],
          ),
          const Divider(color: Colors.amber, thickness: 1.5),
          ...pending.map((p) => ListTile(
                leading: CircleAvatar(backgroundColor: Colors.amber, child: Text((p['name'] as String? ?? 'S')[0])),
                title: Text(p['name'] ?? ''),
                subtitle: Text(p['email'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: 'Approve',
                      onPressed: () async {
                        await _apiService.updateMemberStatus(widget.classroomId, p['userId'].toString(), 'ACTIVE');
                        _loadClassroom();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      tooltip: 'Decline',
                      onPressed: () async {
                        await _apiService.updateMemberStatus(widget.classroomId, p['userId'].toString(), 'REJECTED');
                        _loadClassroom();
                      },
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),
        ],

        // Teachers Section
        Row(
          children: [
            Text('Teachers (${teachers.length})', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeColor)),
          ],
        ),
        Divider(color: themeColor, thickness: 1.5),
        ...teachers.map((t) => ListTile(
              leading: CircleAvatar(backgroundColor: themeColor, child: Text((t['name'] as String? ?? 'T')[0], style: const TextStyle(color: Colors.white))),
              title: Text(t['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(t['email'] ?? ''),
              trailing: Chip(label: Text(t['role'] ?? 'TEACHER'), backgroundColor: themeColor.withValues(alpha: 0.1)),
            )),
        const SizedBox(height: 32),

        // Students Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Classmates (${students.length})', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeColor)),
            Text('${students.length} students', style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
        Divider(color: themeColor, thickness: 1.5),
        if (students.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No students currently enrolled.', style: TextStyle(color: AppColors.textMuted)),
          )
        else
          ...students.map((s) => ListTile(
                leading: CircleAvatar(backgroundColor: const Color(0xFFE2E8F0), child: Text((s['name'] as String? ?? 'S')[0])),
                title: Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(s['email'] ?? ''),
              )),
      ],
    );
  }

  Widget _buildGradesTab(Color themeColor, bool isTeacher) {
    if (!isTeacher) {
      // Student Personal Grade View
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Your Grades & Returned Evaluations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._assignments.map((a) {
            final myScore = a['myScore'];
            final isReturned = a['isReturned'] == true;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(a['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Max points: ${a['pointsPossible']} pts'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isReturned ? Colors.green.shade100 : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isReturned ? '$myScore / ${a['pointsPossible']}' : 'Not Graded Yet',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isReturned ? Colors.green.shade800 : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      );
    }

    // Teacher Gradebook Matrix
    final gradebookList = (_gradebook?['gradebook'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Class Gradebook Matrix', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${gradebookList.length} Students Graded', style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 16),
        if (gradebookList.isEmpty)
          const Text('No submissions to grade yet.', style: TextStyle(color: AppColors.textMuted))
        else
          ...gradebookList.map((g) {
            final studentName = g['studentName'] ?? 'Student';
            final totalScore = g['totalScore'] ?? 0;
            final totalPossible = g['totalPossible'] ?? 100;
            final percentage = g['percentage'] ?? 0.0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: CircleAvatar(backgroundColor: themeColor, child: Text((studentName as String)[0], style: const TextStyle(color: Colors.white))),
                title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Score: $totalScore / $totalPossible (${percentage.toStringAsFixed(1)}%)'),
                children: [
                  ..._assignments.map((a) {
                    final assignId = a['id'].toString();
                    final scoreVal = (g['scores'] as Map?)?[assignId] ?? 'MISSING';
                    return ListTile(
                      dense: true,
                      title: Text(a['title'] ?? ''),
                      trailing: TextButton(
                        onPressed: () {
                          _showGradeDialog({
                            'id': a['id'],
                            'studentName': studentName,
                            'submissionText': 'Current Score: $scoreVal',
                          });
                        },
                        child: Text(scoreVal.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
      ],
    );
  }
}
