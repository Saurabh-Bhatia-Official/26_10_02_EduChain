import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/portal_header.dart';
import '../../widgets/illustrations.dart';

class InstituteLoginScreen extends StatefulWidget {
  const InstituteLoginScreen({super.key});

  @override
  State<InstituteLoginScreen> createState() => _InstituteLoginScreenState();
}

class _InstituteLoginScreenState extends State<InstituteLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _showPassword = false;
  bool _autoFilled = false;

  @override
  void dispose() {
    _codeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleDemoFill() {
    setState(() {
      _codeController.text = 'INST-2025';
      _emailController.text = 'admin@apex.edu';
      _passwordController.text = 'password123';
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

    final success = await auth.loginInstitute(
      instituteCode: _codeController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Institute verified! Opening Institute Portal...'),
          backgroundColor: AppColors.success,
        ),
      );
      nav.navigateTo('institute-home');
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
          const PortalHeader(backTarget: 'home', backLabel: 'Back to Home'),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
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
                              Expanded(flex: 5, child: _buildLeftHeroPanel()),
                              Expanded(flex: 6, child: _buildLoginForm(auth, nav)),
                            ],
                          )
                        : Column(
                            children: [
                              _buildLeftHeroPanel(compact: true),
                              _buildLoginForm(auth, nav),
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

  Widget _buildLeftHeroPanel({bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
            ),
            child: const Text(
              'ACADEMIC ADMINISTRATION',
              style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Institute Login',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sign in to access centralized institute administration, verified campus analytics, and faculty controls.',
            style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8), height: 1.5),
          ),
          if (!compact) ...[
            const SizedBox(height: 32),
            const Center(child: InstituteIllustration(size: 200)),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.verified, size: 16, color: AppColors.accentGreen),
                const SizedBox(width: 8),
                const Text('AICTE & UGC Recognized Standards', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoginForm(AuthProvider auth, NavigationProvider nav) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sign In to Campus',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain),
                ),
                TextButton.icon(
                  onPressed: _handleDemoFill,
                  icon: Icon(
                    _autoFilled ? Icons.check : Icons.bolt,
                    size: 15,
                    color: _autoFilled ? AppColors.accentGreen : AppColors.primary,
                  ),
                  label: Text(
                    _autoFilled ? 'Filled!' : 'Demo Fill',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _autoFilled ? AppColors.accentGreen : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter your institute code and administrator credentials.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),

            if (auth.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        auth.errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Institute Code
            const Text('Institute Code / ID', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                hintText: 'e.g., INST-2025',
                prefixIcon: Icon(Icons.tag, size: 18),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter institute code' : null,
            ),
            const SizedBox(height: 16),

            // Email
            const Text('Administrator Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'admin@apex.edu',
                prefixIcon: Icon(Icons.email_outlined, size: 18),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter administrator email';
                if (!v.contains('@')) return 'Enter a valid email address';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password
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
              validator: (v) => v == null || v.isEmpty ? 'Please enter your password' : null,
            ),
            const SizedBox(height: 14),

            // Remember Me & Forgot Password
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
                  onTap: () => nav.navigateTo('forgot-password', {'role': 'institute'}),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: auth.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Verify & Enter Institute'),
              ),
            ),
            const SizedBox(height: 20),

            // Register Redirect
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('New institute? ', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  InkWell(
                    onTap: () => nav.navigateTo('institute-register'),
                    child: const Text(
                      'Register your campus',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
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

