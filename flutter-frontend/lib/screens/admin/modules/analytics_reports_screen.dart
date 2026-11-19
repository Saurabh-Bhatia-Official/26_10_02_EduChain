import 'package:material_ui/material_ui.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/metric_card.dart';

class AnalyticsReportsScreen extends StatefulWidget {
  final Function(String screenName, {String? param})? onNavigate;

  const AnalyticsReportsScreen({super.key, this.onNavigate});

  @override
  State<AnalyticsReportsScreen> createState() => _AnalyticsReportsScreenState();
}

class _AnalyticsReportsScreenState extends State<AnalyticsReportsScreen> {
  final String _dateRange = 'Jan – Jun 2025 (Spring Term)';

  final List<Map<String, dynamic>> _enrollmentTrend = [
    {'month': 'Jan', 'val': 55, 'count': '660 students'},
    {'month': 'Feb', 'val': 70, 'count': '840 students'},
    {'month': 'Mar', 'val': 82, 'count': '984 students'},
    {'month': 'Apr', 'val': 95, 'count': '1,140 students'},
    {'month': 'May', 'val': 65, 'count': '780 students'},
    {'month': 'Jun', 'val': 88, 'count': '1,056 students'},
  ];

  final List<Map<String, dynamic>> _deptBreakdown = [
    {'name': 'Computer Science', 'pct': 40, 'color': AppColors.primary},
    {'name': 'Mathematics', 'pct': 25, 'color': AppColors.secondary},
    {'name': 'Physics', 'pct': 15, 'color': AppColors.accentPurple},
    {'name': 'Commerce', 'pct': 12, 'color': AppColors.accentOrange},
    {'name': 'Others', 'pct': 8, 'color': AppColors.accentTeal},
  ];

  final List<Map<String, dynamic>> _topPerformers = [
    {'name': 'Rahul Sharma', 'dept': 'Computer Science', 'score': '96%', 'grade': 'A+'},
    {'name': 'Priya Singh', 'dept': 'Computer Science', 'score': '94%', 'grade': 'A+'},
    {'name': 'Amit Kumar', 'dept': 'Computer Science', 'score': '93%', 'grade': 'A'},
    {'name': 'Neha Patel', 'dept': 'Computer Science', 'score': '91%', 'grade': 'A'},
    {'name': 'Sahil Verma', 'dept': 'Mathematics', 'score': '88%', 'grade': 'A'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Screen Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Analytics & Compliance Reports',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Campus-wide insights, student enrollment trends, department performance, and regulatory compliance.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(_dateRange, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comprehensive report exported as CSV!'), backgroundColor: AppColors.success),
                    );
                  },
                  icon: const Icon(Icons.file_download_outlined, size: 16),
                  label: const Text('Export CSV'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 4 KPI Metric Cards
        Row(
          children: const [
            Expanded(
              child: MetricCard(
                title: 'Total Students',
                value: '1,250',
                icon: Icons.school,
                color: AppColors.studentPrimary,
                subtitle: '+5% increase this term',
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: MetricCard(
                title: 'Faculty Instructors',
                value: '186',
                icon: Icons.people,
                color: AppColors.teacherPrimary,
                subtitle: '+2% new recruitments',
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: MetricCard(
                title: 'Average Attendance',
                value: '89.2%',
                icon: Icons.check_circle_outline,
                color: AppColors.accentGreen,
                subtitle: '+1% campus compliance',
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: MetricCard(
                title: 'Exam Pass Rate',
                value: '92.4%',
                icon: Icons.military_tech_outlined,
                color: AppColors.accentOrange,
                subtitle: '+4% overall pass score',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 3 Visual Analytics Cards in Flex Layout
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visual 1: Student Enrollment Trend (Bar Chart)
                Expanded(
                  flex: isWide ? 4 : 0,
                  child: Container(
                    height: 340,
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
                            Text('Enrollment Trend', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            Text('Monthly Active', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: _enrollmentTrend.map((item) {
                              final int val = item['val'] as int;
                              final String month = item['month'] as String;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('$val%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 24,
                                    height: (val / 100) * 160,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [AppColors.primary, AppColors.secondary],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(month, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),

                // Visual 2: Department-Wise Performance (Donut)
                Expanded(
                  flex: isWide ? 4 : 0,
                  child: Container(
                    height: 340,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Department Allocation', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 16),
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(
                                  value: 0.85,
                                  strokeWidth: 9,
                                  backgroundColor: AppColors.bgSurface,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('1,250', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain)),
                                  Text('Students', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: _deptBreakdown.map((dept) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(color: dept['color'] as Color, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(dept['name'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textMain)),
                                    ),
                                    Text('${dept['pct']}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),

                // Visual 3: Top Academic Performers
                Expanded(
                  flex: isWide ? 4 : 0,
                  child: Container(
                    height: 340,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Top Academic Performers', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _topPerformers.length,
                            separatorBuilder: (_, _) => const Divider(height: 8, color: AppColors.borderLight),
                            itemBuilder: (context, index) {
                              final p = _topPerformers[index];
                              return Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: index == 0
                                          ? AppColors.accentOrange
                                          : (index == 1 ? AppColors.secondary : AppColors.bgSurface),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: index < 2 ? Colors.white : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                        Text(p['dept'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.successBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      p['score'] as String,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // Compliance & Governance Summary Card
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
                  const Text('UGC & Regulatory Compliance Audit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(8)),
                    child: const Text('100% Compliant', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildComplianceRow(
                title: 'Attendance Compliance Standard',
                value: '92.4% campus average (Standard: 75% minimum mandatory requirement met)',
                isGood: true,
              ),
              const SizedBox(height: 10),
              _buildComplianceRow(
                title: 'Faculty-to-Student Ratio',
                value: '1:21 faculty-to-student ratio (UGC norms prescribe 1:25 or lower)',
                isGood: true,
              ),
              const SizedBox(height: 10),
              _buildComplianceRow(
                title: 'Semester Regular Pass Rate',
                value: '94.6% regular session students cleared evaluations without backlogs',
                isGood: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComplianceRow({required String title, required String value, required bool isGood}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(isGood ? Icons.check_circle : Icons.warning_amber, color: isGood ? AppColors.success : AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
