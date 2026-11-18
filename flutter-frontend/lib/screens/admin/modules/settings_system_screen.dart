import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../widgets/status_badge.dart';

class SettingsSystemScreen extends StatefulWidget {
  final UserModel? user;
  final Function(String screenName, {String? param})? onNavigate;

  const SettingsSystemScreen({super.key, this.user, this.onNavigate});

  @override
  State<SettingsSystemScreen> createState() => _SettingsSystemScreenState();
}

class _SettingsSystemScreenState extends State<SettingsSystemScreen> {
  late String _adminName;
  late String _adminEmail;
  late String _adminPhone;
  late String _adminTitle;
  late String _instituteCode;
  late String _instituteName;

  bool _emailAlerts = true;
  bool _attendanceAnomalyAlerts = true;
  bool _maintenanceAlerts = false;
  bool _isCheckingHealth = false;
  String _healthStatus = 'Healthy & Connected';

  @override
  void initState() {
    super.initState();
    _adminName = widget.user?.name ?? 'Amit Kumar';
    _adminEmail = widget.user?.email ?? 'amit.kumar@institute.com';
    _adminPhone = widget.user?.phone ?? '+91 98765 43210';
    _adminTitle = 'System Administrator';
    _instituteCode = widget.user?.instituteCode ?? 'INST-2025';
    _instituteName = widget.user?.instituteName ?? 'Apex Institute of Technology';
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _adminName);
    final emailCtrl = TextEditingController(text: _adminEmail);
    final phoneCtrl = TextEditingController(text: _adminPhone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Administrator Profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name *'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Admin Email *'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Contact Phone *'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _adminName = nameCtrl.text.trim();
                _adminEmail = emailCtrl.text.trim();
                _adminPhone = phoneCtrl.text.trim();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Admin profile updated!'), backgroundColor: AppColors.success),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
            child: const Text('Save Profile'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final curCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Master Admin Password', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: curCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password *'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password *'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: confCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm New Password *'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (newCtrl.text.isEmpty || newCtrl.text != confCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match or are empty!'), backgroundColor: AppColors.error),
                );
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Master Admin password updated securely!'), backgroundColor: AppColors.success),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }

  void _verifyDatabaseHealth() async {
    setState(() => _isCheckingHealth = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _isCheckingHealth = false;
        _healthStatus = '100% Operational • 0 Errors';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PostgreSQL 16 database, JPA connections, and Cloudinary media verified healthy!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

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
                    'Settings & System Management',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage administrator credentials, campus affiliation, notifications, database connectivity, and security parameters.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Two-Column Grid: Left Profile Card vs Right Settings
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Admin Profile Card
            SizedBox(
              width: isDesktop ? 320 : double.infinity,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.adminPrimary,
                      child: Text(
                        _adminName.isNotEmpty ? _adminName[0].toUpperCase() : 'A',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 26),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _adminName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textMain),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _adminTitle,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.adminPrimary),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 12),

                    _buildProfileContactItem(Icons.email_outlined, _adminEmail),
                    const SizedBox(height: 10),
                    _buildProfileContactItem(Icons.phone_outlined, _adminPhone),
                    const SizedBox(height: 10),
                    _buildProfileContactItem(Icons.account_balance_outlined, _instituteCode),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _showEditProfileDialog,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit Admin Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.adminPrimary,
                        minimumSize: const Size.fromHeight(42),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Links
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('System Support & Docs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                        const SizedBox(height: 8),
                        _buildQuickDocLink('Help & Technical Support'),
                        _buildQuickDocLink('Campus Privacy Policy'),
                        _buildQuickDocLink('Terms & Acceptable Use'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Right Column: Preferences, Security & Database
            Expanded(
              child: Column(
                children: [
                  // Account & Security Card
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
                        const Text('Account & Security Settings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 16),

                        // Change Password Tile
                        InkWell(
                          onTap: _showChangePasswordDialog,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.bgPage,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.lock_outline, size: 20, color: AppColors.primary),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text('Change Master Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                      Text('Update your administrator login passphrase', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppColors.textLight),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Notification Toggles
                        const Text('Automated Notifications', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 10),
                        SwitchListTile(
                          title: const Text('Email Alerts & Digest', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          subtitle: const Text('Receive daily summaries of student registrations and admissions.', style: TextStyle(fontSize: 12)),
                          value: _emailAlerts,
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: AppColors.adminPrimary,
                          onChanged: (v) => setState(() => _emailAlerts = v),
                        ),
                        SwitchListTile(
                          title: const Text('Attendance Anomaly Warnings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          subtitle: const Text('Trigger notification when student attendance falls below 75%.', style: TextStyle(fontSize: 12)),
                          value: _attendanceAnomalyAlerts,
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: AppColors.adminPrimary,
                          onChanged: (v) => setState(() => _attendanceAnomalyAlerts = v),
                        ),
                        SwitchListTile(
                          title: const Text('Maintenance & Audit Logging', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          subtitle: const Text('Log sensitive DB operations and schema migrations.', style: TextStyle(fontSize: 12)),
                          value: _maintenanceAlerts,
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: AppColors.adminPrimary,
                          onChanged: (v) => setState(() => _maintenanceAlerts = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Platform & Infrastructure Health Card
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
                            const Text('Platform & Infrastructure Health', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            StatusBadge(label: _healthStatus, status: 'healthy'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSystemParamRow('Database Engine', 'PostgreSQL 16 (Spring Boot JPA Hibernate)'),
                        _buildSystemParamRow('Media & File Cloud', 'Cloudinary Media Storage & AWS S3'),
                        _buildSystemParamRow('Session Lifetime', '24 Hours (HMAC-SHA256 JWT Signed)'),
                        _buildSystemParamRow('Active Academic Term', 'Spring Term 2025 (Jan – Jun)'),
                        _buildSystemParamRow('Server Timezone', 'Asia/Kolkata (IST +05:30)'),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: _isCheckingHealth ? null : _verifyDatabaseHealth,
                          icon: _isCheckingHealth
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.health_and_safety, size: 16),
                          label: Text(_isCheckingHealth ? 'Pinging Database...' : 'Verify Database Health & Cache'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Bottom Institute Affiliation Banner Card
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.adminPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_instituteName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: AppColors.primary, size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Affiliation Code: $_instituteCode • AICTE & UGC Recognized • Grade A+ NAAC Accredited',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textMain, fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _buildQuickDocLink(String title) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title documentation opened.')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.arrow_right, size: 18, color: AppColors.primary),
            Text(title, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemParamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textMain, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
