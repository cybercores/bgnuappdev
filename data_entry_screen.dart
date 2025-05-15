import 'package:flutter/material.dart';
import 'api_service.dart';
import 'database_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({super.key});

  @override
  _DataEntryScreenState createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _selectedBloodGroup;
  String? _selectedCity;
  String? _selectedGender;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  final List<String> _cities = [
    'Karachi', 'Lahore', 'Islamabad', 'Rawalpindi',
    'Faisalabad', 'Multan', 'Hyderabad', 'Peshawar',
    'Quetta', 'Gujranwala', 'Sialkot', 'Bahawalpur'
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _cnicController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null || _selectedCity == null || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all dropdown fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final donorData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone_number': _phoneController.text,
      'password': _passwordController.text,
      'cnic': _cnicController.text,
      'blood_group': _selectedBloodGroup,
      'city': _selectedCity,
      'gender': _selectedGender,
      'age': int.parse(_ageController.text),
    };

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await ApiService().addDonor(donorData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donor added successfully!')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedBloodGroup = null;
          _selectedCity = null;
          _selectedGender = null;
        });
      } else {
        await DatabaseHelper.instance.insertDonor(donorData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved locally. Will sync when online.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Donor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.pushNamed(context, '/donors'),
          ),
          IconButton(
            icon: const Icon(Icons.cloud_off),
            onPressed: () => Navigator.pushNamed(context, '/offline'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter email' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _phoneController,
                decoration:
                const InputDecoration(labelText: 'Phone Number'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter phone number' : null,
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                value!.isEmpty ? 'Please enter password' : null,
              ),
              TextFormField(
                controller: _cnicController,
                decoration: const InputDecoration(labelText: 'CNIC'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter CNIC' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: 'Blood Group'),
                items: _bloodGroups.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedBloodGroup = newValue;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select blood group' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(labelText: 'City'),
                items: _cities.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCity = newValue;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select city' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: _genders.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select gender' : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter age';
                  final age = int.tryParse(value);
                  if (age == null) return 'Please enter a valid number';
                  if (age < 18 || age > 65) return 'Age must be between 18-65';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

