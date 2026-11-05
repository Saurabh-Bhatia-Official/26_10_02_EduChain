import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/portal_header.dart';

class InstituteRegistrationScreen extends StatefulWidget {
  const InstituteRegistrationScreen({super.key});

  @override
  State<InstituteRegistrationScreen> createState() => _InstituteRegistrationScreenState();
}

class _InstituteRegistrationScreenState extends State<InstituteRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _instPasswordController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  String _instituteType = 'College';
  bool _agreeTerms = true;
  bool _showInstPassword = false;
  bool _showAdminPassword = false;
  bool _autoFilled = false;

  final List<String> _instituteTypes = [
    'College',
    'University',
    'Institute of Technology',
    'Polytechnic',
    'Academy',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _adminNameController.dispose();
    _adminEmailController.dispose();
    _instPasswordController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  void _handleDemoFill() {
    setState(() {
      _nameController.text = 'St. Xavier Institute of Technology';
      _instituteType = 'College';
      _emailController.text = 'info@stxavier.edu';
      _phoneController.text = '+91 98765 11223';
      _addressController.text = '420 University Avenue, Tech Campus';
      _adminNameController.text = 'Dr. Robert Vance (Dean)';
      _adminEmailController.text = 'admin@stxavier.edu';
      _instPasswordController.text = 'InstPassword@2025';
      _adminPasswordController.text = 'AdminPassword@2025';
      _agreeTerms = true;
      _autoFilled = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _autoFilled = false);
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to terms and conditions'), backgroundColor: AppColors.error),
      );
      return;
    }

    final nav = Provider.of<NavigationProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final success = await auth.registerInstitute({
      'instituteName': _nameController.text.trim(),
      'instituteType': _instituteType,
      'instituteEmail': _emailController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'adminName': _adminNameController.text.trim(),
      'adminEmail': _adminEmailController.text.trim(),
      'institutePassword': _instPasswordController.text,
      'adminPassword': _adminPasswordController.text,
    });

    if (success && mounted) {
      final code = auth.currentUser?.instituteCode ?? 'INST-2025';
      _showSuccessDialog(code, nav);
    }
  }

  void _showSuccessDialog(String code, NavigationProvider nav) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.successBg, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 28),
            ),
            const SizedBox(width: 12),
            const Text('Institute Registered!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your campus has been officially registered and verified on the platform.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your Institute Code:', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                      Text(
                        code,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20, color: AppColors.primary),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied!'), duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              nav.navigateTo('institute-home');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Open Institute Dashboard'),
          ),
        ],
      ),
    );
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1050),
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
                              Expanded(flex: 4, child: _buildLeftPanel()),
                              Expanded(flex: 7, child: _buildForm(auth, nav)),
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
      padding: EdgeInsets.all(compact ? 24 : 36),
      color: const Color(0xFF0F172A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
            ),
            child: const Text(
              'CAMPUS ONBOARDING',
              style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Register Your Institute',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create your verified institution account to manage students, faculty, exams, and curriculum in one unified hub.',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.5),
          ),
          if (!compact) ...[
            const SizedBox(height: 36),
            _buildCheckItem('Instant Unique Institute Code Generation'),
            const SizedBox(height: 14),
            _buildCheckItem('Role Separation for Admin, Teachers & Students'),
            const SizedBox(height: 14),
            _buildCheckItem('AICTE / UGC Accredited Academic Workflows'),
            const SizedBox(height: 14),
            _buildCheckItem('Real-time Examination & Attendance Tracking'),
            const SizedBox(height: 36),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.accentGreen, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enterprise grade data privacy and AES-256 encrypted authentication.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ],
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
                  'Campus Profile Setup',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textMain),
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
              'Fill in official institution information and head administrator profile.',
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

            // Section 1: Institution Details
            const Text('1. INSTITUTION DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Official Institute Name', hintText: 'e.g. Apex Institute of Technology'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter institute name' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _instituteType,
              items: _instituteTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _instituteType = v ?? 'College'),
              decoration: const InputDecoration(labelText: 'Classification / Type'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Institute Email', hintText: 'info@institute.edu'),
                    validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number', hintText: '+91 98765 00000'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Campus Address', hintText: 'City, State, Country'),
            ),
            const SizedBox(height: 24),

            // Section 2: Administrator Details
            const Text('2. LEAD ADMINISTRATOR ACCOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _adminNameController,
                    decoration: const InputDecoration(labelText: 'Admin Full Name', hintText: 'Dr. John Doe (Dean)'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Admin name required' : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _adminEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Admin Official Email', hintText: 'admin@institute.edu'),
                    validator: (v) => v == null || !v.contains('@') ? 'Valid admin email required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _instPasswordController,
                    obscureText: !_showInstPassword,
                    decoration: InputDecoration(
                      labelText: 'Master Password',
                      suffixIcon: IconButton(
                        icon: Icon(_showInstPassword ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setState(() => _showInstPassword = !_showInstPassword),
                      ),
                    ),
                    validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _adminPasswordController,
                    obscureText: !_showAdminPassword,
                    decoration: InputDecoration(
                      labelText: 'Admin Password',
                      suffixIcon: IconButton(
                        icon: Icon(_showAdminPassword ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setState(() => _showAdminPassword = !_showAdminPassword),
                      ),
                    ),
                    validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Terms
            Row(
              children: [
                Checkbox(
                  value: _agreeTerms,
                  onChanged: (v) => setState(() => _agreeTerms = v ?? true),
                ),
                const Expanded(
                  child: Text(
                    'I certify that I represent an authorized educational institution and agree to terms.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: auth.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Complete Registration & Generate Code'),
              ),
            ),
            const SizedBox(height: 16),

            Center(
              child: Wrap(
                children: [
                  const Text('Already have an institute account? ', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  InkWell(
                    onTap: () => nav.navigateTo('institute-login'),
                    child: const Text('Sign in here', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
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
