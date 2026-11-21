import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../services/api_service.dart';
import 'classroom_detail_screen.dart';
import 'assignment_view_screen.dart';

class ClassroomHubScreen extends StatefulWidget {
  final String userRole; // student, teacher, admin
  final VoidCallback? onBack;

  const ClassroomHubScreen({
    super.key,
    required this.userRole,
    this.onBack,
  });

  @override
  State<ClassroomHubScreen> createState() => _ClassroomHubScreenState();
}

class _ClassroomHubScreenState extends State<ClassroomHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _myClassrooms = [];
  List<Map<String, dynamic>> _publicClassrooms = [];
  List<Map<String, dynamic>> _upcomingLiveClasses = [];
  Map<String, dynamic>? _todoData;
  bool _loading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 4 tabs: Classes, To-do, Live Classes, Discover
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final isStudent = widget.userRole == 'student';
      final results = await Future.wait([
        _apiService.getClassrooms(),
        _apiService.searchPublicClassrooms(query: _searchQuery),
        _apiService.getUpcomingLiveClasses(),
        if (isStudent) _apiService.getStudentTodoList() else Future.value(<String, dynamic>{}),
      ]);

      if (!mounted) return;
      setState(() {
        _myClassrooms = results[0] as List<Map<String, dynamic>>;
        _publicClassrooms = results[1] as List<Map<String, dynamic>>;
        _upcomingLiveClasses = results[2] as List<Map<String, dynamic>>;
        _todoData = results[3] as Map<String, dynamic>;
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

  void _showJoinClassDialog() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.meeting_room_outlined, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Join Classroom', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ask your instructor for the 6-8 character class code, then enter it below.',
                      style: TextStyle(color: AppColors.textMain, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Class Code',
                hintText: 'e.g. 7XK9MP',
                helperText: 'Use letters and numbers with no spaces',
                prefixIcon: const Icon(Icons.vpn_key),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.isEmpty) return;
              Navigator.pop(ctx);
              try {
                final res = await _apiService.joinClassroom(code);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res['message'] ?? 'Enrolled successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadAllData();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showCreateClassDialog() {
    final nameController = TextEditingController();
    final sectionController = TextEditingController();
    final subjectController = TextEditingController();
    final roomController = TextEditingController();
    final descController = TextEditingController();
    bool isPublic = false;
    bool requiresApproval = false;
    String selectedColor = '#1967d2';

    final colors = [
      '#1967d2', // Google Blue
      '#137333', // Google Green
      '#c5221f', // Google Red
      '#f29900', // Google Orange
      '#7b1fa2', // Purple
      '#00796b', // Teal
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.add_business_outlined, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Create Classroom', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Class Name (required)',
                      hintText: 'e.g. Advanced Operating Systems',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: sectionController,
                          decoration: InputDecoration(
                            labelText: 'Section',
                            hintText: 'e.g. Batch A / 2026',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: roomController,
                          decoration: InputDecoration(
                            labelText: 'Room',
                            hintText: 'e.g. Lab 3 / Online',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      hintText: 'e.g. Computer Science',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Course overview and learning goals...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Classroom Theme Color:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: colors.map((hex) {
                      final c = Color(int.parse(hex.replaceFirst('#', '0xff')));
                      final isSel = selectedColor == hex;
                      return GestureDetector(
                        onTap: () => setDlgState(() => selectedColor = hex),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isSel ? Border.all(color: Colors.black, width: 2.5) : null,
                          ),
                          child: isSel ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Make Publicly Discoverable', style: TextStyle(fontSize: 13)),
                    subtitle: const Text('Visible in public catalog for all students', style: TextStyle(fontSize: 11)),
                    value: isPublic,
                    onChanged: (val) => setDlgState(() => isPublic = val ?? false),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Require Teacher Approval', style: TextStyle(fontSize: 13)),
                    subtitle: const Text('Hold new student enrollment requests in approval queue', style: TextStyle(fontSize: 11)),
                    value: requiresApproval,
                    onChanged: (val) => setDlgState(() => requiresApproval = val ?? false),
                  ),
                ],
              ),
            ),
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
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                try {
                  await _apiService.createClassroom({
                    'name': name,
                    'section': sectionController.text.trim(),
                    'subject': subjectController.text.trim(),
                    'room': roomController.text.trim(),
                    'description': descController.text.trim(),
                    'themeColor': selectedColor,
                    'isPublic': isPublic,
                    'requiresApproval': requiresApproval,
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Classroom created successfully!'), backgroundColor: Colors.green),
                  );
                  _loadAllData();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
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
    } catch (_) {
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
    final isTeacherOrAdmin = widget.userRole == 'teacher' || widget.userRole == 'admin';

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Google Classroom Tab Strip & Fast Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textMuted,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.class_outlined, size: 18),
                        text: 'Classes (${_myClassrooms.length})',
                      ),
                      Tab(
                        icon: const Icon(Icons.assignment_turned_in_outlined, size: 18),
                        text: widget.userRole == 'student' ? 'To-do' : 'To Review',
                      ),
                      Tab(
                        icon: const Icon(Icons.video_call_outlined, size: 18),
                        text: 'Live Classes (${_upcomingLiveClasses.length})',
                      ),
                      Tab(
                        icon: const Icon(Icons.explore_outlined, size: 18),
                        text: 'Discover (${_publicClassrooms.length})',
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.textMain, size: 20),
                  tooltip: 'Refresh',
                  onPressed: _loadAllData,
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  icon: const Icon(Icons.vpn_key_outlined, size: 16),
                  label: const Text('Join Class'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onPressed: _showJoinClassDialog,
                ),
                if (isTeacherOrAdmin) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Class'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: _showCreateClassDialog,
                  ),
                ],
              ],
            ),
          ),

          // Body Views
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 12),
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: _loadAllData, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildMyClassesTab(),
                          _buildTodoTab(),
                          _buildLiveClassesTab(),
                          _buildDiscoverTab(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  // Authentic Google Classroom Cards Grid
  Widget _buildMyClassesTab() {
    if (_myClassrooms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school_outlined, size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              const Text(
                'Don’t see your existing classes?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try joining a class with an invitation code, or create a new class to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.vpn_key),
                    label: const Text('Join with Code'),
                    onPressed: _showJoinClassDialog,
                  ),
                  if (widget.userRole == 'teacher' || widget.userRole == 'admin') ...[
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Create Classroom'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _showCreateClassDialog,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1100
            ? 3
            : constraints.maxWidth > 700
                ? 2
                : 1;

        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.35,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: _myClassrooms.length,
          itemBuilder: (ctx, idx) => _buildClassCard(_myClassrooms[idx]),
        );
      },
    );
  }

  Widget _buildClassCard(Map<String, dynamic> c) {
    final hexColor = c['themeColor'] as String? ?? '#1967d2';
    final themeColor = Color(int.parse(hexColor.replaceFirst('#', '0xff')));
    final studentCount = c['studentCount'] ?? 0;
    final myRole = c['myRole'] ?? 'STUDENT';
    final invitationCode = c['invitationCode'] ?? '';
    final creatorName = c['creatorName'] ?? 'Instructor';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => ClassroomDetailScreen(
                classroomId: c['id'].toString(),
                userRole: widget.userRole,
              ),
            ),
          ).then((_) => _loadAllData());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header Banner (Google Classroom Style)
            Container(
              padding: const EdgeInsets.all(16),
              color: themeColor,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              c['name'] ?? 'Classroom',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              myRole,
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${c['subject'] ?? ''} ${c['section'] != null && c['section'].toString().isNotEmpty ? '• ${c['section']}' : ''}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Instructor: $creatorName',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    bottom: -28,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: themeColor,
                        child: Text(
                          creatorName.isNotEmpty ? creatorName[0].toUpperCase() : 'T',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body: Upcoming work snippet & stats
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      c['description'] != null && c['description'].toString().isNotEmpty
                          ? c['description']
                          : 'Participate in live Google Meet classes, submit coursework, and access lecture resources.',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Bottom action strip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.people_outline, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text('$studentCount students', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                        if (invitationCode.isNotEmpty)
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: invitationCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Class code $invitationCode copied!')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.copy, size: 12, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    invitationCode,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Google Classroom To-do View
  Widget _buildTodoTab() {
    final assignedList = (_todoData?['assigned'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final missingList = (_todoData?['missing'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final doneList = (_todoData?['done'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Assigned (${assignedList.length})'),
                Tab(text: 'Missing (${missingList.length})'),
                Tab(text: 'Done (${doneList.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildTodoList(assignedList, emptyMsg: 'Woohoo, no work due soon!', isMissing: false),
                _buildTodoList(missingList, emptyMsg: 'No missing assignments. Great job staying on top of your work!', isMissing: true),
                _buildTodoList(doneList, emptyMsg: 'No completed assignments yet.', isDone: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(List<Map<String, dynamic>> items, {required String emptyMsg, bool isMissing = false, bool isDone = false}) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isDone ? Icons.task_alt : Icons.done_all, size: 54, color: isDone ? Colors.green : AppColors.textMuted),
              const SizedBox(height: 12),
              Text(emptyMsg, style: const TextStyle(fontSize: 14, color: AppColors.textMuted), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (ctx, idx) {
        final a = items[idx];
        final classroomName = a['classroomName'] ?? 'Classroom';
        final themeColorHex = a['classroomThemeColor'] as String? ?? '#1967d2';
        final themeColor = Color(int.parse(themeColorHex.replaceFirst('#', '0xff')));
        final title = a['title'] ?? 'Assignment';
        final dueDate = a['dueDate'];
        final score = a['myScore'];
        final points = a['pointsPossible'] ?? 100;

        String dueFormatted = 'No due date';
        if (dueDate != null) {
          try {
            final dt = DateTime.parse(dueDate.toString());
            dueFormatted = 'Due ${dt.day}/${dt.month} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
          } catch (_) {
            dueFormatted = 'Due $dueDate';
          }
        }

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
                    classroomId: a['classroomId'].toString(),
                    userRole: widget.userRole,
                  ),
                ),
              ).then((_) => _loadAllData());
            },
            leading: CircleAvatar(
              backgroundColor: themeColor.withValues(alpha: 0.15),
              child: Icon(Icons.assignment, color: themeColor),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(
              '$classroomName • $dueFormatted',
              style: TextStyle(
                fontSize: 12,
                color: isMissing ? AppColors.error : AppColors.textMuted,
                fontWeight: isMissing ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDone && score != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Text(
                      '$score / $points',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                    ),
                  ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }

  // Google Meet Live Online Classes
  Widget _buildLiveClassesTab() {
    if (_upcomingLiveClasses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.video_call_outlined, size: 64, color: Colors.green),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Upcoming Live Classes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
              const SizedBox(height: 8),
              const Text(
                'When teachers schedule Google Meet sessions, they will appear here automatically.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _upcomingLiveClasses.length,
      itemBuilder: (ctx, idx) {
        final lc = _upcomingLiveClasses[idx];
        final isLiveNow = lc['isLiveNow'] == true;
        final meetLink = lc['meetLink'] as String? ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          elevation: isLiveNow ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isLiveNow ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isLiveNow ? Colors.green.shade100 : const Color(0xFFE8F0FE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.video_camera_front,
                    color: isLiveNow ? Colors.green.shade800 : AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isLiveNow)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('LIVE NOW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          Text(
                            lc['title'] ?? 'Live Online Class',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Class: ${lc['classroomName'] ?? ''} • Instructor: ${lc['hostName'] ?? ''}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Time: ${lc['startTime']} - ${lc['endTime']}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(isLiveNow ? 'Join Meet Now' : 'Join Link'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLiveNow ? Colors.green : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    try {
                      final joinRes = await _apiService.joinLiveClass(lc['id'].toString());
                      final link = joinRes['meetLink'] ?? meetLink;
                      _launchUrl(link);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Attendance recorded! Opening Google Meet...'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Discover Public Classrooms
  Widget _buildDiscoverTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search public classrooms by subject, title or keyword...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _loadAllData,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (val) => _searchQuery = val,
            onSubmitted: (_) => _loadAllData(),
          ),
        ),
        Expanded(
          child: _publicClassrooms.isEmpty
              ? const Center(
                  child: Text('No public classrooms match your search query.', style: TextStyle(color: AppColors.textMuted)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _publicClassrooms.length,
                  itemBuilder: (ctx, idx) {
                    final c = _publicClassrooms[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            (c['name'] as String? ?? 'C').substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${c['subject'] ?? ''} • Instructor: ${c['creatorName'] ?? ''}\n${c['description'] ?? ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final code = c['invitationCode'] as String? ?? '';
                            if (code.isEmpty) return;
                            try {
                              final res = await _apiService.joinClassroom(code);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(res['message'] ?? 'Enrolled!'), backgroundColor: Colors.green),
                              );
                              _loadAllData();
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
                              );
                            }
                          },
                          child: const Text('Enroll'),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
