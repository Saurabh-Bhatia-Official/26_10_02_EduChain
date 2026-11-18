import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/lecture_slot_model.dart';
import '../../../widgets/status_badge.dart';

class LectureScheduleScreen extends StatefulWidget {
  final String? initialClassFilter;
  final Function(String screenName, {String? param})? onNavigate;

  const LectureScheduleScreen({
    super.key,
    this.initialClassFilter,
    this.onNavigate,
  });

  @override
  State<LectureScheduleScreen> createState() => _LectureScheduleScreenState();
}

class _LectureScheduleScreenState extends State<LectureScheduleScreen> {
  late String _selectedClass;
  String _selectedSemester = 'All';
  String _selectedDay = 'All';
  String _selectedRoom = 'All';
  String _viewMode = 'table'; // 'table' or 'grid'

  late List<LectureSlotModel> _slots;

  @override
  void initState() {
    super.initState();
    _selectedClass = widget.initialClassFilter ?? 'All';
    _initDefaultSlots();
  }

  void _initDefaultSlots() {
    _slots = [
      LectureSlotModel(
        id: 'slot_1',
        day: 'Mon',
        timeSlot: '09:00 AM - 10:00 AM',
        subject: 'Database Management Systems',
        subjectCode: 'CS-301',
        instructor: 'Dr. Amit Sharma',
        room: 'Hall 101',
        className: 'BCA-301',
        semester: 'Semester 3',
        status: 'Scheduled',
      ),
      LectureSlotModel(
        id: 'slot_2',
        day: 'Mon',
        timeSlot: '10:15 AM - 11:15 AM',
        subject: 'Data Structures & Algorithms',
        subjectCode: 'CS-302',
        instructor: 'Prof. Rajesh Gupta',
        room: 'Hall 202',
        className: 'BCA-301',
        semester: 'Semester 3',
        status: 'Scheduled',
      ),
      LectureSlotModel(
        id: 'slot_3',
        day: 'Mon',
        timeSlot: '11:30 AM - 01:00 PM',
        subject: 'Database Systems Lab Practicals',
        subjectCode: 'CS-301L',
        instructor: 'Dr. Amit Sharma',
        room: 'Computer Lab 1',
        className: 'BCA-301',
        semester: 'Semester 3',
        status: 'Scheduled',
      ),
      LectureSlotModel(
        id: 'slot_4',
        day: 'Tue',
        timeSlot: '09:00 AM - 10:00 AM',
        subject: 'Operating Systems Architecture',
        subjectCode: 'CS-303',
        instructor: 'Prof. Sunita Rao',
        room: 'Hall 105',
        className: 'BCA-301',
        semester: 'Semester 3',
        status: 'Scheduled',
      ),
      LectureSlotModel(
        id: 'slot_5',
        day: 'Tue',
        timeSlot: '10:15 AM - 11:15 AM',
        subject: 'Discrete Mathematics & Logic',
        subjectCode: 'MATH-201',
        instructor: 'Prof. Sunita Rao',
        room: 'Hall 103',
        className: 'MATH-201',
        semester: 'Semester 2',
        status: 'Scheduled',
      ),
      LectureSlotModel(
        id: 'slot_6',
        day: 'Wed',
        timeSlot: '09:00 AM - 10:00 AM',
        subject: 'Advanced Software Engineering',
        subjectCode: 'MCA-101',
        instructor: 'Dr. Amit Sharma',
        room: 'Hall 302',
        className: 'MCA-101',
        semester: 'Semester 1',
        status: 'Scheduled',
      ),
      LectureSlotModel(
        id: 'slot_7',
        day: 'Wed',
        timeSlot: '10:15 AM - 11:15 AM',
        subject: 'Artificial Intelligence & Neural Nets',
        subjectCode: 'CS-401',
        instructor: 'Dr. Vikram Malhotra',
        room: 'Computer Lab 2',
        className: 'BCA-305',
        semester: 'Semester 5',
        status: 'Scheduled',
      ),
      LectureSlotModel(
        id: 'slot_8',
        day: 'Thu',
        timeSlot: '09:00 AM - 10:00 AM',
        subject: 'Quantum Mechanics & Modern Physics',
        subjectCode: 'PHY-101',
        instructor: 'Dr. Neha Kapoor',
        room: 'Hall 201',
        className: 'PHY-101',
        semester: 'Semester 1',
        status: 'Scheduled',
      ),
      LectureSlotModel(
        id: 'slot_9',
        day: 'Fri',
        timeSlot: '11:15 AM - 12:45 PM',
        subject: 'Data Structures Practical Lab',
        subjectCode: 'CS-302L',
        instructor: 'Prof. Rajesh Gupta',
        room: 'Computer Lab 1',
        className: 'BCA-301',
        semester: 'Semester 3',
        status: 'Scheduled',
      ),
      LectureSlotModel(
        id: 'slot_10',
        day: 'Sat',
        timeSlot: '10:00 AM - 11:30 AM',
        subject: 'Technical Seminar & Industry Project',
        subjectCode: 'CS-399',
        instructor: 'Dr. Amit Sharma',
        room: 'Auditorium Hall',
        className: 'BCA-301',
        semester: 'Semester 3',
        status: 'Scheduled',
      ),
    ];
  }

  List<LectureSlotModel> get _filteredSlots {
    return _slots.where((slot) {
      if (_selectedClass != 'All' && slot.className != _selectedClass) {
        return false;
      }
      if (_selectedSemester != 'All' && slot.semester != _selectedSemester) {
        return false;
      }
      if (_selectedDay != 'All' && slot.day != _selectedDay) {
        return false;
      }
      if (_selectedRoom != 'All' && slot.room != _selectedRoom) {
        return false;
      }
      return true;
    }).toList();
  }

  void _showAddOrEditSlotDialog([LectureSlotModel? existing]) {
    final isEdit = existing != null;
    String day = existing?.day ?? 'Mon';
    final timeCtrl = TextEditingController(text: existing?.timeSlot ?? '09:00 AM - 10:00 AM');
    final subjCtrl = TextEditingController(text: existing?.subject ?? '');
    final codeCtrl = TextEditingController(text: existing?.subjectCode ?? '');
    String cls = existing?.className ?? 'BCA-301';
    String sem = existing?.semester ?? 'Semester 3';
    String instructor = existing?.instructor ?? 'Dr. Amit Sharma';
    String room = existing?.room ?? 'Hall 101';
    String status = existing?.status ?? 'Scheduled';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEdit ? 'Edit Lecture Slot' : 'Add Lecture Schedule Slot',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              if (!isEdit)
                TextButton.icon(
                  onPressed: () {
                    setDialogState(() {
                      day = 'Mon';
                      timeCtrl.text = '01:30 PM - 02:30 PM';
                      subjCtrl.text = 'Cloud Architecture & Microservices';
                      codeCtrl.text = 'CS-308';
                      cls = 'BCA-301';
                      sem = 'Semester 3';
                      instructor = 'Prof. Rajesh Gupta';
                      room = 'Hall 202';
                      status = 'Scheduled';
                    });
                  },
                  icon: const Icon(Icons.auto_awesome, size: 14),
                  label: const Text('Demo Fill', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: day,
                          decoration: const InputDecoration(labelText: 'Day of Week *'),
                          items: const [
                            DropdownMenuItem(value: 'Mon', child: Text('Monday (Mon)')),
                            DropdownMenuItem(value: 'Tue', child: Text('Tuesday (Tue)')),
                            DropdownMenuItem(value: 'Wed', child: Text('Wednesday (Wed)')),
                            DropdownMenuItem(value: 'Thu', child: Text('Thursday (Thu)')),
                            DropdownMenuItem(value: 'Fri', child: Text('Friday (Fri)')),
                            DropdownMenuItem(value: 'Sat', child: Text('Saturday (Sat)')),
                          ],
                          onChanged: (v) => setDialogState(() => day = v ?? 'Mon'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: timeCtrl,
                          decoration: const InputDecoration(labelText: 'Time Slot *', hintText: '09:00 AM - 10:00 AM'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: subjCtrl,
                          decoration: const InputDecoration(labelText: 'Subject Name *', hintText: 'e.g. Database Systems'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: codeCtrl,
                          decoration: const InputDecoration(labelText: 'Subject Code *', hintText: 'e.g. CS-301'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: cls,
                          decoration: const InputDecoration(labelText: 'Class / Batch *'),
                          items: const [
                            DropdownMenuItem(value: 'BCA-301', child: Text('BCA-301')),
                            DropdownMenuItem(value: 'BCA-302', child: Text('BCA-302')),
                            DropdownMenuItem(value: 'BCA-305', child: Text('BCA-305')),
                            DropdownMenuItem(value: 'MCA-101', child: Text('MCA-101')),
                            DropdownMenuItem(value: 'MATH-201', child: Text('MATH-201')),
                            DropdownMenuItem(value: 'PHY-101', child: Text('PHY-101')),
                          ],
                          onChanged: (v) => setDialogState(() => cls = v ?? 'BCA-301'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: sem,
                          decoration: const InputDecoration(labelText: 'Semester *'),
                          items: const [
                            DropdownMenuItem(value: 'Semester 1', child: Text('Semester 1')),
                            DropdownMenuItem(value: 'Semester 2', child: Text('Semester 2')),
                            DropdownMenuItem(value: 'Semester 3', child: Text('Semester 3')),
                            DropdownMenuItem(value: 'Semester 4', child: Text('Semester 4')),
                            DropdownMenuItem(value: 'Semester 5', child: Text('Semester 5')),
                          ],
                          onChanged: (v) => setDialogState(() => sem = v ?? 'Semester 3'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: instructor,
                          decoration: const InputDecoration(labelText: 'Faculty Instructor *'),
                          items: const [
                            DropdownMenuItem(value: 'Dr. Amit Sharma', child: Text('Dr. Amit Sharma')),
                            DropdownMenuItem(value: 'Prof. Sunita Rao', child: Text('Prof. Sunita Rao')),
                            DropdownMenuItem(value: 'Prof. Rajesh Gupta', child: Text('Prof. Rajesh Gupta')),
                            DropdownMenuItem(value: 'Dr. Vikram Malhotra', child: Text('Dr. Vikram Malhotra')),
                            DropdownMenuItem(value: 'Dr. Neha Kapoor', child: Text('Dr. Neha Kapoor')),
                          ],
                          onChanged: (v) => setDialogState(() => instructor = v ?? 'Dr. Amit Sharma'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: room,
                          decoration: const InputDecoration(labelText: 'Classroom / Lab *'),
                          items: const [
                            DropdownMenuItem(value: 'Hall 101', child: Text('Hall 101')),
                            DropdownMenuItem(value: 'Hall 202', child: Text('Hall 202')),
                            DropdownMenuItem(value: 'Hall 105', child: Text('Hall 105')),
                            DropdownMenuItem(value: 'Hall 302', child: Text('Hall 302')),
                            DropdownMenuItem(value: 'Computer Lab 1', child: Text('Computer Lab 1')),
                            DropdownMenuItem(value: 'Computer Lab 2', child: Text('Computer Lab 2')),
                          ],
                          onChanged: (v) => setDialogState(() => room = v ?? 'Hall 101'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (subjCtrl.text.trim().isEmpty || codeCtrl.text.trim().isEmpty) return;

                setState(() {
                  if (isEdit) {
                    final idx = _slots.indexWhere((s) => s.id == existing.id);
                    if (idx != -1) {
                      _slots[idx] = existing.copyWith(
                        day: day,
                        timeSlot: timeCtrl.text.trim(),
                        subject: subjCtrl.text.trim(),
                        subjectCode: codeCtrl.text.trim(),
                        className: cls,
                        semester: sem,
                        instructor: instructor,
                        room: room,
                        status: status,
                      );
                    }
                  } else {
                    _slots.insert(
                      0,
                      LectureSlotModel(
                        id: 'slot_${DateTime.now().millisecondsSinceEpoch}',
                        day: day,
                        timeSlot: timeCtrl.text.trim(),
                        subject: subjCtrl.text.trim(),
                        subjectCode: codeCtrl.text.trim(),
                        className: cls,
                        semester: sem,
                        instructor: instructor,
                        room: room,
                        status: status,
                      ),
                    );
                  }
                });

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'Lecture slot updated!' : 'New lecture slot added to timetable!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
              child: Text(isEdit ? 'Save Changes' : 'Add Slot'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDeleteSlot(LectureSlotModel slot) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Lecture Slot?'),
        content: Text('Delete "${slot.subject} (${slot.timeSlot})" on ${slot.day} from master timetable?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _slots.removeWhere((s) => s.id == slot.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lecture slot removed from timetable.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Institute-Wide Lecture Schedule',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'View and manage faculty lectures, subject timetables, classroom allocations, batches, and conflict-free time slots.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    if (widget.onNavigate != null) widget.onNavigate!('academic-planning');
                  },
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Academic Planning'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _showAddOrEditSlotDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Lecture Slot'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Filter Toolbar (matching screenshot exactly)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                spacing: 14,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Select Class
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Class: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      DropdownButton<String>(
                        value: _selectedClass,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All Classes')),
                          DropdownMenuItem(value: 'BCA-301', child: Text('BCA-301')),
                          DropdownMenuItem(value: 'BCA-302', child: Text('BCA-302')),
                          DropdownMenuItem(value: 'BCA-305', child: Text('BCA-305')),
                          DropdownMenuItem(value: 'MCA-101', child: Text('MCA-101')),
                          DropdownMenuItem(value: 'MATH-201', child: Text('MATH-201')),
                          DropdownMenuItem(value: 'PHY-101', child: Text('PHY-101')),
                        ],
                        onChanged: (v) => setState(() => _selectedClass = v ?? 'All'),
                      ),
                    ],
                  ),

                  // Select Semester
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Semester: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      DropdownButton<String>(
                        value: _selectedSemester,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All')),
                          DropdownMenuItem(value: 'Semester 1', child: Text('Sem 1')),
                          DropdownMenuItem(value: 'Semester 2', child: Text('Sem 2')),
                          DropdownMenuItem(value: 'Semester 3', child: Text('Sem 3')),
                          DropdownMenuItem(value: 'Semester 5', child: Text('Sem 5')),
                        ],
                        onChanged: (v) => setState(() => _selectedSemester = v ?? 'All'),
                      ),
                    ],
                  ),

                  // Select Day
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Day: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      DropdownButton<String>(
                        value: _selectedDay,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All Days')),
                          DropdownMenuItem(value: 'Mon', child: Text('Mon')),
                          DropdownMenuItem(value: 'Tue', child: Text('Tue')),
                          DropdownMenuItem(value: 'Wed', child: Text('Wed')),
                          DropdownMenuItem(value: 'Thu', child: Text('Thu')),
                          DropdownMenuItem(value: 'Fri', child: Text('Fri')),
                          DropdownMenuItem(value: 'Sat', child: Text('Sat')),
                        ],
                        onChanged: (v) => setState(() => _selectedDay = v ?? 'All'),
                      ),
                    ],
                  ),

                  // Select Room
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Room: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      DropdownButton<String>(
                        value: _selectedRoom,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All Rooms')),
                          DropdownMenuItem(value: 'Hall 101', child: Text('Hall 101')),
                          DropdownMenuItem(value: 'Hall 202', child: Text('Hall 202')),
                          DropdownMenuItem(value: 'Hall 105', child: Text('Hall 105')),
                          DropdownMenuItem(value: 'Hall 302', child: Text('Hall 302')),
                          DropdownMenuItem(value: 'Computer Lab 1', child: Text('Computer Lab 1')),
                          DropdownMenuItem(value: 'Computer Lab 2', child: Text('Computer Lab 2')),
                        ],
                        onChanged: (v) => setState(() => _selectedRoom = v ?? 'All'),
                      ),
                    ],
                  ),
                ],
              ),

              // View Toggle (Table vs Grid)
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'table', icon: Icon(Icons.table_rows_outlined, size: 16), label: Text('Table')),
                  ButtonSegment(value: 'grid', icon: Icon(Icons.grid_view_outlined, size: 16), label: Text('Matrix')),
                ],
                selected: {_viewMode},
                onSelectionChanged: (set) => setState(() => _viewMode = set.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.primary,
                  selectedForegroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Content: Table View or Matrix Grid
        if (_viewMode == 'table') ...[
          _buildTableView(),
        ] else ...[
          _buildMatrixGridView(),
        ],
        const SizedBox(height: 20),

        // Bottom Actions Row (matching screenshot Save Schedule)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Timetable exported for print / PDF distribution.')),
                );
              },
              icon: const Icon(Icons.print_outlined, size: 16),
              label: const Text('Export Timetable'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lecture schedule saved & published campus-wide!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              icon: const Icon(Icons.save_outlined, size: 16),
              label: const Text('Save & Publish Schedule'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scheduled Lectures (${_filteredSlots.length} Slots)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Active Timetable Slots',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          if (_filteredSlots.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text('No lecture slots match the selected filters.', style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredSlots.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
              itemBuilder: (context, index) {
                final slot = _filteredSlots[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      // Index
                      Container(
                        width: 28,
                        alignment: Alignment.center,
                        child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),

                      // Day Badge
                      Container(
                        width: 46,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          slot.day,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Time Slot & Subject
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot.subject,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMain),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(slot.timeSlot, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                const SizedBox(width: 6),
                                Text('• ${slot.subjectCode} • ${slot.className}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Instructor
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.teacherPrimary.withValues(alpha: 0.15),
                              child: Text(
                                slot.instructor.isNotEmpty ? slot.instructor[0] : 'T',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.teacherPrimary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                slot.instructor,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Room Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.meeting_room_outlined, size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(slot.room, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Status Badge
                      StatusBadge(label: slot.status, status: 'active'),
                      const SizedBox(width: 10),

                      // Action Buttons
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
                        tooltip: 'Edit Slot',
                        onPressed: () => _showAddOrEditSlotDialog(slot),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        tooltip: 'Delete Slot',
                        onPressed: () => _handleDeleteSlot(slot),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMatrixGridView() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Weekly Timetable Grid', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text('Day-by-Day Schedule Flow', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: days.map((d) {
                      final daySlots = _filteredSlots.where((s) => s.day == d).toList();
                      return Container(
                        width: 220,
                        margin: const EdgeInsets.only(right: 14),
                        decoration: BoxDecoration(
                          color: AppColors.bgPage,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: const BoxDecoration(
                                color: AppColors.bgSurface,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    d.toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textMain),
                                  ),
                                  Text('${daySlots.length} slots', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: daySlots.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 24),
                                      child: Center(
                                        child: Text('No slots scheduled', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                                      ),
                                    )
                                  : Column(
                                      children: daySlots.map((s) {
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(s.timeSlot, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                              const SizedBox(height: 3),
                                              Text(s.subject, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textMain)),
                                              const SizedBox(height: 3),
                                              Text('${s.instructor} • ${s.room}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
