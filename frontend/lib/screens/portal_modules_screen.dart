import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class PortalModulesScreen extends StatefulWidget {
  final String role;
  final String module;
  final UserModel? user;
  final String? targetId;

  const PortalModulesScreen({
    super.key,
    required this.role,
    required this.module,
    required this.user,
    this.targetId,
  });

  @override
  State<PortalModulesScreen> createState() => _PortalModulesScreenState();
}

class _PortalModulesScreenState extends State<PortalModulesScreen> {
  final ApiService _api = ApiService();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _reason = TextEditingController();
  final _search = TextEditingController();
  List<Map<String, dynamic>> _announcements = [];
  List<Map<String, dynamic>> _leaves = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _teachers = [];
  String _audience = 'BOTH';
  String _leaveType = 'Personal';
  String _statusFilter = '';
  String _applicantRoleFilter = '';
  String? _editingId;
  String? _documentUrl;
  String? _documentName;
  String? _assignmentStudent;
  String? _assignmentTeacher;
  DateTime _announcementDate = DateTime.now();
  DateTime? _announcementExpiry;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  DateTime? _filterFrom;
  DateTime? _filterTo;
  bool _published = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _isAdmin => widget.role == 'admin';
  bool get _isTeacher => widget.role == 'teacher';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(PortalModulesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.module != widget.module ||
        oldWidget.role != widget.role ||
        oldWidget.targetId != widget.targetId) {
      _load();
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _reason.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (widget.module == 'announcements') {
        _announcements = await _api.getAnnouncements();
      } else {
        _leaves = await _api.getLeaves(
          status: _statusFilter,
          applicantRole: _applicantRoleFilter,
          search: _search.text.trim(),
          from: _filterFrom == null ? null : _date(_filterFrom!),
          to: _filterTo == null ? null : _date(_filterTo!),
        );
        if (_isAdmin) {
          final options = await _api.getAssignmentOptions();
          _students = (options['students'] as List)
              .cast<Map<String, dynamic>>();
          _teachers = (options['teachers'] as List)
              .cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _run(Future<void> Function() action, {String? success}) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await action();
      await _load();
      if (mounted && success != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(success)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _selectDate({
    required bool forStart,
    bool expiry = false,
  }) async {
    final initial = expiry
        ? (_announcementExpiry ?? _announcementDate)
        : forStart
        ? _startDate
        : _endDate;
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (expiry) {
        _announcementExpiry = selected;
      } else if (forStart) {
        _startDate = selected;
        if (_endDate.isBefore(selected)) _endDate = selected;
      } else {
        _endDate = selected;
      }
    });
  }

  Future<void> _selectFilterDate({required bool from}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: (from ? _filterFrom : _filterTo) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (from) {
        _filterFrom = selected;
      } else {
        _filterTo = selected;
      }
    });
    await _load();
  }

  String _date(DateTime value) => DateFormat('yyyy-MM-dd').format(value);

  Future<void> _saveAnnouncement() async {
    if (_title.text.trim().isEmpty || _description.text.trim().isEmpty) {
      setState(() => _error = 'Enter an announcement title and description.');
      return;
    }
    await _run(
      () async {
        await _api.saveAnnouncement({
          'title': _title.text.trim(),
          'description': _description.text.trim(),
          'audience': _audience,
          'announcementDate': _date(_announcementDate),
          'expiresAt': _announcementExpiry == null
              ? null
              : _date(_announcementExpiry!),
          'published': _published,
        }, id: _editingId);
        _clearAnnouncementForm();
      },
      success: _editingId == null
          ? 'Announcement saved.'
          : 'Announcement updated.',
    );
  }

  void _editAnnouncement(Map<String, dynamic> item) {
    setState(() {
      _editingId = item['id'].toString();
      _title.text = item['title']?.toString() ?? '';
      _description.text = item['description']?.toString() ?? '';
      _audience = item['audience']?.toString() ?? 'BOTH';
      _published = item['published'] == true;
      _announcementDate =
          DateTime.tryParse(item['announcementDate']?.toString() ?? '') ??
          DateTime.now();
      _announcementExpiry = DateTime.tryParse(
        item['expiresAt']?.toString() ?? '',
      );
    });
  }

  void _clearAnnouncementForm() {
    _editingId = null;
    _title.clear();
    _description.clear();
    _audience = 'BOTH';
    _published = false;
    _announcementDate = DateTime.now();
    _announcementExpiry = null;
  }

  Future<void> _submitLeave() async {
    if (_reason.text.trim().isEmpty) {
      setState(() => _error = 'Enter a reason for the leave application.');
      return;
    }
    await _run(() async {
      await _api.submitLeave({
        'leaveType': _leaveType,
        'startDate': _date(_startDate),
        'endDate': _date(_endDate),
        'reason': _reason.text.trim(),
        'documentUrl': _documentUrl,
      });
      _reason.clear();
      _documentUrl = null;
      _documentName = null;
    }, success: 'Leave application submitted.');
  }

  Future<void> _uploadDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      if (file.size > 10 * 1024 * 1024 || file.bytes == null) {
        setState(() => _error = 'Choose a PDF, JPEG, or PNG file up to 10 MB.');
        return;
      }
      setState(() {
        _saving = true;
        _error = null;
      });
      _documentUrl = await _api.uploadLeaveDocument(file.bytes!, file.name);
      _documentName = file.name;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _decide(Map<String, dynamic> item, String decision) async {
    final remarkController = TextEditingController();
    final remark = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${decision == 'APPROVED' ? 'Approve' : 'Reject'} leave application',
        ),
        content: TextField(
          controller: remarkController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Remark (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, remarkController.text),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    remarkController.dispose();
    if (remark == null) return;
    await _run(() async {
      await _api.decideLeave(item['id'].toString(), decision, remark.trim());
    }, success: 'Leave application ${decision.toLowerCase()}.');
  }

  Future<void> _assignTeacher() async {
    if (_assignmentStudent == null || _assignmentTeacher == null) {
      setState(() => _error = 'Select both a student and a teacher.');
      return;
    }
    await _run(() async {
      await _api.assignTeacher(_assignmentStudent!, _assignmentTeacher!);
    }, success: 'Teacher assignment saved.');
  }

  @override
  Widget build(BuildContext context) {
    final isAnnouncements = widget.module == 'announcements';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_error != null) ...[
          _message(_error!, AppColors.errorBg, AppColors.error),
          const SizedBox(height: 12),
        ],
        if (isAnnouncements) ...[
          if (_isAdmin) _announcementForm(),
          if (_isAdmin) const SizedBox(height: 20),
          _announcementList(),
        ] else ...[
          if (!_isAdmin) _leaveForm(),
          if (_isAdmin) _assignmentPanel(),
          if (!_isAdmin || _isTeacher) const SizedBox(height: 20),
          _leaveList(),
        ],
      ],
    );
  }

  Widget _announcementForm() => _panel(
    title: _editingId == null ? 'Create announcement' : 'Edit announcement',
    subtitle:
        'Announcements are shared with selected institute users when published.',
    child: Column(
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                initialValue: _audience,
                decoration: const InputDecoration(labelText: 'Audience'),
                items: const [
                  DropdownMenuItem(
                    value: 'STUDENTS',
                    child: Text('All Students'),
                  ),
                  DropdownMenuItem(
                    value: 'TEACHERS',
                    child: Text('All Teachers'),
                  ),
                  DropdownMenuItem(
                    value: 'BOTH',
                    child: Text('Students and Teachers'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _audience = value ?? 'BOTH'),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _selectDate(forStart: true),
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text('Date: ${_date(_announcementDate)}'),
            ),
            OutlinedButton.icon(
              onPressed: () => _selectDate(forStart: true, expiry: true),
              icon: const Icon(Icons.event_busy_outlined),
              label: Text(
                _announcementExpiry == null
                    ? 'No expiry'
                    : 'Expires: ${_date(_announcementExpiry!)}',
              ),
            ),
            if (_announcementExpiry != null)
              IconButton(
                onPressed: () => setState(() => _announcementExpiry = null),
                icon: const Icon(Icons.clear),
                tooltip: 'Clear expiry',
              ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Published'),
          subtitle: const Text(
            'Published announcements appear in their audience portals.',
          ),
          value: _published,
          onChanged: (value) => setState(() => _published = value),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            spacing: 8,
            children: [
              if (_editingId != null)
                TextButton(
                  onPressed: _clearAnnouncementForm,
                  child: const Text('Cancel edit'),
                ),
              FilledButton.icon(
                onPressed: _saving ? null : _saveAnnouncement,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _editingId == null
                      ? 'Save announcement'
                      : 'Update announcement',
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _announcementList() => _panel(
    title: _isAdmin
        ? 'Announcements'
        : 'Latest announcements${_announcements.any((item) => item['read'] != true) ? ' • ${_announcements.where((item) => item['read'] != true).length} unread' : ''}',
    subtitle: _isAdmin
        ? 'Manage institute-wide announcements.'
        : 'Only announcements for your role are shown.',
    child: _loading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        : _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          )
        : _announcements.isEmpty
        ? const _EmptyState('No announcements to show.')
        : Column(
            children: _announcements.map((item) {
              final isRead = item['read'] == true;
              final published = item['published'] == true;
              return Card(
                color: item['id'].toString() == widget.targetId
                    ? AppColors.primaryLight
                    : null,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item['title']?.toString() ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _badge(
                            _isAdmin
                                ? (published ? 'Published' : 'Unpublished')
                                : (isRead ? 'Read' : 'Unread'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(item['description']?.toString() ?? ''),
                      const SizedBox(height: 10),
                      Text(
                        'Date: ${item['announcementDate'] ?? '-'}  •  By ${item['publisher'] ?? 'Admin'}'
                        '${item['expiresAt'] == null ? '' : '  •  Expires ${item['expiresAt']}'}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      if (_isAdmin)
                        Wrap(
                          spacing: 4,
                          children: [
                            TextButton.icon(
                              onPressed: () => _editAnnouncement(item),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit'),
                            ),
                            TextButton.icon(
                              onPressed: _saving
                                  ? null
                                  : () => _run(
                                      () async {
                                        final body = {
                                          'title': item['title'],
                                          'description': item['description'],
                                          'audience': item['audience'],
                                          'announcementDate':
                                              item['announcementDate'],
                                          'expiresAt': item['expiresAt'],
                                          'published': !published,
                                        };
                                        await _api.saveAnnouncement(
                                          body,
                                          id: item['id'].toString(),
                                        );
                                      },
                                      success: published
                                          ? 'Announcement unpublished.'
                                          : 'Announcement published.',
                                    ),
                              icon: Icon(
                                published
                                    ? Icons.visibility_off_outlined
                                    : Icons.publish_outlined,
                              ),
                              label: Text(published ? 'Unpublish' : 'Publish'),
                            ),
                            TextButton.icon(
                              onPressed: _saving
                                  ? null
                                  : () => _run(
                                      () => _api.deleteAnnouncement(
                                        item['id'].toString(),
                                      ),
                                      success: 'Announcement deleted.',
                                    ),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        )
                      else if (!isRead)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _saving
                                ? null
                                : () => _run(
                                    () => _api.markAnnouncementRead(
                                      item['id'].toString(),
                                    ),
                                    success: 'Announcement marked as read.',
                                  ),
                            icon: const Icon(Icons.done),
                            label: const Text('Mark as read'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
  );

  Widget _leaveForm() => _panel(
    title: 'Apply for leave',
    subtitle:
        'Submit leave dates and reason. Student applications are sent to your assigned teacher.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 210,
              child: DropdownButtonFormField<String>(
                initialValue: _leaveType,
                decoration: const InputDecoration(labelText: 'Leave type'),
                items:
                    const [
                          'Personal',
                          'Medical',
                          'Family',
                          'Emergency',
                          'Other',
                        ]
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                onChanged: (value) =>
                    setState(() => _leaveType = value ?? 'Personal'),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _selectDate(forStart: true),
              icon: const Icon(Icons.date_range),
              label: Text('Start: ${_date(_startDate)}'),
            ),
            OutlinedButton.icon(
              onPressed: () => _selectDate(forStart: false),
              icon: const Icon(Icons.event),
              label: Text('End: ${_date(_endDate)}'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _reason,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _saving ? null : _uploadDocument,
              icon: const Icon(Icons.attach_file),
              label: Text(_documentName ?? 'Supporting document (optional)'),
            ),
            if (_documentName != null)
              IconButton(
                onPressed: () => setState(() {
                  _documentUrl = null;
                  _documentName = null;
                }),
                icon: const Icon(Icons.close),
                tooltip: 'Remove document',
              ),
            FilledButton.icon(
              onPressed: _saving ? null : _submitLeave,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Submit application'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _assignmentPanel() => _panel(
    title: 'Student teacher assignments',
    subtitle:
        'Assign an advisor so student leave applications reach the correct teacher.',
    child: _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: DropdownButtonFormField<String>(
                      initialValue: _assignmentStudent,
                      decoration: const InputDecoration(labelText: 'Student'),
                      items: _students
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item['id'].toString(),
                              child: Text(
                                '${item['name']} • ${item['rollNumber'] ?? item['email']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        _assignmentStudent = value;
                        final assigned = _students
                            .where(
                              (student) => student['id'].toString() == value,
                            )
                            .map(
                              (student) =>
                                  student['assignedTeacherId']?.toString(),
                            )
                            .toList();
                        _assignmentTeacher = assigned.isEmpty
                            ? null
                            : assigned.first;
                      }),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: DropdownButtonFormField<String>(
                      initialValue: _assignmentTeacher,
                      decoration: const InputDecoration(
                        labelText: 'Assigned teacher',
                      ),
                      items: _teachers
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item['id'].toString(),
                              child: Text(
                                '${item['name']} • ${item['instructorId'] ?? item['email']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _assignmentTeacher = value),
                    ),
                  ),
                  FilledButton(
                    onPressed: _saving ? null : _assignTeacher,
                    child: const Text('Assign'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._students.map(
                (student) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.person_outline),
                  title: Text(student['name']?.toString() ?? ''),
                  subtitle: Text(
                    'Teacher: ${student['assignedTeacherName'] ?? 'Not assigned'}',
                  ),
                ),
              ),
            ],
          ),
  );

  Widget _leaveList() => _panel(
    title: _isAdmin
        ? 'Institute leave records'
        : _isTeacher
        ? 'Leave requests and history'
        : 'My leave history',
    subtitle: _isAdmin
        ? 'Review teacher requests and track student approval stages.'
        : 'Status and reviewer remarks are updated from the shared backend.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                initialValue: _statusFilter,
                decoration: const InputDecoration(
                  labelText: 'Filter by status',
                ),
                items: const [
                  DropdownMenuItem(value: '', child: Text('All statuses')),
                  DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                  DropdownMenuItem(
                    value: 'WAITING_ADMIN',
                    child: Text('Waiting for Admin'),
                  ),
                  DropdownMenuItem(value: 'APPROVED', child: Text('Approved')),
                  DropdownMenuItem(value: 'REJECTED', child: Text('Rejected')),
                ],
                onChanged: (value) {
                  setState(() => _statusFilter = value ?? '');
                  _load();
                },
              ),
            ),
            if (_isAdmin)
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  initialValue: _applicantRoleFilter,
                  decoration: const InputDecoration(
                    labelText: 'Applicant role',
                  ),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All applicants')),
                    DropdownMenuItem(value: 'student', child: Text('Students')),
                    DropdownMenuItem(value: 'teacher', child: Text('Teachers')),
                  ],
                  onChanged: (value) {
                    setState(() => _applicantRoleFilter = value ?? '');
                    _load();
                  },
                ),
              ),
            SizedBox(
              width: 260,
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  labelText: 'Search name or email',
                  suffixIcon: IconButton(
                    onPressed: _load,
                    icon: const Icon(Icons.search),
                  ),
                ),
                onSubmitted: (_) => _load(),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _selectFilterDate(from: true),
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                _filterFrom == null
                    ? 'From date'
                    : 'From: ${_date(_filterFrom!)}',
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _selectFilterDate(from: false),
              icon: const Icon(Icons.event_outlined),
              label: Text(
                _filterTo == null ? 'To date' : 'To: ${_date(_filterTo!)}',
              ),
            ),
            if (_filterFrom != null || _filterTo != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterFrom = null;
                    _filterTo = null;
                  });
                  _load();
                },
                child: const Text('Clear dates'),
              ),
            IconButton(
              onPressed: _load,
              tooltip: 'Refresh applications',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_leaves.isEmpty)
          const _EmptyState('No leave applications found.')
        else
          ..._leaves.map(_leaveCard),
      ],
    ),
  );

  Widget _leaveCard(Map<String, dynamic> item) {
    final applicant =
        (item['applicant'] as Map?)?.cast<String, dynamic>() ?? {};
    final applicantRole = applicant['role']?.toString().toLowerCase() ?? '';
    final status = item['status']?.toString() ?? 'PENDING';
    final canReview =
        (_isTeacher && applicantRole == 'student' && status == 'PENDING') ||
        (_isAdmin &&
            ((applicantRole == 'teacher' && status == 'PENDING') ||
                (applicantRole == 'student' && status == 'WAITING_ADMIN')));
    final histories =
        (item['approvalHistory'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final documentUrl = item['documentUrl']?.toString();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: item['id'].toString() == widget.targetId,
        leading: Icon(Icons.event_note_outlined, color: _statusColor(status)),
        title: Text(
          '${applicant['name'] ?? 'Applicant'} • ${item['leaveType'] ?? 'Leave'}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${item['startDate']} – ${item['endDate']}  •  ${status.replaceAll('_', ' ')}',
        ),
        trailing: _badge(status.replaceAll('_', ' ')),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${applicant['role']?.toString().toUpperCase() ?? ''} • ${applicant['email'] ?? ''}'
                  '${applicant['rollNumber'] == null ? '' : ' • Roll ${applicant['rollNumber']}'}',
                ),
                const SizedBox(height: 8),
                Text(item['reason']?.toString() ?? ''),
                if (documentUrl != null && documentUrl.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(documentUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open supporting document'),
                  ),
                if (histories.isNotEmpty) ...[
                  const Divider(),
                  const Text(
                    'Approval history',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  ...histories.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${entry['decision']} by ${entry['reviewer']}'
                        '${entry['remark'] == null || entry['remark'].toString().isEmpty ? '' : ' — ${entry['remark']}'}'
                        ' • ${entry['reviewedAt']}',
                      ),
                    ),
                  ),
                ],
                if (canReview)
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _saving
                            ? null
                            : () => _decide(item, 'REJECTED'),
                        icon: const Icon(Icons.close, color: AppColors.error),
                        label: const Text('Reject'),
                      ),
                      FilledButton.icon(
                        onPressed: _saving
                            ? null
                            : () => _decide(item, 'APPROVED'),
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({
    required String title,
    required String subtitle,
    required Widget child,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );

  Widget _badge(String text) {
    final color = _statusColor(text);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final value = status.toUpperCase();
    if (value.contains('APPROV') || value == 'PUBLISHED' || value == 'READ') {
      return AppColors.success;
    }
    if (value.contains('REJECT')) {
      return AppColors.error;
    }
    if (value.contains('PENDING') ||
        value.contains('WAITING') ||
        value == 'UNREAD') {
      return AppColors.warning;
    }
    return AppColors.info;
  }

  Widget _message(String message, Color background, Color color) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(message, style: TextStyle(color: color)),
  );
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState(this.message);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: Text(message, style: const TextStyle(color: AppColors.textMuted)),
    ),
  );
}
