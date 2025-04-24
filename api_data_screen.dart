import 'package:flutter/material.dart';
import 'api_service.dart';

class ApiDataScreen extends StatefulWidget {
  final ApiService apiService;

  const ApiDataScreen({super.key, required this.apiService});

  @override
  State<ApiDataScreen> createState() => _ApiDataScreenState();
}

class _ApiDataScreenState extends State<ApiDataScreen> {
  List<dynamic> _grades = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final result = await widget.apiService.fetchGrades();

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _grades = result['data'] ?? [];
        if (result['error'] != null) {
          _error = result['error']!;
        }
      } else {
        _error = result['error'] ?? 'Failed to load data';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Grades'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_error.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.orange[100],
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error)),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _grades.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No grades found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _grades.length,
              itemBuilder: (context, index) {
                final grade = _grades[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      grade['course_name'] ?? 'No Course Name',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User ID: ${grade['user_id']}'),
                        Text('Semester: ${grade['semester_no']}'),
                        Text('Grade: ${grade['grade']} (${grade['marks']} marks)'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}