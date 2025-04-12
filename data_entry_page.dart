// import 'package:flutter/material.dart';
// import 'helpers.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class DataEntryPage extends StatefulWidget {
//   const DataEntryPage({super.key});

//   @override
//   State<DataEntryPage> createState() => _DataEntryPageState();
// }

// class _DataEntryPageState extends State<DataEntryPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _userIdController = TextEditingController();
//   final TextEditingController _courseNameController = TextEditingController();
//   final TextEditingController _marksController = TextEditingController();

//   String? _selectedSemester;
//   String? _selectedCreditHours;

//   final List<String> _semesterOptions = [
//     '1',
//     '2',
//     '3',
//     '4',
//     '5',
//     '6',
//     '7',
//     '8'
//   ];
//   final List<String> _creditHoursOptions = ['1', '2', '3', '4', '5'];

//   bool _isSubmitting = false;

//   @override
//   void dispose() {
//     _userIdController.dispose();
//     _courseNameController.dispose();
//     _marksController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedSemester == null || _selectedCreditHours == null) {
//       showToast('Please select semester and credit hours');
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     final data = {
//       'user_id': _userIdController.text,
//       'course_name': _courseNameController.text,
//       'semester_no': _selectedSemester!,
//       'credit_hours': _selectedCreditHours!,
//       'marks': _marksController.text,
//     };

//     final hasInternet = await checkInternet();

//     if (hasInternet) {
//       try {
//         // Try POST request first
//         final response = await http.post(
//           Uri.parse('https://devtechtop.com/management/public/api/grades'),
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//           },
//           body: jsonEncode(data),
//         );

//         // Handle response
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           final responseData = jsonDecode(response.body);
//           showToast(responseData['message'] ?? 'Data saved successfully');
//           _clearForm();
//         } else {
//           final errorData = jsonDecode(response.body);
//           showToast('Error: ${errorData['message'] ?? response.statusCode}');
//           // Save to local storage if API fails
//           await saveToLocal(data);
//         }
//       } catch (e) {
//         showToast('Network Error: $e');
//         await saveToLocal(data);
//         showToast('Saved locally (offline)');
//       }
//     } else {
//       await saveToLocal(data);
//       showToast('Saved locally (offline)');
//       _clearForm();
//     }

//     setState(() => _isSubmitting = false);
//   }

//   void _clearForm() {
//     _formKey.currentState!.reset();
//     setState(() {
//       _selectedSemester = null;
//       _selectedCreditHours = null;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 20),
//               const Text(
//                 'Add Grade',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               _buildTextField(
//                 controller: _userIdController,
//                 label: 'User ID',
//                 validator: (value) => value!.isEmpty ? 'Required' : null,
//                 icon: Icons.person,
//               ),
//               const SizedBox(height: 16),
//               _buildTextField(
//                 controller: _courseNameController,
//                 label: 'Course Name',
//                 validator: (value) => value!.isEmpty ? 'Required' : null,
//                 icon: Icons.menu_book,
//               ),
//               const SizedBox(height: 16),
//               _buildDropdown(
//                 value: _selectedSemester,
//                 items: _semesterOptions,
//                 hint: 'Select Semester',
//                 onChanged: (value) => setState(() => _selectedSemester = value),
//                 icon: Icons.school,
//               ),
//               const SizedBox(height: 16),
//               _buildDropdown(
//                 value: _selectedCreditHours,
//                 items: _creditHoursOptions,
//                 hint: 'Select Credit Hours',
//                 onChanged: (value) =>
//                     setState(() => _selectedCreditHours = value),
//                 icon: Icons.hourglass_bottom,
//               ),
//               const SizedBox(height: 16),
//               _buildTextField(
//                 controller: _marksController,
//                 label: 'Marks',
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value!.isEmpty) return 'Required';
//                   final marks = int.tryParse(value);
//                   if (marks == null) return 'Enter valid number';
//                   if (marks < 0 || marks > 100) return 'Marks must be 0-100';
//                   return null;
//                 },
//                 icon: Icons.grade,
//               ),
//               const SizedBox(height: 32),
//               ElevatedButton(
//                 onPressed: _isSubmitting ? null : _submitForm,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: _isSubmitting
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         'SUBMIT GRADE',
//                         style: TextStyle(fontSize: 16),
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String? Function(String?)? validator,
//     TextInputType? keyboardType,
//     required IconData icon,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.blue),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.grey),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.blue),
//         ),
//       ),
//       keyboardType: keyboardType,
//       validator: validator,
//     );
//   }

//   Widget _buildDropdown({
//     required String? value,
//     required List<String> items,
//     required String hint,
//     required void Function(String?) onChanged,
//     required IconData icon,
//   }) {
//     return DropdownButtonFormField<String>(
//       value: value,
//       items: items.map((item) {
//         return DropdownMenuItem<String>(
//           value: item,
//           child: Text(item),
//         );
//       }).toList(),
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         labelText: hint,
//         prefixIcon: Icon(icon, color: Colors.blue),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.grey),
//         ),
//       ),
//       validator: (value) => value == null ? 'Required' : null,
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'helpers.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class DataEntryPage extends StatefulWidget {
//   const DataEntryPage({super.key});

//   @override
//   State<DataEntryPage> createState() => _DataEntryPageState();
// }

// class _DataEntryPageState extends State<DataEntryPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _userIdController = TextEditingController();
//   final TextEditingController _courseNameController = TextEditingController();
//   final TextEditingController _marksController = TextEditingController();

//   String? _selectedSemester;
//   String? _selectedCreditHours;

//   final List<String> _semesterOptions = [
//     '1',
//     '2',
//     '3',
//     '4',
//     '5',
//     '6',
//     '7',
//     '8'
//   ];
//   final List<String> _creditHoursOptions = ['1', '2', '3', '4', '5'];

//   bool _isSubmitting = false;

//   @override
//   void dispose() {
//     _userIdController.dispose();
//     _courseNameController.dispose();
//     _marksController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedSemester == null || _selectedCreditHours == null) {
//       showToast('Please select semester and credit hours');
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     final data = {
//       'user_id': _userIdController.text.trim(),
//       'course_name': _courseNameController.text.trim(),
//       'semester_no': _selectedSemester!,
//       'credit_hours': _selectedCreditHours!,
//       'marks': _marksController.text.trim(),
//     };

//     try {
//       final hasInternet = await checkInternet();

//       if (hasInternet) {
//         final response = await postGradeData(data);

//         if (response.statusCode == 200 || response.statusCode == 201) {
//           final responseData = jsonDecode(response.body);
//           showToast(responseData['message'] ?? 'Data saved successfully');
//           _clearForm();
//         } else {
//           final errorData = jsonDecode(response.body);
//           throw Exception(errorData['message'] ?? 'Failed to save data');
//         }
//       } else {
//         await saveToLocal(data);
//         showToast('Saved locally (offline)');
//         _clearForm();
//       }
//     } catch (e) {
//       showToast('Error: $e');
//       try {
//         await saveToLocal(data);
//         showToast('Saved locally as backup');
//       } catch (e) {
//         showToast('Failed to save data locally: $e');
//       }
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }

//   void _clearForm() {
//     _formKey.currentState!.reset();
//     setState(() {
//       _selectedSemester = null;
//       _selectedCreditHours = null;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 20),
//               const Text(
//                 'Add Grade',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               _buildTextField(
//                 controller: _userIdController,
//                 label: 'User ID',
//                 validator: (value) => value!.trim().isEmpty ? 'Required' : null,
//                 icon: Icons.person,
//               ),
//               const SizedBox(height: 16),
//               _buildTextField(
//                 controller: _courseNameController,
//                 label: 'Course Name',
//                 validator: (value) => value!.trim().isEmpty ? 'Required' : null,
//                 icon: Icons.menu_book,
//               ),
//               const SizedBox(height: 16),
//               _buildDropdown(
//                 value: _selectedSemester,
//                 items: _semesterOptions,
//                 hint: 'Select Semester',
//                 onChanged: (value) => setState(() => _selectedSemester = value),
//                 icon: Icons.school,
//               ),
//               const SizedBox(height: 16),
//               _buildDropdown(
//                 value: _selectedCreditHours,
//                 items: _creditHoursOptions,
//                 hint: 'Select Credit Hours',
//                 onChanged: (value) =>
//                     setState(() => _selectedCreditHours = value),
//                 icon: Icons.hourglass_bottom,
//               ),
//               const SizedBox(height: 16),
//               _buildTextField(
//                 controller: _marksController,
//                 label: 'Marks',
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value!.trim().isEmpty) return 'Required';
//                   final marks = int.tryParse(value);
//                   if (marks == null) return 'Enter valid number';
//                   if (marks < 0 || marks > 100) return 'Marks must be 0-100';
//                   return null;
//                 },
//                 icon: Icons.grade,
//               ),
//               const SizedBox(height: 32),
//               ElevatedButton(
//                 onPressed: _isSubmitting ? null : _submitForm,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: _isSubmitting
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         'SUBMIT GRADE',
//                         style: TextStyle(fontSize: 16),
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String? Function(String?)? validator,
//     TextInputType? keyboardType,
//     required IconData icon,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.blue),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.grey),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.blue),
//         ),
//       ),
//       keyboardType: keyboardType,
//       validator: validator,
//     );
//   }

//   Widget _buildDropdown({
//     required String? value,
//     required List<String> items,
//     required String hint,
//     required void Function(String?) onChanged,
//     required IconData icon,
//   }) {
//     return DropdownButtonFormField<String>(
//       value: value,
//       items: items.map((item) {
//         return DropdownMenuItem<String>(
//           value: item,
//           child: Text(item),
//         );
//       }).toList(),
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         labelText: hint,
//         prefixIcon: Icon(icon, color: Colors.blue),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.grey),
//         ),
//       ),
//       validator: (value) => value == null ? 'Required' : null,
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'helpers.dart';
import 'dart:convert';

class DataEntryPage extends StatefulWidget {
  const DataEntryPage({super.key});

  @override
  State<DataEntryPage> createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();

  String? _selectedSemester;
  String? _selectedCreditHours;

  final List<String> _semesterOptions = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8'
  ];
  final List<String> _creditHoursOptions = ['1', '2', '3', '4', '5'];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _userIdController.dispose();
    _courseNameController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSemester == null || _selectedCreditHours == null) {
      showToast('Please select semester and credit hours');
      return;
    }

    setState(() => _isSubmitting = true);

    final data = {
      'user_id': _userIdController.text.trim(),
      'course_name': _courseNameController.text.trim(),
      'semester_no': _selectedSemester!,
      'credit_hours': _selectedCreditHours!,
      'marks': _marksController.text.trim(),
    };

    try {
      final hasInternet = await checkInternet();

      if (hasInternet) {
        final response = await postGradeData(data);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          showToast(responseData['message'] ?? 'Data saved successfully');
          _clearForm();
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to save data');
        }
      } else {
        await saveToLocal(data);
        showToast('Saved locally (offline)');
        _clearForm();
      }
    } catch (e) {
      showToast('Error: $e');
      try {
        await saveToLocal(data);
        showToast('Saved locally as backup');
      } catch (e) {
        showToast('Failed to save data locally: $e');
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    setState(() {
      _selectedSemester = null;
      _selectedCreditHours = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Add Grade',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _userIdController,
                label: 'User ID',
                validator: (value) => value!.trim().isEmpty ? 'Required' : null,
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _courseNameController,
                label: 'Course Name',
                validator: (value) => value!.trim().isEmpty ? 'Required' : null,
                icon: Icons.menu_book,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: _selectedSemester,
                items: _semesterOptions,
                hint: 'Select Semester',
                onChanged: (value) => setState(() => _selectedSemester = value),
                icon: Icons.school,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: _selectedCreditHours,
                items: _creditHoursOptions,
                hint: 'Select Credit Hours',
                onChanged: (value) =>
                    setState(() => _selectedCreditHours = value),
                icon: Icons.hourglass_bottom,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _marksController,
                label: 'Marks',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.trim().isEmpty) return 'Required';
                  final marks = int.tryParse(value);
                  if (marks == null) return 'Enter valid number';
                  if (marks < 0 || marks > 100) return 'Marks must be 0-100';
                  return null;
                },
                icon: Icons.grade,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SUBMIT GRADE',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      validator: (value) => value == null ? 'Required' : null,
    );
  }
}