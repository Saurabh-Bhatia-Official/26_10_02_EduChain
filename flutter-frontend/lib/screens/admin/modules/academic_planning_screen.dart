import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/status_badge.dart';

class AcademicMilestone {
  final String id;
  final String title;
  final String dateRange;
  final String description;
  String status; // 'completed', 'active', 'upcoming', 'scheduled'
  final IconData icon;

  AcademicMilestone({
    required this.id,
    required this.title,
    required this.dateRange,
    required this.description,
    required this.status,
    required this.icon,
  });
}

class AcademicPlanningScreen extends StatefulWidget {
  final Function(String screenName, {String? param})? onNavigate;

  const AcademicPlanningScreen({super.key, this.onNavigate});

  @override
  State<AcademicPlanningScreen> createState() => _AcademicPlanningScreenState();
}

class _AcademicPlanningScreenState extends State<AcademicPlanningScreen> {
  String _selectedSession = 'Spring 2025 (Jan – Jun)';

  late List<AcademicMilestone> _milestones;

  @override
  void initState() {
    super.initState();
    _milestones = [
      AcademicMilestone(
        id: 'ms_1',
        title: 'Semester Commencement & Registration',
        dateRange: 'Jan 15, 2025',
        description: 'Student course registrations, section enrollment, and faculty orientation.',
        status: 'completed',
        icon: Icons.flag_outlined,
      ),
      AcademicMilestone(
        id: 'ms_2',
        title: 'Mid-Term Examination Window',
        dateRange: 'May 05 – May 16, 2025',
        description: 'Campus-wide mid-semester written assessments and continuous evaluation.',
        status: 'active',
        icon: Icons.edit_note,
      ),
      AcademicMilestone(
        id: 'ms_3',
        title: 'Lab & Practical Assessments',
        dateRange: 'June 01 – June 10, 2025',
        description: 'Hands-on practical exams, viva-voce, and software laboratory submissions.',
        status: 'upcoming',
        icon: Icons.science_outlined,
      ),
      AcademicMilestone(
        id: 'ms_4',
        title: 'Final Semester Examinations',
        dateRange: 'June 20 – July 05, 2025',
        description: 'End-term written university evaluations scheduled across main exam halls.',
        status: 'scheduled',
        icon: Icons.assignment_turned_in_outlined,
      ),
      AcademicMilestone(
        id: 'ms_5',
        title: 'Grade Cards Publication & Convocation Prep',
        dateRange: 'July 15, 2025',
        description: 'Final grade point moderation, transcript publishing, and term close.',
        status: 'scheduled',
        icon: Icons.school_outlined,
      ),
    ];
  }

  void _showAddMilestoneDialog() {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: 'July 25, 2025');
    final descCtrl = TextEditingController();
    String status = 'scheduled';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Academic Milestone', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Milestone Title *', hintText: 'e.g. Summer Internship Presentation'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: dateCtrl,
                  decoration: const InputDecoration(labelText: 'Date Range *', hintText: 'e.g. July 25 – August 05, 2025'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                    DropdownMenuItem(value: 'active', child: Text('Active / In Progress')),
                    DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  ],
                  onChanged: (v) => setDialogState(() => status = v ?? 'scheduled'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description', hintText: 'Short details about this milestone'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                setState(() {
                  _milestones.add(
                    AcademicMilestone(
                      id: 'ms_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim(),
                      dateRange: dateCtrl.text.trim(),
                      description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : 'Academic milestone event.',
                      status: status,
                      icon: Icons.event_available,
                    ),
                  );
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Academic milestone saved!'), backgroundColor: AppColors.success),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
              child: const Text('Save Milestone'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAcademicCalendarModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.calendar_month, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Master Academic Calendar (2025)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCalendarEventItem('Jan 15', 'Semester Start', 'Regular teaching commences for all departments.', AppColors.success),
                _buildCalendarEventItem('Mar 24 - 26', 'Holi Festival Break', 'Institutional holiday, campus closed.', AppColors.warning),
                _buildCalendarEventItem('May 05 - 16', 'Mid-Term Examinations', 'No regular lectures during morning exam slot.', AppColors.primary),
                _buildCalendarEventItem('Jun 01 - 10', 'Lab Practical Submissions', 'Computer and Physics laboratories.', AppColors.accentTeal),
                _buildCalendarEventItem('Jun 20 - Jul 05', 'End-Term Theory Exams', 'Final university examinations.', AppColors.studentPrimary),
                _buildCalendarEventItem('Jul 15', 'Grade Publishing', 'Official SGPA/CGPA cards published on student portal.', AppColors.accentGreen),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
            child: const Text('Close Calendar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarEventItem(String date, String title, String sub, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
              child: Text(date, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Academic Planning & Semester Management',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Reorganize and orchestrate semester terms, academic calendar, milestones, lecture timetables, and assessments.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedSession,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'Spring 2025 (Jan – Jun)', child: Text('Spring 2025 (Jan – Jun)')),
                    DropdownMenuItem(value: 'Fall 2025 (Jul – Dec)', child: Text('Fall 2025 (Jul – Dec)')),
                    DropdownMenuItem(value: 'Annual 2025–2026', child: Text('Annual 2025–2026')),
                  ],
                  onChanged: (v) => setState(() => _selectedSession = v ?? _selectedSession),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _showAddMilestoneDialog,
                  icon: const Icon(Icons.add_task, size: 16),
                  label: const Text('Add Milestone'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 2 Main Feature Cards (matching screenshot design)
        Row(
          children: [
            // Card 1: Lecture Schedule
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.schedule, color: AppColors.primary, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Lecture Schedule', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textMain)),
                              SizedBox(height: 2),
                              Text('Create, edit, and publish weekly lecture timetables.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Manage classroom allocations, conflict-free faculty schedules, and batch rosters campus-wide.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMain, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (widget.onNavigate != null) widget.onNavigate!('lecture-schedule');
                            },
                            child: const Text('View Schedule'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.onNavigate != null) widget.onNavigate!('lecture-schedule');
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            child: const Text('Manage'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Card 2: Exam Timetable
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.studentPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.assignment_outlined, color: AppColors.studentPrimary, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Exam Timetable', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textMain)),
                              SizedBox(height: 2),
                              Text('Create, view, and publish exam schedules easily.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Coordinate midterm and university final assessment halls, invigilators, and student seating charts.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMain, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (widget.onNavigate != null) widget.onNavigate!('exam-timetable');
                            },
                            child: const Text('View Timetable'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.onNavigate != null) widget.onNavigate!('create-exam');
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.studentPrimary),
                            child: const Text('Schedule Exam'),
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
        const SizedBox(height: 24),

        // Semester Timeline & Milestones Section
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Academic Roadmap & Key Milestones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('$_selectedSession Roadmap Progression', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: _showAcademicCalendarModal,
                    icon: const Icon(Icons.calendar_month, size: 16),
                    label: const Text('View Full Calendar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Milestone list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _milestones.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ms = _milestones[index];
                  Color stateColor = ms.status == 'completed'
                      ? AppColors.success
                      : (ms.status == 'active' ? AppColors.primary : AppColors.textMuted);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgPage,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: stateColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(ms.icon, color: stateColor, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ms.title,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMain),
                                  ),
                                  StatusBadge(label: ms.status.toUpperCase(), status: ms.status),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.date_range, size: 13, color: AppColors.textLight),
                                  const SizedBox(width: 4),
                                  Text(ms.dateRange, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(ms.description, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quick Actions & Graphic Banner Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Column: Quick Action rows
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Planning Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    _buildQuickActionRow(
                      icon: Icons.schedule,
                      label: 'Create Lecture Schedule',
                      color: AppColors.primary,
                      onTap: () {
                        if (widget.onNavigate != null) widget.onNavigate!('lecture-schedule');
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildQuickActionRow(
                      icon: Icons.assignment_add,
                      label: 'Create Exam Timetable',
                      color: AppColors.studentPrimary,
                      onTap: () {
                        if (widget.onNavigate != null) widget.onNavigate!('create-exam');
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildQuickActionRow(
                      icon: Icons.class_outlined,
                      label: 'Manage Classes & Batches',
                      color: AppColors.teacherPrimary,
                      onTap: () {
                        if (widget.onNavigate != null) widget.onNavigate!('class-management');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Column: Academic Session Graphic
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.school, size: 48, color: AppColors.primary),
                      const SizedBox(height: 12),
                      const Text(
                        'Academic Session 2025–2026',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Accredited by AICTE & UGC • Grade A+ NAAC',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionRow({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textMain))),
            const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
