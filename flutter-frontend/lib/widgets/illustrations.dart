import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class InstituteIllustration extends StatelessWidget {
  final double size;
  const InstituteIllustration({super.key, this.size = 280});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.85,
          height: size * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                    ),
                    child: const Icon(Icons.account_balance, size: 54, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ACADEMIC PORTAL',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Verified Institution System',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StudentIllustrationWidget extends StatelessWidget {
  final double size;
  const StudentIllustrationWidget({super.key, this.size = 260});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.studentPrimary.withValues(alpha: 0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.85,
          height: size * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.studentPrimary.withValues(alpha: 0.25), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.studentPrimary.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.studentPrimary.withValues(alpha: 0.35), width: 2),
                    ),
                    child: const Icon(Icons.school, size: 52, color: AppColors.studentPrimary),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'STUDENT DESK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.studentPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Grades • Attendance • Exams',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TeacherIllustrationWidget extends StatelessWidget {
  final double size;
  const TeacherIllustrationWidget({super.key, this.size = 260});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.teacherPrimary.withValues(alpha: 0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.85,
          height: size * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.teacherPrimary.withValues(alpha: 0.25), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.teacherPrimary.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.teacherPrimary.withValues(alpha: 0.35), width: 2),
                    ),
                    child: const Icon(Icons.cast_for_education, size: 52, color: AppColors.teacherPrimary),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'FACULTY WORKSPACE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.teacherPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Classes • Students • Curriculum',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
