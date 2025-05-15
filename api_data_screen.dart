import 'package:flutter/material.dart';
import 'api_service.dart';

class ApiDataScreen extends StatefulWidget {
  const ApiDataScreen({super.key});

  @override
  _ApiDataScreenState createState() => _ApiDataScreenState();
}

class _ApiDataScreenState extends State<ApiDataScreen> {
  List<dynamic> _donors = [];
  bool _isLoading = true;
  bool _errorOccurred = false;

  @override
  void initState() {
    super.initState();
    _fetchDonors();
  }

  Future<void> _fetchDonors() async {
    try {
      final donors = await ApiService().getDonors();
      setState(() {
        _donors = donors;
        _isLoading = false;
        _errorOccurred = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorOccurred = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch donors: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDonors,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorOccurred
          ? const Center(child: Text('Failed to load data'))
          : _donors.isEmpty
          ? const Center(child: Text('No donors found'))
          : ListView.builder(
        itemCount: _donors.length,
        itemBuilder: (context, index) {
          final donor = _donors[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                vertical: 4, horizontal: 8),
            child: ListTile(
              title: Text(donor['name'] ?? 'No Name'),
              subtitle: Text(
                  '${donor['blood_group']} - ${donor['city']}'),
              trailing: Text(donor['gender'] ?? ''),
            ),
          );
        },
      ),
    );
  }
}


