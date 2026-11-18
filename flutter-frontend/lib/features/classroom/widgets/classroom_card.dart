import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../models/classroom_model.dart';

const _bannerColors = <List<Color>>[
  [Color(0xFF4F46E5), Color(0xFF06B6D4)], // Indigo to Cyan (EduChain brand)
  [Color(0xFF7C3AED), Color(0xFFEC4899)], // Purple to Pink
  [Color(0xFF059669), Color(0xFF10B981)], // Emerald to Green
  [Color(0xFFEA580C), Color(0xFFFBBF24)], // Orange to Amber
  [Color(0xFF0284C7), Color(0xFF38BDF8)], // Blue to Sky
  [Color(0xFF9333EA), Color(0xFFC084FC)], // Violet
];

class ClassroomBanner extends StatelessWidget {
  const ClassroomBanner({
    super.key,
    required this.index,
    this.height = 120,
    this.bytes,
    this.url,
  });

  final int index;
  final double height;
  final Uint8List? bytes;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final colors = _bannerColors[index % _bannerColors.length];
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Stack(
        children: [
          if (bytes != null)
            Positioned.fill(child: Image.memory(bytes!, fit: BoxFit.cover)),
          Positioned(
            right: -10,
            top: -24,
            child: Icon(
              Icons.school_rounded,
              size: height * 1.3,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 12,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    [
                      Icons.terminal_rounded,
                      Icons.storage_rounded,
                      Icons.psychology_rounded,
                      Icons.science_rounded,
                      Icons.functions_rounded,
                      Icons.menu_book_rounded,
                    ][index % 6],
                    size: 24,
                    color: Colors.white,
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

class ClassroomCard extends StatelessWidget {
  const ClassroomCard({
    super.key,
    required this.classroom,
    required this.onTap,
    this.role = ClassroomRole.student,
    this.showTeacher = false,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
    this.onLeave,
    this.assignmentCount = 0,
    this.attendanceRate,
  });

  final ClassroomModel classroom;
  final VoidCallback onTap;
  final ClassroomRole role;
  final bool showTeacher;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onLeave;
  final int assignmentCount;
  final double? attendanceRate;

  @override
  Widget build(BuildContext context) {
    final isTeacher = role == ClassroomRole.teacher;
    final isAdmin = role == ClassroomRole.admin;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClassroomBanner(
                  index: classroom.bannerIndex,
                  bytes: classroom.bannerBytes,
                  url: classroom.bannerUrl,
                ),
                // Top Action Row
                Positioned(
                  top: 8,
                  right: 8,
                  left: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Role Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          isTeacher
                              ? 'Assigned Teacher'
                              : isAdmin
                              ? 'Admin Oversight'
                              : 'Enrolled Student',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      // Manage Menu
                      if (canManage || onLeave != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: PopupMenuButton<String>(
                            iconColor: Colors.white,
                            tooltip: 'Class Options',
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (value) {
                              if (value == 'edit') onEdit?.call();
                              if (value == 'delete') onDelete?.call();
                              if (value == 'leave') onLeave?.call();
                              if (value == 'copy_code') {
                                Clipboard.setData(ClipboardData(text: classroom.code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Class code ${classroom.code} copied!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              if (canManage) ...[
                                const PopupMenuItem(
                                  value: 'copy_code',
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy, size: 16),
                                      SizedBox(width: 8),
                                      Text('Copy Class Code'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 16),
                                      SizedBox(width: 8),
                                      Text('Edit Classroom'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                                      SizedBox(width: 8),
                                      Text('Delete Classroom', style: TextStyle(color: AppColors.error)),
                                    ],
                                  ),
                                ),
                              ] else if (onLeave != null) ...[
                                const PopupMenuItem(
                                  value: 'leave',
                                  child: Row(
                                    children: [
                                      Icon(Icons.exit_to_app, size: 16, color: AppColors.error),
                                      SizedBox(width: 8),
                                      Text('Leave Class', style: TextStyle(color: AppColors.error)),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classroom.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          classroom.section.isNotEmpty ? classroom.section : classroom.subject,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          classroom.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          classroom.teacherName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (classroom.room.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.meeting_room_outlined, size: 14, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(
                          classroom.room,
                          style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  // Bottom Stat Pills
                  Row(
                    children: [
                      _StatPill(
                        icon: Icons.people_alt_outlined,
                        label: '${classroom.studentIds.length}',
                        tooltip: 'Enrolled Students',
                      ),
                      const SizedBox(width: 8),
                      if (assignmentCount > 0) ...[
                        _StatPill(
                          icon: Icons.assignment_outlined,
                          label: '$assignmentCount',
                          tooltip: 'Active Assignments',
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (attendanceRate != null) ...[
                        _StatPill(
                          icon: Icons.check_circle_outline,
                          label: '${attendanceRate!.round()}%',
                          color: attendanceRate! >= 75 ? AppColors.success : AppColors.warning,
                          tooltip: 'Attendance Rate',
                        ),
                      ],
                      const Spacer(),
                      // Class Code badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.key_outlined, size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              classroom.code,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.tooltip,
    this.color = AppColors.textMuted,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
