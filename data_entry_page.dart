// import 'package:flutter/material.dart';
// import 'helpers.dart';
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
//       if (mounted) {
//         showToast('Please select semester and credit hours', context: context);
//       }
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
//         logDebug('API Response: ${response.statusCode} - ${response.body}');

//         if (response.statusCode == 200) {
//           final responseData = jsonDecode(response.body);
//           if (mounted) {
//             showToast(responseData['message'] ?? 'Grade saved successfully',
//                 context: context);
//             _clearForm();
//             await processPendingSubmissions(context);
//           }
//         } else {
//           throw Exception('Server error: ${response.statusCode}');
//         }
//       } else {
//         await saveToLocal(data);
//         if (mounted) {
//           showToast('Saved locally (offline)', context: context);
//           _clearForm();
//         }
//       }
//     } catch (e) {
//       logDebug('Submission error: $e');
//       if (mounted) {
//         showToast('Error: $e', context: context);
//       }
//       await saveToLocal(data); // Save as backup
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
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

// import 'package:flutter/material.dart';
// import 'helpers.dart';
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
//       if (mounted) {
//         showToast('Please select semester and credit hours', context: context);
//       }
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
//         logDebug('API Response: ${response.statusCode} - ${response.body}');

//         if (response.statusCode >= 200 && response.statusCode < 300) {
//           // Handle both 200 and 201 status codes as success
//           try {
//             final responseData = jsonDecode(response.body);
//             if (mounted) {
//               showToast(
//                 responseData['message'] ?? 'Grade saved successfully',
//                 context: context,
//               );
//               _clearForm();
//               await processPendingSubmissions(context);
//             }
//           } catch (e) {
//             logDebug('Error parsing response: $e');
//             if (mounted) {
//               showToast('Grade saved successfully', context: context);
//               _clearForm();
//               await processPendingSubmissions(context);
//             }
//           }
//         } else {
//           // Handle other status codes as errors
//           final errorMessage = _getErrorMessage(response);
//           throw Exception(errorMessage);
//         }
//       } else {
//         // Offline case - save to local storage
//         await saveToLocal(data);
//         if (mounted) {
//           showToast('Saved locally (offline)', context: context);
//           _clearForm();
//         }
//       }
//     } catch (e) {
//       logDebug('Submission error: $e');
//       if (mounted) {
//         showToast('Error: ${e.toString()}', context: context);
//       }
//       // Save as backup even if there was an error with the API
//       await saveToLocal(data);
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
//     }
//   }

//   String _getErrorMessage(http.Response response) {
//     try {
//       final responseData = jsonDecode(response.body);
//       return responseData['message'] ??
//           responseData['error'] ??
//           'Server error: ${response.statusCode}';
//     } catch (e) {
//       return 'Server error: ${response.statusCode}';
//     }
//   }

//   void _clearForm() {
//     _formKey.currentState?.reset();
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

// import 'package:flutter/material.dart';
// import 'helpers.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

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
//       if (mounted) {
//         showToast('Please select semester and credit hours', context: context);
//       }
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
//         logDebug('API Response: ${response.statusCode} - ${response.body}');

//         if (response.statusCode >= 200 && response.statusCode < 300) {
//           try {
//             final responseData = jsonDecode(response.body);
//             if (mounted) {
//               showToast(
//                 responseData['message'] ?? 'Grade saved successfully',
//                 context: context,
//               );
//               _clearForm();
//               await processPendingSubmissions(context);
//             }
//           } catch (e) {
//             logDebug('Error parsing response: $e');
//             if (mounted) {
//               showToast('Grade saved successfully', context: context);
//               _clearForm();
//               await processPendingSubmissions(context);
//             }
//           }
//         } else {
//           final errorMessage = _getErrorMessage(response);
//           throw Exception(errorMessage);
//         }
//       } else {
//         await saveToLocal(data);
//         if (mounted) {
//           showToast('Saved locally (offline)', context: context);
//           _clearForm();
//         }
//       }
//     } catch (e) {
//       logDebug('Submission error: $e');
//       if (mounted) {
//         showToast('Error: ${e.toString()}', context: context);
//       }
//       await saveToLocal(data);
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
//     }
//   }

//   String _getErrorMessage(http.Response response) {
//     try {
//       final responseData = jsonDecode(response.body);
//       return responseData['message'] ??
//           responseData['error'] ??
//           'Server error: ${response.statusCode}';
//     } catch (e) {
//       return 'Server error: ${response.statusCode}';
//     }
//   }

//   void _clearForm() {
//     _formKey.currentState?.reset();
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

// import 'package:flutter/material.dart';
// import 'helpers.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class DataEntryPage extends StatefulWidget {
//   const DataEntryPage({super.key});

//   @override
//   State<DataEntryPage> createState() => _DataEntryPageState();
// }

// class _DataEntryPageState extends State<DataEntryPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _userIdController = TextEditingController();
//   final TextEditingController _marksController = TextEditingController();

//   String? _selectedSemester;
//   String? _selectedCreditHours;
//   String? _selectedCourse;
//   List<String> _courseOptions = [];
//   bool _isLoadingCourses = false;

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
//   void initState() {
//     super.initState();
//     _userIdController.addListener(_fetchCourses);
//     _fetchCourses(); // Initial fetch
//   }

//   @override
//   void dispose() {
//     _userIdController.dispose();
//     _marksController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchCourses() async {
//     final userId = _userIdController.text.trim();
//     if (userId.isEmpty) {
//       setState(() => _courseOptions = []);
//       return;
//     }

//     setState(() => _isLoadingCourses = true);

//     try {
//       final response = await http.get(
//         Uri.parse('https://bgnuerp.online/api/get_courses?user_id=$userId'),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data is Map && data.containsKey('courses')) {
//           final courses = List<String>.from(data['courses']);
//           setState(() => _courseOptions = courses);
//         } else {
//           throw Exception('Invalid course data format');
//         }
//       } else {
//         throw Exception('Failed to load courses: ${response.statusCode}');
//       }
//     } catch (e) {
//       logDebug('Error fetching courses: $e');
//       if (mounted) {
//         showToast('Error loading courses', context: context);
//       }
//       setState(() => _courseOptions = []);
//     } finally {
//       if (mounted) {
//         setState(() => _isLoadingCourses = false);
//       }
//     }
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedSemester == null ||
//         _selectedCreditHours == null ||
//         _selectedCourse == null) {
//       if (mounted) {
//         showToast('Please fill all required fields', context: context);
//       }
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     final data = {
//       'user_id': _userIdController.text.trim(),
//       'course_name': _selectedCourse!,
//       'semester_no': _selectedSemester!,
//       'credit_hours': _selectedCreditHours!,
//       'marks': _marksController.text.trim(),
//     };

//     try {
//       final hasInternet = await checkInternet();

//       if (hasInternet) {
//         final response = await postGradeData(data);
//         logDebug('API Response: ${response.statusCode} - ${response.body}');

//         if (response.statusCode >= 200 && response.statusCode < 300) {
//           try {
//             final responseData = jsonDecode(response.body);
//             if (mounted) {
//               showToast(
//                 responseData['message'] ?? 'Grade saved successfully',
//                 context: context,
//               );
//               _clearForm();
//               await processPendingSubmissions(context);
//             }
//           } catch (e) {
//             logDebug('Error parsing response: $e');
//             if (mounted) {
//               showToast('Grade saved successfully', context: context);
//               _clearForm();
//               await processPendingSubmissions(context);
//             }
//           }
//         } else {
//           final errorMessage = _getErrorMessage(response);
//           throw Exception(errorMessage);
//         }
//       } else {
//         await saveToLocal(data);
//         if (mounted) {
//           showToast('Saved locally (offline)', context: context);
//           _clearForm();
//         }
//       }
//     } catch (e) {
//       logDebug('Submission error: $e');
//       if (mounted) {
//         showToast('Error: ${e.toString()}', context: context);
//       }
//       await saveToLocal(data);
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
//     }
//   }

//   String _getErrorMessage(http.Response response) {
//     try {
//       final responseData = jsonDecode(response.body);
//       return responseData['message'] ??
//           responseData['error'] ??
//           'Server error: ${response.statusCode}';
//     } catch (e) {
//       return 'Server error: ${response.statusCode}';
//     }
//   }

//   void _clearForm() {
//     _formKey.currentState?.reset();
//     setState(() {
//       _selectedSemester = null;
//       _selectedCreditHours = null;
//       _selectedCourse = null;
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
//               _buildCourseDropdown(),
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

//   Widget _buildCourseDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Course Name',
//           style: TextStyle(fontSize: 16, color: Colors.black54),
//         ),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           value: _selectedCourse,
//           items: _courseOptions.map((course) {
//             return DropdownMenuItem<String>(
//               value: course,
//               child: Text(course),
//             );
//           }).toList(),
//           onChanged: (value) => setState(() => _selectedCourse = value),
//           decoration: InputDecoration(
//             prefixIcon: const Icon(Icons.menu_book, color: Colors.blue),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: Colors.grey),
//             ),
//             suffixIcon: _isLoadingCourses
//                 ? const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : null,
//           ),
//           validator: (value) => value == null ? 'Please select a course' : null,
//           isExpanded: true,
//           hint: const Text('Select Course'),
//           onTap: () {
//             if (_userIdController.text.isEmpty) {
//               showToast('Please enter User ID first', context: context);
//             }
//           },
//         ),
//       ],
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
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class DataEntryPage extends StatefulWidget {
//   const DataEntryPage({super.key});

//   @override
//   State<DataEntryPage> createState() => _DataEntryPageState();
// }

// class _DataEntryPageState extends State<DataEntryPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _userIdController = TextEditingController();
//   final TextEditingController _marksController = TextEditingController();

//   String? _selectedSemester;
//   String? _selectedCreditHours;
//   String? _selectedCourse;
//   List<Map<String, dynamic>> _courseOptions = [];
//   bool _isLoadingCourses = false;

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
//   void initState() {
//     super.initState();
//     _userIdController.addListener(_fetchCourses);
//     _fetchCourses(); // Initial fetch
//   }

//   @override
//   void dispose() {
//     _userIdController.dispose();
//     _marksController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchCourses() async {
//     final userId = _userIdController.text.trim();
//     if (userId.isEmpty) {
//       setState(() => _courseOptions = []);
//       return;
//     }

//     setState(() => _isLoadingCourses = true);

//     try {
//       final response = await http.get(
//         Uri.parse('https://bgnuerp.online/api/get_courses?user_id=$userId'),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         if (data is List) {
//           setState(() {
//             _courseOptions = data.map((course) {
//               return {
//                 'id': course['id'].toString(),
//                 'code': course['subject_code'].toString(),
//                 'name': course['subject_name'].toString(),
//                 'display':
//                     '${course['subject_code']} - ${course['subject_name']}'
//               };
//             }).toList();
//           });
//         } else {
//           throw Exception('Invalid course data format - expected array');
//         }
//       } else {
//         throw Exception('Failed to load courses: ${response.statusCode}');
//       }
//     } catch (e) {
//       logDebug('Error fetching courses: $e');
//       if (mounted) {
//         showToast('Error loading courses', context: context);
//       }
//       setState(() => _courseOptions = []);
//     } finally {
//       if (mounted) {
//         setState(() => _isLoadingCourses = false);
//       }
//     }
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedSemester == null ||
//         _selectedCreditHours == null ||
//         _selectedCourse == null) {
//       if (mounted) {
//         showToast('Please fill all required fields', context: context);
//       }
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     // Find the selected course details
//     final selectedCourse = _courseOptions.firstWhere(
//       (course) => course['display'] == _selectedCourse,
//       orElse: () => {'id': '', 'code': '', 'name': ''},
//     );

//     final data = {
//       'user_id': _userIdController.text.trim(),
//       'course_id': selectedCourse['id'],
//       'course_code': selectedCourse['code'],
//       'course_name': selectedCourse['name'],
//       'semester_no': _selectedSemester!,
//       'credit_hours': _selectedCreditHours!,
//       'marks': _marksController.text.trim(),
//     };

//     try {
//       final hasInternet = await checkInternet();

//       if (hasInternet) {
//         final response = await postGradeData(data);
//         logDebug('API Response: ${response.statusCode} - ${response.body}');

//         if (response.statusCode >= 200 && response.statusCode < 300) {
//           try {
//             final responseData = jsonDecode(response.body);
//             if (mounted) {
//               showToast(
//                 responseData['message'] ?? 'Grade saved successfully',
//                 context: context,
//               );
//               _clearForm();
//               await processPendingSubmissions(context);
//             }
//           } catch (e) {
//             logDebug('Error parsing response: $e');
//             if (mounted) {
//               showToast('Grade saved successfully', context: context);
//               _clearForm();
//               await processPendingSubmissions(context);
//             }
//           }
//         } else {
//           final errorMessage = _getErrorMessage(response);
//           throw Exception(errorMessage);
//         }
//       } else {
//         await saveToLocal(data);
//         if (mounted) {
//           showToast('Saved locally (offline)', context: context);
//           _clearForm();
//         }
//       }
//     } catch (e) {
//       logDebug('Submission error: $e');
//       if (mounted) {
//         showToast('Error: ${e.toString()}', context: context);
//       }
//       await saveToLocal(data);
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
//     }
//   }

//   String _getErrorMessage(http.Response response) {
//     try {
//       final responseData = jsonDecode(response.body);
//       return responseData['message'] ??
//           responseData['error'] ??
//           'Server error: ${response.statusCode}';
//     } catch (e) {
//       return 'Server error: ${response.statusCode}';
//     }
//   }

//   void _clearForm() {
//     _formKey.currentState?.reset();
//     setState(() {
//       _selectedSemester = null;
//       _selectedCreditHours = null;
//       _selectedCourse = null;
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
//               _buildCourseDropdown(),
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

//   Widget _buildCourseDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Course Name',
//           style: TextStyle(fontSize: 16, color: Colors.black54),
//         ),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           value: _selectedCourse,
//           items: _courseOptions.map((course) {
//             return DropdownMenuItem<String>(
//               value: course['display'],
//               child: Text(
//                 course['display'],
//                 overflow: TextOverflow.ellipsis,
//               ),
//             );
//           }).toList(),
//           onChanged: (value) => setState(() => _selectedCourse = value),
//           decoration: InputDecoration(
//             prefixIcon: const Icon(Icons.menu_book, color: Colors.blue),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: Colors.grey),
//             ),
//             suffixIcon: _isLoadingCourses
//                 ? const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : null,
//           ),
//           validator: (value) => value == null ? 'Please select a course' : null,
//           isExpanded: true,
//           hint: const Text('Select Course'),
//           onTap: () {
//             if (_userIdController.text.isEmpty) {
//               showToast('Please enter User ID first', context: context);
//             }
//           },
//         ),
//       ],
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
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class DataEntryPage extends StatefulWidget {
//   const DataEntryPage({super.key});

//   @override
//   State<DataEntryPage> createState() => _DataEntryPageState();
// }

// class _DataEntryPageState extends State<DataEntryPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _userIdController = TextEditingController();
//   final TextEditingController _marksController = TextEditingController();
//   final TextEditingController _courseSearchController = TextEditingController();

//   String? _selectedSemester;
//   String? _selectedCreditHours;
//   String? _selectedCourse;
//   List<Map<String, dynamic>> _allCourses = [];
//   List<Map<String, dynamic>> _filteredCourses = [];
//   bool _isLoadingCourses = false;
//   bool _isDropdownOpen = false;

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
//   void initState() {
//     super.initState();
//     _userIdController.addListener(_fetchCourses);
//     _courseSearchController.addListener(_filterCourses);
//     _fetchCourses(); // Initial fetch
//   }

//   @override
//   void dispose() {
//     _userIdController.dispose();
//     _marksController.dispose();
//     _courseSearchController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchCourses() async {
//     final userId = _userIdController.text.trim();
//     if (userId.isEmpty) {
//       setState(() {
//         _allCourses = [];
//         _filteredCourses = [];
//       });
//       return;
//     }

//     setState(() => _isLoadingCourses = true);

//     try {
//       final response = await http.get(
//         Uri.parse('https://bgnuerp.online/api/get_courses?user_id=$userId'),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         if (data is List) {
//           setState(() {
//             _allCourses = data.map((course) {
//               return {
//                 'id': course['id'].toString(),
//                 'code': course['subject_code'].toString(),
//                 'name': course['subject_name'].toString(),
//                 'display':
//                     '${course['subject_code']} - ${course['subject_name']}'
//               };
//             }).toList();
//             _filteredCourses = List.from(_allCourses);
//           });
//         } else {
//           throw Exception('Invalid course data format - expected array');
//         }
//       } else {
//         throw Exception('Failed to load courses: ${response.statusCode}');
//       }
//     } catch (e) {
//       logDebug('Error fetching courses: $e');
//       if (mounted) {
//         showToast('Error loading courses', context: context);
//       }
//       setState(() {
//         _allCourses = [];
//         _filteredCourses = [];
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _isLoadingCourses = false);
//       }
//     }
//   }

//   void _filterCourses() {
//     final query = _courseSearchController.text.toLowerCase();
//     setState(() {
//       _filteredCourses = _allCourses.where((course) {
//         return course['code'].toLowerCase().contains(query) ||
//             course['name'].toLowerCase().contains(query) ||
//             course['display'].toLowerCase().contains(query);
//       }).toList();
//     });
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedSemester == null ||
//         _selectedCreditHours == null ||
//         _selectedCourse == null) {
//       if (mounted) {
//         showToast('Please fill all required fields', context: context);
//       }
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     // Find the selected course details
//     final selectedCourse = _allCourses.firstWhere(
//       (course) => course['display'] == _selectedCourse,
//       orElse: () => {'id': '', 'code': '', 'name': ''},
//     );

//     final data = {
//       'user_id': _userIdController.text.trim(),
//       'course_id': selectedCourse['id'],
//       'course_code': selectedCourse['code'],
//       'course_name': selectedCourse['name'],
//       'semester_no': _selectedSemester!,
//       'credit_hours': _selectedCreditHours!,
//       'marks': _marksController.text.trim(),
//     };

//     try {
//       final hasInternet = await checkInternet();

//       if (hasInternet) {
//         final response = await postGradeData(data);
//         logDebug('API Response: ${response.statusCode} - ${response.body}');

//         if (response.statusCode >= 200 && response.statusCode < 300) {
//           try {
//             final responseData = jsonDecode(response.body);
//             if (mounted) {
//               showToast(
//                 responseData['message'] ?? 'Grade saved successfully',
//                 context: context,
//               );
//               _clearForm();
//               await processPendingSubmissions(context);
//             }
//           } catch (e) {
//             logDebug('Error parsing response: $e');
//             if (mounted) {
//               showToast('Grade saved successfully', context: context);
//               _clearForm();
//               await processPendingSubmissions(context);
//             }
//           }
//         } else {
//           final errorMessage = _getErrorMessage(response);
//           throw Exception(errorMessage);
//         }
//       } else {
//         await saveToLocal(data);
//         if (mounted) {
//           showToast('Saved locally (offline)', context: context);
//           _clearForm();
//         }
//       }
//     } catch (e) {
//       logDebug('Submission error: $e');
//       if (mounted) {
//         showToast('Error: ${e.toString()}', context: context);
//       }
//       await saveToLocal(data);
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
//     }
//   }

//   String _getErrorMessage(http.Response response) {
//     try {
//       final responseData = jsonDecode(response.body);
//       return responseData['message'] ??
//           responseData['error'] ??
//           'Server error: ${response.statusCode}';
//     } catch (e) {
//       return 'Server error: ${response.statusCode}';
//     }
//   }

//   void _clearForm() {
//     _formKey.currentState?.reset();
//     _courseSearchController.clear();
//     setState(() {
//       _selectedSemester = null;
//       _selectedCreditHours = null;
//       _selectedCourse = null;
//       _isDropdownOpen = false;
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
//               _buildSearchableCourseDropdown(),
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

//   Widget _buildSearchableCourseDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Course Name',
//           style: TextStyle(fontSize: 16, color: Colors.black54),
//         ),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           value: _selectedCourse,
//           items: [
//             // Search field as the first item
//             DropdownMenuItem<String>(
//               value: null,
//               enabled: false,
//               child: TextField(
//                 controller: _courseSearchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search courses...',
//                   border: InputBorder.none,
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () {
//                       _courseSearchController.clear();
//                       _filterCourses();
//                     },
//                   ),
//                 ),
//                 onTap: () {
//                   setState(() {
//                     _isDropdownOpen = true;
//                   });
//                 },
//               ),
//             ),
//             // Filtered course items
//             ..._filteredCourses.map((course) {
//               return DropdownMenuItem<String>(
//                 value: course['display'],
//                 child: Text(
//                   course['display'],
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               );
//             }).toList(),
//           ],
//           onChanged: (value) {
//             if (value != null) {
//               setState(() {
//                 _selectedCourse = value;
//                 _isDropdownOpen = false;
//               });
//             }
//           },
//           decoration: InputDecoration(
//             prefixIcon: const Icon(Icons.menu_book, color: Colors.blue),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: Colors.grey),
//             ),
//             suffixIcon: _isLoadingCourses
//                 ? const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : IconButton(
//                     icon: Icon(
//                       _isDropdownOpen
//                           ? Icons.arrow_drop_up
//                           : Icons.arrow_drop_down,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _isDropdownOpen = !_isDropdownOpen;
//                       });
//                     },
//                   ),
//           ),
//           validator: (value) => value == null ? 'Please select a course' : null,
//           isExpanded: true,
//           hint: const Text('Select Course'),
//           onTap: () {
//             if (_userIdController.text.isEmpty) {
//               showToast('Please enter User ID first', context: context);
//             }
//             setState(() {
//               _isDropdownOpen = !_isDropdownOpen;
//             });
//           },
//           dropdownColor: Colors.white,
//           icon: const SizedBox.shrink(), // Hide default dropdown icon
//           selectedItemBuilder: (BuildContext context) {
//             return [
//               Container(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   _selectedCourse ?? 'Select Course',
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ];
//           },
//         ),
//       ],
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
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class DataEntryPage extends StatefulWidget {
//   const DataEntryPage({super.key});

//   @override
//   State<DataEntryPage> createState() => _DataEntryPageState();
// }

// class _DataEntryPageState extends State<DataEntryPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _userIdController = TextEditingController();
//   final TextEditingController _marksController = TextEditingController();
//   final TextEditingController _courseSearchController = TextEditingController();

//   String? _selectedSemester;
//   String? _selectedCreditHours;
//   String? _selectedCourse;
//   List<Map<String, dynamic>> _allCourses = [];
//   List<Map<String, dynamic>> _filteredCourses = [];
//   bool _isLoadingCourses = false;
//   bool _isDropdownOpen = false;
//   OverlayEntry? _overlayEntry;
//   final LayerLink _layerLink = LayerLink();
//   final FocusNode _courseFocusNode = FocusNode();

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
//   void initState() {
//     super.initState();
//     _userIdController.addListener(_fetchCourses);
//     _courseSearchController.addListener(_filterCourses);
//     _courseFocusNode.addListener(_onCourseFocusChange);
//     _fetchCourses(); // Initial fetch
//   }

//   @override
//   void dispose() {
//     _userIdController.dispose();
//     _marksController.dispose();
//     _courseSearchController.dispose();
//     _courseFocusNode.dispose();
//     _removeOverlay();
//     super.dispose();
//   }

//   void _onCourseFocusChange() {
//     if (_courseFocusNode.hasFocus) {
//       _showOverlay();
//     } else {
//       _removeOverlay();
//     }
//   }

//   void _showOverlay() {
//     _removeOverlay();
//     setState(() => _isDropdownOpen = true);

//     final overlayState = Overlay.of(context);
//     final renderBox = context.findRenderObject() as RenderBox;
//     final size = renderBox.size;

//     _overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         width: size.width,
//         child: CompositedTransformFollower(
//           link: _layerLink,
//           showWhenUnlinked: false,
//           offset: Offset(0, size.height + 5),
//           child: Material(
//             elevation: 4,
//             child: Container(
//               constraints: BoxConstraints(
//                 maxHeight: MediaQuery.of(context).size.height * 0.4,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(4),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 8,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: TextField(
//                       controller: _courseSearchController,
//                       decoration: InputDecoration(
//                         hintText: 'Search courses...',
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         suffixIcon: _courseSearchController.text.isNotEmpty
//                             ? IconButton(
//                                 icon: const Icon(Icons.close),
//                                 onPressed: () {
//                                   _courseSearchController.clear();
//                                   _filterCourses();
//                                 },
//                               )
//                             : null,
//                       ),
//                       autofocus: true,
//                     ),
//                   ),
//                   Expanded(
//                     child: _isLoadingCourses
//                         ? const Center(child: CircularProgressIndicator())
//                         : _filteredCourses.isEmpty
//                             ? const Center(child: Text('No courses found'))
//                             : ListView.builder(
//                                 shrinkWrap: true,
//                                 itemCount: _filteredCourses.length,
//                                 itemBuilder: (context, index) {
//                                   final course = _filteredCourses[index];
//                                   return ListTile(
//                                     title: Text(
//                                       course['display'],
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     onTap: () {
//                                       setState(() {
//                                         _selectedCourse = course['display'];
//                                         _courseSearchController.text =
//                                             course['display'];
//                                         _isDropdownOpen = false;
//                                       });
//                                       _removeOverlay();
//                                       FocusScope.of(context).unfocus();
//                                     },
//                                   );
//                                 },
//                               ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );

//     overlayState.insert(_overlayEntry!);
//   }

//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//     setState(() => _isDropdownOpen = false);
//   }

//   Future<void> _fetchCourses() async {
//     final userId = _userIdController.text.trim();
//     if (userId.isEmpty) {
//       setState(() {
//         _allCourses = [];
//         _filteredCourses = [];
//       });
//       return;
//     }

//     setState(() => _isLoadingCourses = true);

//     try {
//       final response = await http.get(
//         Uri.parse('https://bgnuerp.online/api/get_courses?user_id=$userId'),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         if (data is List) {
//           setState(() {
//             _allCourses = data.map((course) {
//               return {
//                 'id': course['id'].toString(),
//                 'code': course['subject_code'].toString(),
//                 'name': course['subject_name'].toString(),
//                 'display':
//                     '${course['subject_code']} - ${course['subject_name']}'
//               };
//             }).toList();
//             _filteredCourses = List.from(_allCourses);
//           });
//         } else {
//           throw Exception('Invalid course data format - expected array');
//         }
//       } else {
//         throw Exception('Failed to load courses: ${response.statusCode}');
//       }
//     } catch (e) {
//       logDebug('Error fetching courses: $e');
//       if (mounted) {
//         showToast('Error loading courses', context: context);
//       }
//       setState(() {
//         _allCourses = [];
//         _filteredCourses = [];
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _isLoadingCourses = false);
//       }
//     }
//   }

//   void _filterCourses() {
//     final query = _courseSearchController.text.toLowerCase();
//     setState(() {
//       _filteredCourses = _allCourses.where((course) {
//         return course['code'].toLowerCase().contains(query) ||
//             course['name'].toLowerCase().contains(query) ||
//             course['display'].toLowerCase().contains(query);
//       }).toList();
//     });
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedSemester == null ||
//         _selectedCreditHours == null ||
//         _selectedCourse == null) {
//       if (mounted) {
//         showToast('Please fill all required fields', context: context);
//       }
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     // Find the selected course details
//     final selectedCourse = _allCourses.firstWhere(
//       (course) => course['display'] == _selectedCourse,
//       orElse: () => {'id': '', 'code': '', 'name': ''},
//     );

//     final data = {
//       'user_id': _userIdController.text.trim(),
//       'course_id': selectedCourse['id'],
//       'course_code': selectedCourse['code'],
//       'course_name': selectedCourse['name'],
//       'semester_no': _selectedSemester!,
//       'credit_hours': _selectedCreditHours!,
//       'marks': _marksController.text.trim(),
//     };

//     try {
//       final hasInternet = await checkInternet();

//       if (hasInternet) {
//         final response = await postGradeData(data);
//         logDebug('API Response: ${response.statusCode} - ${response.body}');

//         if (response.statusCode >= 200 && response.statusCode < 300) {
//           try {
//             final responseData = jsonDecode(response.body);
//             if (mounted) {
//               showToast(
//                 responseData['message'] ?? 'Grade saved successfully',
//                 context: context,
//               );
//               _clearForm();
//               await processPendingSubmissions(context);
//             }
//           } catch (e) {
//             logDebug('Error parsing response: $e');
//             if (mounted) {
//               showToast('Grade saved successfully', context: context);
//               _clearForm();
//               await processPendingSubmissions(context);
//             }
//           }
//         } else {
//           final errorMessage = _getErrorMessage(response);
//           throw Exception(errorMessage);
//         }
//       } else {
//         await saveToLocal(data);
//         if (mounted) {
//           showToast('Saved locally (offline)', context: context);
//           _clearForm();
//         }
//       }
//     } catch (e) {
//       logDebug('Submission error: $e');
//       if (mounted) {
//         showToast('Error: ${e.toString()}', context: context);
//       }
//       await saveToLocal(data);
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
//     }
//   }

//   String _getErrorMessage(http.Response response) {
//     try {
//       final responseData = jsonDecode(response.body);
//       return responseData['message'] ??
//           responseData['error'] ??
//           'Server error: ${response.statusCode}';
//     } catch (e) {
//       return 'Server error: ${response.statusCode}';
//     }
//   }

//   void _clearForm() {
//     _formKey.currentState?.reset();
//     _courseSearchController.clear();
//     setState(() {
//       _selectedSemester = null;
//       _selectedCreditHours = null;
//       _selectedCourse = null;
//       _isDropdownOpen = false;
//     });
//     _removeOverlay();
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
//               _buildSearchableCourseDropdown(),
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

//   Widget _buildSearchableCourseDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Course Name',
//           style: TextStyle(fontSize: 16, color: Colors.black54),
//         ),
//         const SizedBox(height: 8),
//         CompositedTransformTarget(
//           link: _layerLink,
//           child: TextFormField(
//             controller: TextEditingController(text: _selectedCourse),
//             readOnly: true,
//             decoration: InputDecoration(
//               hintText: 'Select Course',
//               prefixIcon: const Icon(Icons.menu_book, color: Colors.blue),
//               suffixIcon: _isLoadingCourses
//                   ? const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   : Icon(
//                       _isDropdownOpen
//                           ? Icons.arrow_drop_up
//                           : Icons.arrow_drop_down,
//                     ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: const BorderSide(color: Colors.grey),
//               ),
//             ),
//             validator: (value) => value == null || value.isEmpty
//                 ? 'Please select a course'
//                 : null,
//             onTap: () {
//               if (_userIdController.text.isEmpty) {
//                 showToast('Please enter User ID first', context: context);
//                 return;
//               }
//               _courseFocusNode.requestFocus();
//               _showOverlay();
//             },
//           ),
//         ),
//       ],
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
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class DataEntryPage extends StatefulWidget {
//   const DataEntryPage({super.key});

//   @override
//   State<DataEntryPage> createState() => _DataEntryPageState();
// }

// class _DataEntryPageState extends State<DataEntryPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _userIdController = TextEditingController();
//   final TextEditingController _marksController = TextEditingController();
//   final TextEditingController _courseSearchController = TextEditingController();

//   String? _selectedSemester;
//   String? _selectedCreditHours;
//   String? _selectedCourse;
//   List<Map<String, dynamic>> _allCourses = [];
//   List<Map<String, dynamic>> _filteredCourses = [];
//   bool _isLoadingCourses = false;
//   bool _isDropdownOpen = false;
//   final FocusNode _courseFocusNode = FocusNode();

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
//   void initState() {
//     super.initState();
//     _userIdController.addListener(_fetchCourses);
//     _courseSearchController.addListener(_filterCourses);
//     _courseFocusNode.addListener(() {
//       if (_courseFocusNode.hasFocus && _allCourses.isNotEmpty) {
//         setState(() => _isDropdownOpen = true);
//       } else {
//         setState(() => _isDropdownOpen = false);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _userIdController.dispose();
//     _marksController.dispose();
//     _courseSearchController.dispose();
//     _courseFocusNode.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchCourses() async {
//     final userId = _userIdController.text.trim();
//     if (userId.isEmpty) {
//       setState(() {
//         _allCourses = [];
//         _filteredCourses = [];
//       });
//       return;
//     }

//     setState(() => _isLoadingCourses = true);

//     try {
//       final response = await http.get(
//         Uri.parse('https://bgnuerp.online/api/get_courses?user_id=$userId'),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           _allCourses = data.map((course) {
//             return {
//               'id': course['id'].toString(),
//               'code': course['subject_code'].toString(),
//               'name': course['subject_name'].toString(),
//               'display': '${course['subject_code']} - ${course['subject_name']}'
//             };
//           }).toList();
//           _filteredCourses = List.from(_allCourses);
//         });
//       } else {
//         throw Exception('Failed to load courses: ${response.statusCode}');
//       }
//     } catch (e) {
//       logDebug('Error fetching courses: $e');
//       if (mounted) {
//         showToast('Error loading courses', context: context);
//       }
//       setState(() {
//         _allCourses = [];
//         _filteredCourses = [];
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _isLoadingCourses = false);
//       }
//     }
//   }

//   void _filterCourses() {
//     final query = _courseSearchController.text.toLowerCase();
//     setState(() {
//       _filteredCourses = _allCourses.where((course) {
//         return course['code'].toLowerCase().contains(query) ||
//             course['name'].toLowerCase().contains(query) ||
//             course['display'].toLowerCase().contains(query);
//       }).toList();
//     });
//   }

//   // ... (keep all other methods the same until build method)

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
//               _buildCourseDropdown(),
//               const SizedBox(height: 16),
//               // ... (rest of the form fields remain the same)
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCourseDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Course Name',
//           style: TextStyle(fontSize: 16, color: Colors.black54),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _courseSearchController,
//           focusNode: _courseFocusNode,
//           decoration: InputDecoration(
//             hintText: 'Search courses...',
//             prefixIcon: const Icon(Icons.search),
//             suffixIcon: _isLoadingCourses
//                 ? const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : Icon(_isDropdownOpen
//                     ? Icons.arrow_drop_up
//                     : Icons.arrow_drop_down),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           onTap: () {
//             if (_userIdController.text.isEmpty) {
//               showToast('Please enter User ID first', context: context);
//               return;
//             }
//             _courseFocusNode.requestFocus();
//             setState(() => _isDropdownOpen = true);
//           },
//           validator: (value) =>
//               _selectedCourse == null ? 'Please select a course' : null,
//         ),
//         if (_isDropdownOpen && _filteredCourses.isNotEmpty)
//           Container(
//             margin: const EdgeInsets.only(top: 4),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.3,
//             ),
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: _filteredCourses.length,
//               itemBuilder: (context, index) {
//                 final course = _filteredCourses[index];
//                 return ListTile(
//                   title: Text(course['display']),
//                   onTap: () {
//                     setState(() {
//                       _selectedCourse = course['display'];
//                       _isDropdownOpen = false;
//                     });
//                     _courseFocusNode.unfocus();
//                   },
//                 );
//               },
//             ),
//           ),
//       ],
//     );
//   }

//   // ... (keep all other widget building methods the same)
// }

// import 'package:flutter/material.dart';
// import 'helpers.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class DataEntryPage extends StatefulWidget {
//   const DataEntryPage({super.key});

//   @override
//   State<DataEntryPage> createState() => _DataEntryPageState();
// }

// class _DataEntryPageState extends State<DataEntryPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _userIdController = TextEditingController();
//   final TextEditingController _marksController = TextEditingController();
//   final TextEditingController _courseSearchController = TextEditingController();

//   String? _selectedSemester;
//   String? _selectedCreditHours;
//   String? _selectedCourse;
//   List<Map<String, dynamic>> _allCourses = [];
//   List<Map<String, dynamic>> _filteredCourses = [];
//   bool _isLoadingCourses = false;
//   bool _isDropdownOpen = false;
//   final FocusNode _courseFocusNode = FocusNode();

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
//   void initState() {
//     super.initState();
//     _userIdController.addListener(_fetchCourses);
//     _courseSearchController.addListener(_filterCourses);
//     _courseFocusNode.addListener(() {
//       if (_courseFocusNode.hasFocus && _allCourses.isNotEmpty) {
//         setState(() => _isDropdownOpen = true);
//       } else {
//         setState(() => _isDropdownOpen = false);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _userIdController.dispose();
//     _marksController.dispose();
//     _courseSearchController.dispose();
//     _courseFocusNode.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchCourses() async {
//     final userId = _userIdController.text.trim();
//     if (userId.isEmpty) {
//       setState(() {
//         _allCourses = [];
//         _filteredCourses = [];
//       });
//       return;
//     }

//     setState(() => _isLoadingCourses = true);

//     try {
//       final response = await http.get(
//         Uri.parse('https://bgnuerp.online/api/get_courses?user_id=$userId'),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           _allCourses = data.map((course) {
//             return {
//               'id': course['id'].toString(),
//               'code': course['subject_code'].toString(),
//               'name': course['subject_name'].toString(),
//               'display': '${course['subject_code']} - ${course['subject_name']}'
//             };
//           }).toList();
//           _filteredCourses = List.from(_allCourses);
//         });
//       } else {
//         throw Exception('Failed to load courses: ${response.statusCode}');
//       }
//     } catch (e) {
//       logDebug('Error fetching courses: $e');
//       if (mounted) {
//         showToast('Error loading courses', context: context);
//       }
//       setState(() {
//         _allCourses = [];
//         _filteredCourses = [];
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _isLoadingCourses = false);
//       }
//     }
//   }

//   void _filterCourses() {
//     final query = _courseSearchController.text.toLowerCase();
//     setState(() {
//       _filteredCourses = _allCourses.where((course) {
//         return course['code'].toLowerCase().contains(query) ||
//             course['name'].toLowerCase().contains(query) ||
//             course['display'].toLowerCase().contains(query);
//       }).toList();
//     });
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedSemester == null ||
//         _selectedCreditHours == null ||
//         _selectedCourse == null) {
//       if (mounted) {
//         showToast('Please fill all required fields', context: context);
//       }
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     // Find the selected course details
//     final selectedCourse = _allCourses.firstWhere(
//       (course) => course['display'] == _selectedCourse,
//       orElse: () => {'id': '', 'code': '', 'name': ''},
//     );

//     final data = {
//       'user_id': _userIdController.text.trim(),
//       'course_id': selectedCourse['id'],
//       'course_code': selectedCourse['code'],
//       'course_name': selectedCourse['name'],
//       'semester_no': _selectedSemester!,
//       'credit_hours': _selectedCreditHours!,
//       'marks': _marksController.text.trim(),
//     };

//     try {
//       final hasInternet = await checkInternet();

//       if (hasInternet) {
//         final response = await postGradeData(data);
//         logDebug('API Response: ${response.statusCode} - ${response.body}');

//         if (response.statusCode >= 200 && response.statusCode < 300) {
//           try {
//             final responseData = jsonDecode(response.body);
//             if (mounted) {
//               showToast(
//                 responseData['message'] ?? 'Grade saved successfully',
//                 context: context,
//               );
//               _clearForm();
//               await processPendingSubmissions(context);
//             }
//           } catch (e) {
//             logDebug('Error parsing response: $e');
//             if (mounted) {
//               showToast('Grade saved successfully', context: context);
//               _clearForm();
//               await processPendingSubmissions(context);
//             }
//           }
//         } else {
//           final errorMessage = _getErrorMessage(response);
//           throw Exception(errorMessage);
//         }
//       } else {
//         await saveToLocal(data);
//         if (mounted) {
//           showToast('Saved locally (offline)', context: context);
//           _clearForm();
//         }
//       }
//     } catch (e) {
//       logDebug('Submission error: $e');
//       if (mounted) {
//         showToast('Error: ${e.toString()}', context: context);
//       }
//       await saveToLocal(data);
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
//     }
//   }

//   String _getErrorMessage(http.Response response) {
//     try {
//       final responseData = jsonDecode(response.body);
//       return responseData['message'] ??
//           responseData['error'] ??
//           'Server error: ${response.statusCode}';
//     } catch (e) {
//       return 'Server error: ${response.statusCode}';
//     }
//   }

//   void _clearForm() {
//     _formKey.currentState?.reset();
//     _courseSearchController.clear();
//     setState(() {
//       _selectedSemester = null;
//       _selectedCreditHours = null;
//       _selectedCourse = null;
//       _isDropdownOpen = false;
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
//               TextFormField(
//                 controller: _userIdController,
//                 decoration: InputDecoration(
//                   labelText: 'User ID',
//                   prefixIcon: const Icon(Icons.person, color: Colors.blue),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Colors.blue),
//                   ),
//                 ),
//                 validator: (value) => value!.trim().isEmpty ? 'Required' : null,
//               ),
//               const SizedBox(height: 16),
//               _buildCourseDropdown(),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedSemester,
//                 items: _semesterOptions.map((item) {
//                   return DropdownMenuItem<String>(
//                     value: item,
//                     child: Text(item),
//                   );
//                 }).toList(),
//                 onChanged: (value) => setState(() => _selectedSemester = value),
//                 decoration: InputDecoration(
//                   labelText: 'Select Semester',
//                   prefixIcon: const Icon(Icons.school, color: Colors.blue),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 validator: (value) => value == null ? 'Required' : null,
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedCreditHours,
//                 items: _creditHoursOptions.map((item) {
//                   return DropdownMenuItem<String>(
//                     value: item,
//                     child: Text(item),
//                   );
//                 }).toList(),
//                 onChanged: (value) =>
//                     setState(() => _selectedCreditHours = value),
//                 decoration: InputDecoration(
//                   labelText: 'Select Credit Hours',
//                   prefixIcon:
//                       const Icon(Icons.hourglass_bottom, color: Colors.blue),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 validator: (value) => value == null ? 'Required' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _marksController,
//                 decoration: InputDecoration(
//                   labelText: 'Marks',
//                   prefixIcon: const Icon(Icons.grade, color: Colors.blue),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Colors.blue),
//                   ),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value!.trim().isEmpty) return 'Required';
//                   final marks = int.tryParse(value);
//                   if (marks == null) return 'Enter valid number';
//                   if (marks < 0 || marks > 100) return 'Marks must be 0-100';
//                   return null;
//                 },
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

//   Widget _buildCourseDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Course Name',
//           style: TextStyle(fontSize: 16, color: Colors.black54),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _courseSearchController,
//           focusNode: _courseFocusNode,
//           decoration: InputDecoration(
//             hintText: 'Search courses...',
//             prefixIcon: const Icon(Icons.search),
//             suffixIcon: _isLoadingCourses
//                 ? const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : Icon(_isDropdownOpen
//                     ? Icons.arrow_drop_up
//                     : Icons.arrow_drop_down),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           onTap: () {
//             if (_userIdController.text.isEmpty) {
//               showToast('Please enter User ID first', context: context);
//               return;
//             }
//             _courseFocusNode.requestFocus();
//             setState(() => _isDropdownOpen = true);
//           },
//           validator: (value) =>
//               _selectedCourse == null ? 'Please select a course' : null,
//         ),
//         if (_isDropdownOpen && _filteredCourses.isNotEmpty)
//           Container(
//             margin: const EdgeInsets.only(top: 4),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.3,
//             ),
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: _filteredCourses.length,
//               itemBuilder: (context, index) {
//                 final course = _filteredCourses[index];
//                 return ListTile(
//                   title: Text(course['display']),
//                   onTap: () {
//                     setState(() {
//                       _selectedCourse = course['display'];
//                       _isDropdownOpen = false;
//                     });
//                     _courseFocusNode.unfocus();
//                   },
//                 );
//               },
//             ),
//           ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'helpers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DataEntryPage extends StatefulWidget {
  const DataEntryPage({super.key});

  @override
  State<DataEntryPage> createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  final TextEditingController _courseSearchController = TextEditingController();

  String? _selectedSemester;
  String? _selectedCreditHours;
  String? _selectedCourse;
  String? _selectedCourseId;
  String? _selectedCourseCode;
  String? _selectedCourseName;
  List<Map<String, dynamic>> _allCourses = [];
  List<Map<String, dynamic>> _filteredCourses = [];
  bool _isLoadingCourses = false;
  bool _isDropdownOpen = false;
  final FocusNode _courseFocusNode = FocusNode();

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
  void initState() {
    super.initState();
    _userIdController.addListener(_fetchCourses);
    _courseSearchController.addListener(_filterCourses);
    _courseFocusNode.addListener(_handleCourseFocusChange);
  }

  void _handleCourseFocusChange() {
    if (_courseFocusNode.hasFocus && _allCourses.isNotEmpty) {
      setState(() => _isDropdownOpen = true);
    } else {
      setState(() => _isDropdownOpen = false);
    }
  }

  @override
  void dispose() {
    _userIdController.removeListener(_fetchCourses);
    _courseSearchController.removeListener(_filterCourses);
    _courseFocusNode.removeListener(_handleCourseFocusChange);
    _userIdController.dispose();
    _marksController.dispose();
    _courseSearchController.dispose();
    _courseFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchCourses() async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      setState(() {
        _allCourses = [];
        _filteredCourses = [];
        _selectedCourse = null;
        _selectedCourseId = null;
        _selectedCourseCode = null;
        _selectedCourseName = null;
      });
      return;
    }

    setState(() => _isLoadingCourses = true);

    try {
      final response = await http.get(
        Uri.parse('https://bgnuerp.online/api/get_courses?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _allCourses = data.map((course) {
            return {
              'id': course['id'].toString(),
              'code': course['subject_code'].toString(),
              'name': course['subject_name'].toString(),
              'display': '${course['subject_code']} - ${course['subject_name']}'
            };
          }).toList();
          _filteredCourses = List.from(_allCourses);
        });
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      logDebug('Error fetching courses: $e');
      if (mounted) {
        showToast('Error loading courses', context: context);
      }
      setState(() {
        _allCourses = [];
        _filteredCourses = [];
        _selectedCourse = null;
        _selectedCourseId = null;
        _selectedCourseCode = null;
        _selectedCourseName = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingCourses = false);
      }
    }
  }

  void _filterCourses() {
    final query = _courseSearchController.text.toLowerCase();
    setState(() {
      _filteredCourses = _allCourses.where((course) {
        return course['code'].toLowerCase().contains(query) ||
            course['name'].toLowerCase().contains(query) ||
            course['display'].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSemester == null ||
        _selectedCreditHours == null ||
        _selectedCourse == null) {
      if (mounted) {
        showToast('Please fill all required fields', context: context);
      }
      return;
    }

    setState(() => _isSubmitting = true);

    final data = {
      'user_id': _userIdController.text.trim(),
      'course_id': _selectedCourseId,
      'course_code': _selectedCourseCode,
      'course_name': _selectedCourseName,
      'semester_no': _selectedSemester!,
      'credit_hours': _selectedCreditHours!,
      'marks': _marksController.text.trim(),
    };

    try {
      final hasInternet = await checkInternet();

      if (hasInternet) {
        final response = await postGradeData(data);
        logDebug('API Response: ${response.statusCode} - ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          try {
            final responseData = jsonDecode(response.body);
            if (mounted) {
              showToast(
                responseData['message'] ?? 'Grade saved successfully',
                context: context,
              );
              _clearForm();
              await processPendingSubmissions(context);
            }
          } catch (e) {
            logDebug('Error parsing response: $e');
            if (mounted) {
              showToast('Grade saved successfully', context: context);
              _clearForm();
              await processPendingSubmissions(context);
            }
          }
        } else {
          final errorMessage = _getErrorMessage(response);
          throw Exception(errorMessage);
        }
      } else {
        await saveToLocal(data);
        if (mounted) {
          showToast('Saved locally (offline)', context: context);
          _clearForm();
        }
      }
    } catch (e) {
      logDebug('Submission error: $e');
      if (mounted) {
        showToast('Error: ${e.toString()}', context: context);
      }
      await saveToLocal(data);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getErrorMessage(http.Response response) {
    try {
      final responseData = jsonDecode(response.body);
      return responseData['message'] ??
          responseData['error'] ??
          'Server error: ${response.statusCode}';
    } catch (e) {
      return 'Server error: ${response.statusCode}';
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _courseSearchController.clear();
    setState(() {
      _selectedSemester = null;
      _selectedCreditHours = null;
      _selectedCourse = null;
      _selectedCourseId = null;
      _selectedCourseCode = null;
      _selectedCourseName = null;
      _isDropdownOpen = false;
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
              TextFormField(
                controller: _userIdController,
                decoration: InputDecoration(
                  labelText: 'User ID',
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) => value!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildCourseDropdown(),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                items: _semesterOptions.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedSemester = value),
                decoration: InputDecoration(
                  labelText: 'Select Semester',
                  prefixIcon: const Icon(Icons.school, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCreditHours,
                items: _creditHoursOptions.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedCreditHours = value),
                decoration: InputDecoration(
                  labelText: 'Select Credit Hours',
                  prefixIcon:
                      const Icon(Icons.hourglass_bottom, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _marksController,
                decoration: InputDecoration(
                  labelText: 'Marks',
                  prefixIcon: const Icon(Icons.grade, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.trim().isEmpty) return 'Required';
                  final marks = int.tryParse(value);
                  if (marks == null) return 'Enter valid number';
                  if (marks < 0 || marks > 100) return 'Marks must be 0-100';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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

  Widget _buildCourseDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course Name',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _courseSearchController,
          focusNode: _courseFocusNode,
          decoration: InputDecoration(
            hintText: _selectedCourse ?? 'Search courses...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isLoadingCourses
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_isDropdownOpen
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onTap: () {
            if (_userIdController.text.isEmpty) {
              showToast('Please enter User ID first', context: context);
              return;
            }
            _courseFocusNode.requestFocus();
            setState(() => _isDropdownOpen = true);
          },
          validator: (value) =>
              _selectedCourse == null ? 'Please select a course' : null,
        ),
        if (_isDropdownOpen && _filteredCourses.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredCourses.length,
              itemBuilder: (context, index) {
                final course = _filteredCourses[index];
                return ListTile(
                  title: Text(course['display']),
                  onTap: () {
                    setState(() {
                      _selectedCourse = course['display'];
                      _selectedCourseId = course['id'];
                      _selectedCourseCode = course['code'];
                      _selectedCourseName = course['name'];
                      _isDropdownOpen = false;
                      _courseSearchController.clear();
                    });
                    _courseFocusNode.unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
