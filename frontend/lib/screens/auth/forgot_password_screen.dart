import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/portal_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String initialRole;
  const ForgotPasswordScreen({super.key, this.initialRole = 'student'});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late String _selectedRole;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _getBackLoginRoute() {
    switch (_selectedRole) {
      case 'admin':
        return 'admin-login';
      case 'teacher':
        return 'teacher-login';
      case 'institute':
        return 'institute-login';
      default:
        return 'student-login';
    }
  }

  Color _getRoleColor() {
    switch (_selectedRole) {
      case 'admin':
        return AppColors.adminPrimary;
      case 'teacher':
        return AppColors.teacherPrimary;
      case 'institute':
        return AppColors.institutePrimary;
      default:
        return AppColors.studentPrimary;
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _successMessage = null);

    try {
      final msg = await auth.forgotPassword(
        email: _emailController.text.trim(),
        role: _selectedRole,
      );
      setState(() {
        _successMessage = msg;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context);
    final roleColor = _getRoleColor();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          PortalHeader(
            backTarget: _getBackLoginRoute(),
            backLabel: 'Back to Login',
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: Container(
                    padding: const EdgeInsets.all(36),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: roleColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.key, color: roleColor, size: 32),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Center(
                            child: Text(
                              'Reset Password',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textMain),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Center(
                            child: Text(
                              'Select your account role and enter your registered email address.',
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Role Selector Tabs
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.bgPage,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                _buildRoleTab('student', 'Student'),
                                _buildRoleTab('teacher', 'Teacher'),
                                _buildRoleTab('admin', 'Admin'),
                                _buildRoleTab('institute', 'Institute'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (_successMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _successMessage!,
                                      style: const TextStyle(color: Color(0xFF065F46), fontSize: 13, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          if (auth.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.errorBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(auth.errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                            ),
                            const SizedBox(height: 16),
                          ],

                          const Text('Registered Email Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'e.g. user@institute.com',
                              prefixIcon: Icon(Icons.email_outlined, size: 18),
                            ),
                            validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: auth.isLoading ? null : _handleSubmit,
                              icon: auth.isLoading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.send, size: 16),
                              label: const Text('Send Password Reset Link'),
                              style: ElevatedButton.styleFrom(backgroundColor: roleColor),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Center(
                            child: OutlinedButton.icon(
                              onPressed: () => nav.navigateTo(_getBackLoginRoute()),
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: const Text('Back to Login'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTab(String role, String label) {
    final isActive = _selectedRole == role;
    final color = _getRoleColor();
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _selectedRole = role;
          _successMessage = null;
        }),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.white : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

