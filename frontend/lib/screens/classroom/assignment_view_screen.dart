import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../services/api_service.dart';

class AssignmentViewScreen extends StatefulWidget {
  final String assignmentId;
  final String classroomId;
  final String userRole; // student, teacher, admin

  const AssignmentViewScreen({
    super.key,
    required this.assignmentId,
    required this.classroomId,
    required this.userRole,
  });

  @override
  State<AssignmentViewScreen> createState() => _AssignmentViewScreenState();
}

class _AssignmentViewScreenState extends State<AssignmentViewScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _assignment;
  Map<String, dynamic>? _mySubmission;
  List<Map<String, dynamic>> _teacherAttachments = [];
  List<Map<String, dynamic>> _classComments = [];
  List<Map<String, dynamic>> _privateComments = [];
  List<Map<String, dynamic>> _allSubmissions = []; // For teachers

  // Staged student attachments before submitting
  final List<Map<String, dynamic>> _stagedAttachments = [];
  final TextEditingController _studentTextController = TextEditingController();

  // Teacher selected student
  Map<String, dynamic>? _selectedSubmission;
  final TextEditingController _gradeScoreController = TextEditingController();
  final TextEditingController _gradeFeedbackController = TextEditingController();

  // Comment controllers
  final TextEditingController _classCommentController = TextEditingController();
  final TextEditingController _privateCommentController = TextEditingController();

  // Teacher tabs
  late TabController _teacherTabController;

  @override
  void initState() {
    super.initState();
    _teacherTabController = TabController(length: 2, vsync: this);
    _loadAssignmentData();
  }

  @override
  void dispose() {
    _teacherTabController.dispose();
    _studentTextController.dispose();
    _gradeScoreController.dispose();
    _gradeFeedbackController.dispose();
    _classCommentController.dispose();
    _privateCommentController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignmentData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _apiService.getAssignmentDetails(widget.assignmentId);
      final classComments = await _apiService.getClassroomComments(
        widget.classroomId,
        targetType: 'ASSIGNMENT',
        targetId: widget.assignmentId,
      );

      Map<String, dynamic>? sub;
      List<Map<String, dynamic>> privComments = [];

      if (data['mySubmission'] != null) {
        sub = Map<String, dynamic>.from(data['mySubmission'] as Map);
        final subId = sub['id']?.toString();
        if (subId != null) {
          privComments = await _apiService.getClassroomComments(
            widget.classroomId,
            targetType: 'SUBMISSION',
            targetId: subId,
          );
        }
      }

      List<Map<String, dynamic>> allSubs = [];
      if (data['submissions'] is List) {
        allSubs = (data['submissions'] as List).cast<Map<String, dynamic>>();
      }

      if (!mounted) return;
      setState(() {
        _assignment = data;
        _teacherAttachments = (data['attachments'] is List)
            ? (data['attachments'] as List).cast<Map<String, dynamic>>()
            : [];
        _mySubmission = sub;
        _classComments = classComments;
        _privateComments = privComments;
        _allSubmissions = allSubs;
        if (allSubs.isNotEmpty && _selectedSubmission == null) {
          _selectTeacherSubmission(allSubs.first);
        }
        if (sub != null && sub['submissionText'] != null) {
          _studentTextController.text = sub['submissionText'].toString();
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _selectTeacherSubmission(Map<String, dynamic> sub) {
    setState(() {
      _selectedSubmission = sub;
      final grade = sub['grade'] as Map<String, dynamic>?;
      _gradeScoreController.text = grade?['score']?.toString() ?? '';
      _gradeFeedbackController.text = grade?['feedback']?.toString() ?? '';
    });
  }

  Future<void> _postClassComment() async {
    final text = _classCommentController.text.trim();
    if (text.isEmpty) return;
    _classCommentController.clear();

    try {
      await _apiService.postClassroomComment(widget.classroomId, {
        'content': text,
        'targetType': 'ASSIGNMENT',
        'targetId': widget.assignmentId,
      });
      _loadAssignmentData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _postPrivateComment() async {
    final text = _privateCommentController.text.trim();
    if (text.isEmpty) return;

    final subId = _mySubmission?['id']?.toString() ?? _selectedSubmission?['id']?.toString();
    if (subId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission record is required to send a private comment.')),
      );
      return;
    }

    _privateCommentController.clear();
    try {
      await _apiService.postClassroomComment(widget.classroomId, {
        'content': text,
        'targetType': 'SUBMISSION',
        'targetId': subId,
      });
      _loadAssignmentData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post private comment: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showAddAttachmentDialog() {
    final urlController = TextEditingController();
    final nameController = TextEditingController();
    String fileType = 'LINK';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.attach_file, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Add Attachment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add a web link, Google Drive document, or Cloudinary file URL:',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: fileType,
                decoration: InputDecoration(
                  labelText: 'Attachment Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: 'LINK', child: Text('Link / URL (GitHub, Google Drive, etc.)')),
                  DropdownMenuItem(value: 'PDF', child: Text('PDF Document')),
                  DropdownMenuItem(value: 'IMAGE', child: Text('Image (PNG, JPG)')),
                  DropdownMenuItem(value: 'DOCUMENT', child: Text('Word / Presentation / Zip')),
                ],
                onChanged: (v) => setDlgState(() => fileType = v ?? 'LINK'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Attachment Name / Title',
                  hintText: 'e.g. Solution Code or Assignment_Report.pdf',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'URL or File Link',
                  hintText: 'https://...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final url = urlController.text.trim();
                if (url.isEmpty) return;
                final name = nameController.text.trim().isNotEmpty
                    ? nameController.text.trim()
                    : url.split('/').last.split('?').first;

                setState(() {
                  _stagedAttachments.add({
                    'fileName': name.isNotEmpty ? name : 'Attached Resource',
                    'fileUrl': url,
                    'fileType': fileType,
                  });
                });
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitWork({bool isResubmit = false}) async {
    final hasAttachments = _stagedAttachments.isNotEmpty || (_mySubmission?['attachments'] as List?)?.isNotEmpty == true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          hasAttachments ? 'Turn in your work?' : 'Mark as done?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          hasAttachments
              ? '${_stagedAttachments.length} attachment(s) will be submitted for "${_assignment?['title'] ?? 'this assignment'}".'
              : 'You did not attach any files, so your teacher will see that it is marked as done.',
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(hasAttachments ? 'Turn In' : 'Mark as Done'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiService.submitAssignment(widget.assignmentId, {
        'submissionText': _studentTextController.text.trim(),
        'attachments': _stagedAttachments,
      });

      if (!mounted) return;
      setState(() {
        _stagedAttachments.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment turned in successfully!'), backgroundColor: Colors.green),
      );
      _loadAssignmentData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _unsubmitWork() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Unsubmit?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Unsubmit to add or change attachments. Don\'t forget to resubmit once you\'re done.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Unsubmit'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiService.unsubmitAssignment(widget.assignmentId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment unsubmitted. You can now edit and resubmit.'), backgroundColor: Colors.orange),
      );
      _loadAssignmentData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteSubmittedAttachment(String attachmentId) async {
    try {
      await _apiService.deleteAttachment(attachmentId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attachment removed.')),
      );
      _loadAssignmentData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _teacherGradeSubmission() async {
    if (_selectedSubmission == null) return;
    final scoreText = _gradeScoreController.text.trim();
    if (scoreText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a grade score.')),
      );
      return;
    }

    try {
      await _apiService.gradeSubmission(_selectedSubmission!['id'].toString(), {
        'score': double.parse(scoreText),
        'feedback': _gradeFeedbackController.text.trim(),
        'isReturned': true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grade saved and returned to student!'), backgroundColor: Colors.green),
      );
      _loadAssignmentData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: url));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link copied to clipboard!')),
          );
        }
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copied to clipboard!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = widget.userRole == 'teacher' || widget.userRole == 'admin';

    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(backgroundColor: Colors.white, elevation: 1),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _assignment == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(backgroundColor: Colors.white, elevation: 1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(_error ?? 'Assignment not found', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadAssignmentData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to Class',
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.assignment, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _assignment!['title'] ?? 'Assignment',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMain),
            tooltip: 'Refresh',
            onPressed: _loadAssignmentData,
          ),
          const SizedBox(width: 12),
        ],
        bottom: isTeacher
            ? TabBar(
                controller: _teacherTabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Student Work (${_allSubmissions.length})'),
                  const Tab(text: 'Instructions'),
                ],
              )
            : null,
      ),
      body: isTeacher
          ? TabBarView(
              controller: _teacherTabController,
              children: [
                _buildTeacherStudentWorkView(),
                _buildStudentView(isTeacherMode: true),
              ],
            )
          : _buildStudentView(isTeacherMode: false),
    );
  }

  // Authentic Google Classroom Student View
  Widget _buildStudentView({required bool isTeacherMode}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 850;

        if (isDesktop) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Instructions, attachments & class comments (flex: 3)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAssignmentHeader(),
                      const SizedBox(height: 16),
                      _buildInstructionsSection(),
                      const SizedBox(height: 24),
                      if (_teacherAttachments.isNotEmpty) ...[
                        _buildAttachmentsSection(),
                        const SizedBox(height: 24),
                      ],
                      const Divider(height: 32, color: AppColors.border),
                      _buildClassCommentsSection(),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                // Right Column: "Your work" card & private comments (flex: 2)
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      if (!isTeacherMode) ...[
                        _buildYourWorkCard(),
                        const SizedBox(height: 24),
                        _buildPrivateCommentsCard(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile responsive layout
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAssignmentHeader(),
                const SizedBox(height: 16),
                if (!isTeacherMode) ...[
                  _buildYourWorkCard(),
                  const SizedBox(height: 20),
                ],
                _buildInstructionsSection(),
                const SizedBox(height: 20),
                if (_teacherAttachments.isNotEmpty) ...[
                  _buildAttachmentsSection(),
                  const SizedBox(height: 20),
                ],
                if (!isTeacherMode) ...[
                  _buildPrivateCommentsCard(),
                  const SizedBox(height: 20),
                ],
                const Divider(height: 32, color: AppColors.border),
                _buildClassCommentsSection(),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildAssignmentHeader() {
    final title = _assignment!['title'] ?? 'Assignment';
    final teacher = _assignment!['createdByName'] ?? 'Instructor';
    final points = _assignment!['pointsPossible'] ?? 100;
    final dueDate = _assignment!['dueDate'];

    String dueFormatted = 'No due date';
    bool isOverdue = false;
    if (dueDate != null) {
      try {
        final dt = DateTime.parse(dueDate.toString());
        dueFormatted = 'Due ${dt.day}/${dt.month}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        if (DateTime.now().isAfter(dt)) {
          isOverdue = true;
        }
      } catch (_) {
        dueFormatted = 'Due $dueDate';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$teacher • ${_assignment!['createdAt']?.toString().split('T').first ?? 'Recent'}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$points points',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMain),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dueFormatted,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isOverdue ? AppColors.error : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: AppColors.border),
      ],
    );
  }

  Widget _buildInstructionsSection() {
    final instructions = _assignment!['instructions']?.toString().trim() ?? 'No instructions provided.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instructions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain),
          ),
          const SizedBox(height: 12),
          SelectableText(
            instructions,
            style: const TextStyle(fontSize: 14, color: AppColors.textMain, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reference Materials',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _teacherAttachments.map((att) {
            final fileName = att['fileName'] ?? 'Document';
            final fileUrl = att['fileUrl'] ?? '';
            final fileType = att['fileType'] ?? 'FILE';

            IconData icon = Icons.insert_drive_file;
            Color iconColor = Colors.blue;
            if (fileType == 'PDF') {
              icon = Icons.picture_as_pdf;
              iconColor = Colors.red;
            } else if (fileType == 'IMAGE') {
              icon = Icons.image;
              iconColor = Colors.green;
            } else if (fileType == 'LINK') {
              icon = Icons.link;
              iconColor = Colors.teal;
            }

            return InkWell(
              onTap: () => _launchUrl(fileUrl),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 260,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            fileType,
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.open_in_new, size: 16, color: AppColors.textMuted),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Google Classroom "Your work" card
  Widget _buildYourWorkCard() {
    final subStatus = _mySubmission?['status']?.toString() ?? _assignment?['submissionStatus']?.toString() ?? 'ASSIGNED';
    final isTurnedIn = subStatus == 'TURNED_IN' || subStatus == 'LATE';
    final isGraded = subStatus == 'GRADED' || subStatus == 'RETURNED';

    final gradeInfo = _mySubmission?['grade'] as Map<String, dynamic>?;
    final score = gradeInfo?['score'] ?? _assignment?['myScore'];
    final feedback = gradeInfo?['feedback'];

    Color statusColor = Colors.green;
    String statusLabel = 'Assigned';

    if (subStatus == 'TURNED_IN') {
      statusColor = Colors.blue.shade700;
      statusLabel = 'Turned in';
    } else if (subStatus == 'LATE') {
      statusColor = Colors.orange.shade800;
      statusLabel = 'Done late';
    } else if (subStatus == 'MISSING') {
      statusColor = AppColors.error;
      statusLabel = 'Missing';
    } else if (isGraded) {
      statusColor = Colors.purple.shade700;
      statusLabel = score != null ? 'Graded: $score/${_assignment!['pointsPossible'] ?? 100}' : 'Graded';
    }

    final serverAttachments = (_mySubmission?['attachments'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your work',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Graded score display
          if (isGraded && score != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.purple, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Score: $score / ${_assignment!['pointsPossible'] ?? 100}',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                      ),
                    ],
                  ),
                  if (feedback != null && feedback.toString().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Teacher feedback: "$feedback"',
                      style: TextStyle(fontSize: 12, color: Colors.purple.shade800, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Submitted attachments from server
          if (serverAttachments.isNotEmpty) ...[
            const Text('Submitted Attachments:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            const SizedBox(height: 8),
            ...serverAttachments.map((att) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        att['fileName'] ?? 'Attachment',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new, size: 16, color: AppColors.primary),
                      onPressed: () => _launchUrl(att['fileUrl'] ?? ''),
                      tooltip: 'Open',
                    ),
                    if (!isTurnedIn && !isGraded)
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: Colors.red),
                        onPressed: () => _deleteSubmittedAttachment(att['id'].toString()),
                        tooltip: 'Remove',
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],

          // Staged local attachments (before turning in)
          if (_stagedAttachments.isNotEmpty) ...[
            const Text('Newly Added Files:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green)),
            const SizedBox(height: 8),
            ..._stagedAttachments.map((att) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        att['fileName'] ?? 'Staged file',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _stagedAttachments.remove(att);
                        });
                      },
                      tooltip: 'Remove',
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],

          // Text Answer Input (if editable)
          if (!isTurnedIn && !isGraded) ...[
            TextField(
              controller: _studentTextController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add text answer or notes for teacher...',
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('+ Add or create'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _showAddAttachmentDialog,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () => _submitWork(),
              child: Text(
                _stagedAttachments.isNotEmpty || serverAttachments.isNotEmpty ? 'Turn in' : 'Mark as done',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ] else if (isTurnedIn) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Work is turned in. Click unsubmit below if you need to add or edit attachments.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                side: BorderSide(color: Colors.orange.shade700),
                foregroundColor: Colors.orange.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _unsubmitWork,
              child: const Text('Unsubmit', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ] else if (isGraded) ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.replay, size: 18),
              label: const Text('Resubmit Work'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _submitWork(isResubmit: true),
            ),
          ],
        ],
      ),
    );
  }

  // Google Classroom "Private comments" card
  Widget _buildPrivateCommentsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
              SizedBox(width: 8),
              Text(
                'Private comments',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Visible only to you and your instructor.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          if (_privateComments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No private comments yet.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            )
          else
            ..._privateComments.map((c) {
              final isMe = c['authorRole'] == 'student';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFFF0FDF4) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          c['authorName'] ?? 'User',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          c['createdAt']?.toString().split('T').first ?? '',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c['content'] ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _privateCommentController,
                  decoration: InputDecoration(
                    hintText: 'Add private comment...',
                    hintStyle: const TextStyle(fontSize: 12),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primary, size: 20),
                onPressed: _postPrivateComment,
                tooltip: 'Send private comment',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Google Classroom "Class comments" section
  Widget _buildClassCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people_outline, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Class comments (${_classComments.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_classComments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No class comments yet. Be the first to ask a question!', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          )
        else
          ..._classComments.map((c) {
            final isTeacher = c['authorRole'] == 'teacher' || c['authorRole'] == 'admin';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isTeacher ? AppColors.teacherPrimary : AppColors.studentPrimary,
                    child: Text(
                      (c['authorName'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              c['authorName'] ?? 'User',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            if (isTeacher) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Teacher', style: TextStyle(fontSize: 9, color: Colors.blue, fontWeight: FontWeight.bold)),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              c['createdAt']?.toString().split('T').first ?? '',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c['content'] ?? '',
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _classCommentController,
                decoration: InputDecoration(
                  hintText: 'Add class comment...',
                  hintStyle: const TextStyle(fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: _postClassComment,
              tooltip: 'Post to class',
            ),
          ],
        ),
      ],
    );
  }

  // Teacher View: Student work roster & grading split pane
  Widget _buildTeacherStudentWorkView() {
    int turnedInCount = 0;
    int gradedCount = 0;
    int assignedCount = _allSubmissions.length;

    for (final s in _allSubmissions) {
      final st = s['status']?.toString();
      if (st == 'TURNED_IN' || st == 'LATE') turnedInCount++;
      if (st == 'GRADED' || st == 'RETURNED') gradedCount++;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 850;

        return Column(
          children: [
            // Summary Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              color: Colors.white,
              child: Row(
                children: [
                  _buildMetricPill('$turnedInCount', 'Turned in', Colors.blue.shade700),
                  const SizedBox(width: 16),
                  _buildMetricPill('$assignedCount', 'Assigned', Colors.green.shade700),
                  const SizedBox(width: 16),
                  _buildMetricPill('$gradedCount', 'Graded', Colors.purple.shade700),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // Main Content Area
            Expanded(
              child: isDesktop
                  ? Row(
                      children: [
                        // Left: Student Roster
                        SizedBox(
                          width: 320,
                          child: _buildStudentRosterList(),
                        ),
                        const VerticalDivider(width: 1, color: AppColors.border),
                        // Right: Selected Student Submission & Grade panel
                        Expanded(
                          child: _buildSubmissionEvaluationPane(),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 220,
                          child: _buildStudentRosterList(),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        Expanded(
                          child: _buildSubmissionEvaluationPane(),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricPill(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildStudentRosterList() {
    if (_allSubmissions.isEmpty) {
      return const Center(
        child: Text('No student submissions yet.', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    return ListView.separated(
      itemCount: _allSubmissions.length,
      separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
      itemBuilder: (ctx, idx) {
        final sub = _allSubmissions[idx];
        final isSelected = _selectedSubmission?['id'] == sub['id'];
        final status = sub['status']?.toString() ?? 'ASSIGNED';
        final grade = sub['grade'] as Map<String, dynamic>?;

        Color badgeColor = Colors.green;
        String badgeText = status;
        if (status == 'TURNED_IN') {
          badgeColor = Colors.blue;
          badgeText = 'Turned in';
        } else if (status == 'LATE') {
          badgeColor = Colors.orange;
          badgeText = 'Done late';
        } else if (status == 'GRADED' || status == 'RETURNED') {
          badgeColor = Colors.purple;
          badgeText = '${grade?['score'] ?? '-'} / ${_assignment!['pointsPossible'] ?? 100}';
        }

        return ListTile(
          selected: isSelected,
          selectedTileColor: const Color(0xFFEFF6FF),
          leading: CircleAvatar(
            backgroundColor: AppColors.studentPrimary,
            child: Text(
              (sub['studentName'] ?? 'S')[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            sub['studentName'] ?? 'Student',
            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 13),
          ),
          subtitle: Text(
            sub['studentEmail'] ?? '',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeText,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
            ),
          ),
          onTap: () => _selectTeacherSubmission(sub),
        );
      },
    );
  }

  Widget _buildSubmissionEvaluationPane() {
    if (_selectedSubmission == null) {
      return const Center(
        child: Text('Select a student from the roster to review submission and assign grades.'),
      );
    }

    final sub = _selectedSubmission!;
    final studentName = sub['studentName'] ?? 'Student';
    final submittedAt = sub['submittedAt']?.toString() ?? '';
    final subText = sub['submissionText']?.toString() ?? '';
    final attachments = (sub['attachments'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final status = sub['status']?.toString() ?? 'ASSIGNED';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(studentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Submitted: $submittedAt • Status: $status', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Return Grade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _teacherGradeSubmission,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Submitted Text
          const Text('Submission Notes / Text Answer:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              subText.isNotEmpty ? subText : 'No text response entered.',
              style: TextStyle(fontSize: 13, color: subText.isNotEmpty ? AppColors.textMain : AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 20),

          // Attachments
          const Text('Submitted Files & Links:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          if (attachments.isEmpty)
            const Text('No files attached.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: attachments.map((att) {
                return InkWell(
                  onTap: () => _launchUrl(att['fileUrl'] ?? ''),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.attach_file, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(att['fileName'] ?? 'Attachment', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        const Icon(Icons.open_in_new, size: 14, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),

          // Grade input section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Grade & Feedback', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _gradeScoreController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Score',
                          suffixText: '/ ${_assignment!['pointsPossible'] ?? 100}',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _gradeFeedbackController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Private Feedback for Student',
                    hintText: 'Add remarks, guidance, or rubric breakdown...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
