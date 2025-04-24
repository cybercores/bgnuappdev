import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'api_service.dart';
import 'database_helper.dart';

class DataEntryScreen extends StatefulWidget {
  final ApiService apiService;

  const DataEntryScreen({super.key, required this.apiService});

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'user_id': '',
    'course_name': '',
    'semester_no': '1',
    'credit_hours': '3',
    'marks': '',
    'grade': '',
  };

  final List<String> _semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];
  final List<String> _creditHours = ['1', '2', '3', '4'];

  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    final result = await widget.apiService.submitGrade(_formData);
    if (result['success'] == true) {
      _showSuccessSnackbar('Grade submitted successfully!');
      _clearForm();
    } else {
      _showErrorSnackbar(result['error'] ?? 'Submission failed');
    }

    setState(() => _isSubmitting = false);
  }

  Future<void> _saveToLocal() async {
    try {
      await DatabaseHelper.instance.insertGrade(_formData);
      _showSuccessSnackbar('Saved to local storage');
    } catch (e) {
      _showErrorSnackbar('Failed to save locally: ${e.toString()}');
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    setState(() {
      _formData.updateAll((key, value) => '');
      _formData['semester_no'] = '1';
      _formData['credit_hours'] = '3';
    });
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Grade'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTextField('User ID', 'user_id', Icons.person),
                      const SizedBox(height: 16),
                      _buildTextField('Course Name', 'course_name', Icons.school),
                      const SizedBox(height: 16),
                      _buildDropdown('Semester', 'semester_no', Icons.list_alt, _semesters),
                      const SizedBox(height: 16),
                      _buildDropdown('Credit Hours', 'credit_hours', Icons.timer, _creditHours),
                      const SizedBox(height: 16),
                      _buildTextField('Marks', 'marks', Icons.score),
                      const SizedBox(height: 16),
                      _buildTextField('Grade', 'grade', Icons.grade),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: const Icon(Icons.send),
                  label: const Text('SUBMIT GRADE'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String field, IconData icon) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      onSaved: (value) => _formData[field] = value,
    );
  }

  Widget _buildDropdown(String label, String field, IconData icon, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      value: _formData[field],
      items: items.map((value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) => setState(() => _formData[field] = value!),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }
}