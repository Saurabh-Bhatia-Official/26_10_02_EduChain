import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/portal_header.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController(text: 'INST-2025');
  bool _rememberMe = false;
  bool _showPassword = false;
  bool _autoFilled = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _handleDemoFill() {
    setState(() {
      _emailController.text = 'amit.kumar@institute.com';
      _passwordController.text = 'password123';
      _codeController.text = 'INST-2025';
      _autoFilled = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _autoFilled = false);
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final nav = Provider.of<NavigationProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final success = await auth.loginRole(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: 'admin',
      instituteCode: _codeController.text.trim(),
    );

    if (success && mounted) {
      nav.navigateTo('admin-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          const PortalHeader(backTarget: 'select-role', backLabel: 'Back to Role Selection'),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Container(
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
                    clipBehavior: Clip.antiAlias,
                    child: isDesktop
                        ? Row(
                            children: [
                              Expanded(flex: 5, child: _buildLeftPanel(nav)),
                              Expanded(flex: 6, child: _buildForm(auth, nav)),
                            ],
                          )
                        : Column(
                            children: [
                              _buildLeftPanel(nav, compact: true),
                              _buildForm(auth, nav),
                            ],
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

  Widget _buildLeftPanel(NavigationProvider nav, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'Admin Login',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Access system dashboard, manage records, timetables, and academic operations.',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
          ),
          if (!compact) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_clock, color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text('System Administrator Privileges', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Full control over student admissions, instructor allocation, exam timetables, and real-time backend reports.',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Switch Role:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRoleSwitchBtn('Teacher', Icons.cast_for_education, () => nav.navigateTo('teacher-login')),
                const SizedBox(width: 8),
                _buildRoleSwitchBtn('Student', Icons.school, () => nav.navigateTo('student-login')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleSwitchBtn(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AuthProvider auth, NavigationProvider nav) {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Admin Sign In',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain),
                ),
                TextButton.icon(
                  onPressed: _handleDemoFill,
                  icon: Icon(
                    _autoFilled ? Icons.check : Icons.bolt,
                    size: 15,
                    color: _autoFilled ? AppColors.accentGreen : AppColors.adminPrimary,
                  ),
                  label: Text(
                    _autoFilled ? 'Filled!' : 'Demo Fill',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _autoFilled ? AppColors.accentGreen : AppColors.adminPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Sign in with your system administrator credentials.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),

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

            const Text('Institute Code', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                hintText: 'INST-2025',
                prefixIcon: Icon(Icons.tag, size: 18),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Admin Email Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'amit.kumar@institute.com',
                prefixIcon: Icon(Icons.email_outlined, size: 18),
              ),
              validator: (v) => v == null || !v.contains('@') ? 'Valid admin email required' : null,
            ),
            const SizedBox(height: 16),

            const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, size: 18),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Password required' : null,
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (v) => setState(() => _rememberMe = v ?? false),
                    ),
                    const Text('Remember me', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  ],
                ),
                InkWell(
                  onTap: () => nav.navigateTo('forgot-password', {'role': 'admin'}),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.adminPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
                child: auth.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Sign In as Admin'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

