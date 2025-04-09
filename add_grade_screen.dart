import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apilocal/grade_model.dart';
import 'package:apilocal/grade_repository.dart';
import 'package:apilocal/student_model.dart';
import 'package:apilocal/grade_screen.dart';

class AddGradeScreen extends ConsumerStatefulWidget {
  final Student? student;
  const AddGradeScreen({super.key, this.student});

  @override
  ConsumerState<AddGradeScreen> createState() => _AddGradeScreenState();
}

class _AddGradeScreenState extends ConsumerState<AddGradeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rollNoController = TextEditingController();
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _programController = TextEditingController();
  final _shiftController = TextEditingController();
  final _semesterController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _courseTitleController = TextEditingController();
  final _creditHoursController = TextEditingController();
  final _obtainedMarksController = TextEditingController();
  final _considerStatusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _rollNoController.text = widget.student!.rollNo;
      _nameController.text = widget.student!.name;
      _fatherNameController.text = widget.student!.fatherName;
      _programController.text = widget.student!.program;
      _shiftController.text = widget.student!.shift;
    }
    _considerStatusController.text = 'E';
  }

  @override
  void dispose() {
    _rollNoController.dispose();
    _nameController.dispose();
    _fatherNameController.dispose();
    _programController.dispose();
    _shiftController.dispose();
    _semesterController.dispose();
    _courseCodeController.dispose();
    _courseTitleController.dispose();
    _creditHoursController.dispose();
    _obtainedMarksController.dispose();
    _considerStatusController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Save'),
            content: const Text('Are you sure you want to save this grade?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final grade = Grade(
      studentName: _nameController.text,
      fatherName: _fatherNameController.text,
      programName: _programController.text,
      shift: _shiftController.text,
      rollNo: _rollNoController.text,
      courseCode: _courseCodeController.text,
      courseTitle: _courseTitleController.text,
      creditHours: double.parse(_creditHoursController.text),
      obtainedMarks: double.parse(_obtainedMarksController.text),
      semester: _semesterController.text,
      considerStatus: _considerStatusController.text,
    );

    try {
      final repository = ref.read(gradeRepositoryProvider);
      await repository.insertGrade(grade);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grade added successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add grade: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Grade'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_rollNoController, 'Roll Number', (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter roll number';
                }
                return null;
              }),
              _buildTextField(_nameController, 'Student Name', (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter student name';
                }
                return null;
              }),
              _buildTextField(_fatherNameController, 'Father Name', (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter father name';
                }
                return null;
              }),
              _buildTextField(_programController, 'Program', (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter program';
                }
                return null;
              }),
              _buildTextField(_shiftController, 'Shift', (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter shift';
                }
                return null;
              }),
              _buildTextField(_semesterController, 'Semester', (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter semester';
                }
                return null;
              }),
              _buildTextField(_courseCodeController, 'Course Code', (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter course code';
                }
                return null;
              }),
              _buildTextField(_courseTitleController, 'Course Title', (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter course title';
                }
                return null;
              }),
              _buildNumberField(_creditHoursController, 'Credit Hours',
                  (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter credit hours';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              }),
              _buildNumberField(_obtainedMarksController, 'Obtained Marks',
                  (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter obtained marks';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                final marks = double.parse(value);
                if (marks < 0 || marks > 100) {
                  return 'Marks must be between 0-100';
                }
                return null;
              }),
              _buildTextField(_considerStatusController, 'Consider Status (E)',
                  (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter E for considered';
                }
                if (value != 'E') {
                  return 'Must be E to be considered';
                }
                return null;
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Grade'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    FormFieldValidator<String> validator,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildNumberField(
    TextEditingController controller,
    String label,
    FormFieldValidator<String> validator,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}
