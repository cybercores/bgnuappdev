// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'api_service.dart';
//
// class DataEntryScreen extends StatefulWidget {
//   final ApiService apiService;
//
//   const DataEntryScreen({super.key, required this.apiService});
//
//   @override
//   State<DataEntryScreen> createState() => _DataEntryScreenState();
// }
//
// class _DataEntryScreenState extends State<DataEntryScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _ageController = TextEditingController();
//
//   String _bloodGroup = 'A+';
//   String _gender = 'Male';
//   bool _isSubmitting = false;
//
//   final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
//   final List<String> _genders = ['Male', 'Female', 'Other'];
//
//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isSubmitting = true);
//
//     try {
//       final formData = {
//         'name': _nameController.text.trim(),
//         'email': _emailController.text.trim(),
//         'phone': _phoneController.text.trim(),
//         'blood_group': _bloodGroup,
//         'city': _cityController.text.trim(),
//         'gender': _gender,
//         'age': _ageController.text.trim(),
//       };
//
//       final result = await widget.apiService.submitDonor(formData);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(result['message']),
//           backgroundColor: result['success'] ? Colors.green : Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//
//       if (result['success'] == true) {
//         _clearForm();
//       } else if (result['details'] != null) {
//         // Show validation errors if any
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Validation Errors'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: (result['details'] as Map<String, dynamic>)
//                   .entries
//                   .map((e) => Text('${e.key}: ${e.value.join(', ')}'))
//                   .toList(),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }
//
//   void _clearForm() {
//     _formKey.currentState?.reset();
//     _nameController.clear();
//     _emailController.clear();
//     _phoneController.clear();
//     _cityController.clear();
//     _ageController.clear();
//     setState(() {
//       _bloodGroup = 'A+';
//       _gender = 'Male';
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Register New Donor'),
//         centerTitle: true,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.red.shade700, Colors.red.shade400],
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     children: [
//                       _buildTextField('Full Name', _nameController, Icons.person),
//                       const SizedBox(height: 20),
//                       _buildEmailField('Email', _emailController),
//                       const SizedBox(height: 20),
//                       _buildPhoneField('Phone Number', _phoneController),
//                       const SizedBox(height: 20),
//                       _buildTextField('City', _cityController, Icons.location_city),
//                       const SizedBox(height: 20),
//                       _buildTextField('Age', _ageController, Icons.cake, TextInputType.number),
//                       const SizedBox(height: 20),
//                       _buildDropdown('Blood Group', _bloodGroups, _bloodGroup, (value) {
//                         setState(() => _bloodGroup = value!);
//                       }, Icons.bloodtype),
//                       const SizedBox(height: 20),
//                       _buildDropdown('Gender', _genders, _gender, (value) {
//                         setState(() => _gender = value!);
//                       }, Icons.transgender),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isSubmitting ? null : _submitForm,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.redAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isSubmitting
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text(
//                     'REGISTER DONOR',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(String label, TextEditingController controller, IconData icon,
//       [TextInputType? keyboardType]) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.redAccent),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: Colors.redAccent, width: 2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//       keyboardType: keyboardType,
//       validator: (value) => value?.isEmpty ?? true ? 'Please enter $label' : null,
//     );
//   }
//
//   Widget _buildEmailField(String label, TextEditingController controller) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: const Icon(Icons.email, color: Colors.redAccent),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: Colors.redAccent, width: 2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//       keyboardType: TextInputType.emailAddress,
//       validator: (value) {
//         if (value?.isEmpty ?? true) return 'Please enter email';
//         if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
//           return 'Enter a valid email';
//         }
//         return null;
//       },
//     );
//   }
//
//   Widget _buildPhoneField(String label, TextEditingController controller) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: const Icon(Icons.phone, color: Colors.redAccent),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: Colors.redAccent, width: 2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//       keyboardType: TextInputType.phone,
//       validator: (value) {
//         if (value?.isEmpty ?? true) return 'Please enter phone number';
//         if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value!)) {
//           return 'Enter a valid phone number';
//         }
//         return null;
//       },
//     );
//   }
//
//   Widget _buildDropdown(String label, List<String> items, String value,
//       ValueChanged<String?> onChanged, IconData icon) {
//     return DropdownButtonFormField<String>(
//       value: value,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.redAccent),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//       items: items.map((String value) {
//         return DropdownMenuItem<String>(
//           value: value,
//           child: Text(value),
//         );
//       }).toList(),
//       onChanged: onChanged,
//       validator: (value) => value == null ? 'Please select $label' : null,
//     );
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _cityController.dispose();
//     _ageController.dispose();
//     super.dispose();
//   }
// }
//
//
//
//
//
// import 'package:flutter/material.dart';
// import 'api_service.dart';
//
// class DataEntryScreen extends StatefulWidget {
//   final ApiService apiService;
//
//   const DataEntryScreen({super.key, required this.apiService});
//
//   @override
//   State<DataEntryScreen> createState() => _DataEntryScreenState();
// }
//
// class _DataEntryScreenState extends State<DataEntryScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _ageController = TextEditingController();
//
//   String _bloodGroup = 'A+';
//   String _gender = 'Male';
//   bool _isSubmitting = false;
//
//   final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
//   final List<String> _genders = ['Male', 'Female', 'Other'];
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _cityController.dispose();
//     _ageController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isSubmitting = true);
//
//     try {
//       final formData = {
//         'name': _nameController.text.trim(),
//         'email': _emailController.text.trim(),
//         'phone': _phoneController.text.trim(),
//         'blood_group': _bloodGroup,
//         'city': _cityController.text.trim(),
//         'gender': _gender,
//         'age': _ageController.text.trim(),
//       };
//
//       final result = await widget.apiService.submitDonor(formData);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(result['message']),
//           backgroundColor: result['success'] ? Colors.green : Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//
//       if (result['success'] == true) {
//         _clearForm();
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }
//
//   void _clearForm() {
//     _formKey.currentState?.reset();
//     _nameController.clear();
//     _emailController.clear();
//     _phoneController.clear();
//     _cityController.clear();
//     _ageController.clear();
//     setState(() {
//       _bloodGroup = 'A+';
//       _gender = 'Male';
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Register New Donor'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         controller: _nameController,
//                         decoration: const InputDecoration(
//                           labelText: 'Full Name',
//                           prefixIcon: Icon(Icons.person),
//                         ),
//                         validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _emailController,
//                         decoration: const InputDecoration(
//                           labelText: 'Email',
//                           prefixIcon: Icon(Icons.email),
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                         validator: (value) {
//                           if (value?.isEmpty ?? true) return 'Required';
//                           if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
//                             return 'Invalid email';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _phoneController,
//                         decoration: const InputDecoration(
//                           labelText: 'Phone Number',
//                           prefixIcon: Icon(Icons.phone),
//                         ),
//                         keyboardType: TextInputType.phone,
//                         validator: (value) {
//                           if (value?.isEmpty ?? true) return 'Required';
//                           if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value!)) {
//                             return 'Invalid phone';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _cityController,
//                         decoration: const InputDecoration(
//                           labelText: 'City',
//                           prefixIcon: Icon(Icons.location_city),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _ageController,
//                         decoration: const InputDecoration(
//                           labelText: 'Age',
//                           prefixIcon: Icon(Icons.calendar_today),
//                         ),
//                         keyboardType: TextInputType.number,
//                       ),
//                       const SizedBox(height: 16),
//                       DropdownButtonFormField<String>(
//                         value: _bloodGroup,
//                         items: _bloodGroups.map((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                         onChanged: (value) => setState(() => _bloodGroup = value!),
//                         decoration: const InputDecoration(
//                           labelText: 'Blood Group',
//                           prefixIcon: Icon(Icons.bloodtype),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       DropdownButtonFormField<String>(
//                         value: _gender,
//                         items: _genders.map((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                         onChanged: (value) => setState(() => _gender = value!),
//                         decoration: const InputDecoration(
//                           labelText: 'Gender',
//                           prefixIcon: Icon(Icons.transgender),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _isSubmitting ? null : _submitForm,
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//                 child: _isSubmitting
//                     ? const CircularProgressIndicator()
//                     : const Text('SUBMIT DONOR'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'api_service.dart';

class DataEntryScreen extends StatefulWidget {
  final ApiService apiService;

  const DataEntryScreen({super.key, required this.apiService});

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _ageController = TextEditingController();

  String _bloodGroup = 'A+';
  String _gender = 'Male';
  bool _isSubmitting = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final formData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'blood_group': _bloodGroup,
      'city': _cityController.text.trim(),
      'gender': _gender,
      'age': _ageController.text.trim(),
    };

    final result = await widget.apiService.submitDonor(formData);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    if (result['success'] == true) {
      _clearForm();
    } else if (result['details'] != null) {
      // Show detailed validation errors if available
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Validation Errors'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: (result['details'] as Map<String, dynamic>)
                  .entries
                  .map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('• ${e.key}: ${e.value.join('\n')}'),
              ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    setState(() => _isSubmitting = false);
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _cityController.clear();
    _ageController.clear();
    setState(() {
      _bloodGroup = 'A+';
      _gender = 'Male';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Donor'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required field';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return 'Enter valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required field';
                          if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value!)) {
                            return 'Enter valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          prefixIcon: Icon(Icons.location_city),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ageController,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isNotEmpty ?? false) {
                            final age = int.tryParse(value!);
                            if (age == null || age <= 0 || age > 120) {
                              return 'Enter valid age';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _bloodGroup,
                        items: _bloodGroups.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _bloodGroup = value!),
                        decoration: const InputDecoration(
                          labelText: 'Blood Group *',
                          prefixIcon: Icon(Icons.bloodtype),
                        ),
                        validator: (value) => value == null ? 'Required field' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        items: _genders.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _gender = value!),
                        decoration: const InputDecoration(
                          labelText: 'Gender *',
                          prefixIcon: Icon(Icons.transgender),
                        ),
                        validator: (value) => value == null ? 'Required field' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'REGISTER DONOR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
}