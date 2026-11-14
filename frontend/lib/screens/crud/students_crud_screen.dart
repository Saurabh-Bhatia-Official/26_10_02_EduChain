import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/student_model.dart';
import '../../services/api_service.dart';

class StudentsCrudScreen extends StatefulWidget {
  const StudentsCrudScreen({super.key});

  @override
  State<StudentsCrudScreen> createState() => _StudentsCrudScreenState();
}

class _StudentsCrudScreenState extends State<StudentsCrudScreen> {
  final ApiService _api = ApiService();
  List<StudentModel> _students = [];
  bool _loading = true;
  String _error = '';
  String _search = '';
  String? _editingId;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _rollController = TextEditingController();
  final _classController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _fatherPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final list = await _api.getStudents(_search);
      setState(() => _students = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _startEdit(StudentModel s) {
    setState(() {
      _editingId = s.id;
      _nameController.text = s.name;
      _emailController.text = s.email;
      _rollController.text = s.rollNumber;
      _classController.text = s.className;
      _phoneController.text = s.phone ?? '';
      _addressController.text = s.address ?? '';
      _fatherNameController.text = s.fatherName ?? '';
      _fatherPhoneController.text = s.fatherPhone ?? '';
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _nameController.clear();
      _emailController.clear();
      _rollController.clear();
      _classController.clear();
      _phoneController.clear();
      _addressController.clear();
      _fatherNameController.clear();
      _fatherPhoneController.clear();
    });
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.trim().isEmpty) return;

    final std = StudentModel(
      id: _editingId ?? '',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      rollNumber: _rollController.text.trim(),
      className: _classController.text.trim(),
      course: _classController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      fatherName: _fatherNameController.text.trim(),
      fatherPhone: _fatherPhoneController.text.trim(),
    );

    try {
      if (_editingId != null) {
        await _api.updateStudent(_editingId!, std);
      } else {
        await _api.createStudent(std);
      }
      _clearForm();
      await _loadStudents();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _delete(String id) async {
    try {
      await _api.deleteStudent(id);
      await _loadStudents();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rollController.dispose();
    _classController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _fatherNameController.dispose();
    _fatherPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students CRUD Management'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStudents),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_editingId != null ? 'Edit Student' : 'Add Student', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name *'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email *'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: _rollController, decoration: const InputDecoration(labelText: 'Roll Number'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: _classController, decoration: const InputDecoration(labelText: 'Class / Course'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address'))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: Text(_editingId != null ? 'Update Student' : 'Save Student'),
                      ),
                      if (_editingId != null) ...[
                        const SizedBox(width: 10),
                        OutlinedButton(onPressed: _clearForm, child: const Text('Cancel Edit')),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Search
            TextField(
              onChanged: (v) {
                _search = v;
                _loadStudents();
              },
              decoration: const InputDecoration(
                hintText: 'Search students by name, roll, email...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error.isNotEmpty)
              Text('Error: $_error', style: const TextStyle(color: AppColors.error))
            else
              ..._students.map((s) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Roll: ${s.rollNumber} • ${s.className} • ${s.email}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _startEdit(s)),
                          IconButton(icon: const Icon(Icons.delete, color: AppColors.error), onPressed: () => _delete(s.id)),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
