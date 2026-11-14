import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/portal_header.dart';
import '../../widgets/illustrations.dart';

class TeacherRegistrationScreen extends StatefulWidget {
  const TeacherRegistrationScreen({super.key});

  @override
  State<TeacherRegistrationScreen> createState() => _TeacherRegistrationScreenState();
}

class _TeacherRegistrationScreenState extends State<TeacherRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController(text: 'INST-2025');
  final _empIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedDept = 'Computer Science & IT';
  bool _showPassword = false;

  final List<String> _departments = [
    'Computer Science & IT',
    'Mathematics & Stats',
    'Electronics & Hardware',
    'Business Administration',
    'Physics & Applied Sciences',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _empIdController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleDemoFill() {
    setState(() {
      _nameController.text = 'Dr. Sunita Rao';
      _emailController.text = 'sunita.new@institute.com';
      _codeController.text = 'INST-2025';
      _empIdController.text = 'INS-${DateTime.now().millisecondsSinceEpoch % 1000}';
      _selectedDept = 'Computer Science & IT';
      _phoneController.text = '+91 98765 44332';
      _passwordController.text = 'password123';
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final nav = Provider.of<NavigationProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final success = await auth.registerTeacher({
      'fullName': _nameController.text.trim(),
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'instituteCode': _codeController.text.trim().toUpperCase(),
      'employeeId': _empIdController.text.trim(),
      'instructorId': _empIdController.text.trim(),
      'department': _selectedDept,
      'phoneNumber': _phoneController.text.trim(),
      'password': _passwordController.text,
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faculty account registered successfully!'), backgroundColor: AppColors.success),
      );
      nav.navigateTo('teacher-dashboard');
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Center(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: _buildLeftPanel()),
                              Expanded(flex: 6, child: _buildForm(auth, nav)),
                            ],
                          )
                        : Column(
                            children: [
                              _buildLeftPanel(compact: true),
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

  Widget _buildLeftPanel({bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF134E4A), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cast_for_education, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'Teacher Registration',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join the campus faculty directory to manage lectures, grade submissions, and track student performance.',
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.5),
          ),
          if (!compact) ...[
            const SizedBox(height: 32),
            const Center(child: TeacherIllustrationWidget(size: 200)),
            const SizedBox(height: 24),
            const Text(
              'Requires campus verification: Ensure you have the official Institute Code from your dean or administrator.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
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
                  'Faculty Registration',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain),
                ),
                TextButton.icon(
                  onPressed: _handleDemoFill,
                  icon: const Icon(Icons.bolt, size: 15, color: AppColors.teacherPrimary),
                  label: const Text('Demo Fill', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teacherPrimary)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Enter your academic and department details.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 24),

            if (auth.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(10)),
                child: Text(auth.errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Faculty Full Name', hintText: 'e.g. Dr. Amit Sharma'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Full name required' : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Faculty Email', hintText: 'amit.sharma@institute.com'),
              validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(labelText: 'Institute Code', hintText: 'INST-2025'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Code required' : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _empIdController,
                    decoration: const InputDecoration(labelText: 'Employee / Faculty ID', hintText: 'INS-001'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Employee ID required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: _selectedDept,
              items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setState(() => _selectedDept = v ?? 'Computer Science & IT'),
              decoration: const InputDecoration(labelText: 'Department / Discipline'),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number', hintText: '+91 98765 00000'),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, size: 18),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
              validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary),
                child: auth.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Complete Teacher Registration'),
              ),
            ),
            const SizedBox(height: 18),

            Center(
              child: Wrap(
                children: [
                  const Text('Already registered? ', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  InkWell(
                    onTap: () => nav.navigateTo('teacher-login'),
                    child: const Text('Sign in here', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.teacherPrimary)),
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
