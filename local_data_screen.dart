import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'api_service.dart';
import 'database_helper.dart';

class LocalDataScreen extends StatefulWidget {
  final ApiService apiService;

  const LocalDataScreen({super.key, required this.apiService});

  @override
  State<LocalDataScreen> createState() => _LocalDataScreenState();
}

class _LocalDataScreenState extends State<LocalDataScreen> {
  List<Map<String, dynamic>> _grades = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final data = await DatabaseHelper.instance.getAllGrades();
      setState(() {
        _grades = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load local data: ${e.toString()}';
      });
    }
  }

  Future<void> _syncData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      await widget.apiService.syncLocalGrades();
      await _loadLocalData(); // Refresh the data after sync

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync completed'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadSingleGrade(Map<String, dynamic> grade) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await widget.apiService.submitGrade({
        'user_id': grade['user_id'],
        'course_name': grade['course_name'],
        'semester_no': grade['semester_no'],
        'credit_hours': grade['credit_hours'],
        'marks': grade['marks'],
        'grade': grade['grade'],
      });

      if (result['success'] == true) {
        await DatabaseHelper.instance.updateGradeSyncStatus(grade['id'] as int);
        await _loadLocalData(); // Refresh the list

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grade uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteGrade(int id) async {
    try {
      await DatabaseHelper.instance.deleteGrade(id);
      await _loadLocalData(); // Refresh the list

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grade deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Grades'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncData,
            tooltip: 'Sync all data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : _grades.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storage, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No local grades found',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
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
                  Text(
                    grade['is_synced'] == 1
                        ? 'Synced with API'
                        : 'Not synced',
                    style: TextStyle(
                      color: grade['is_synced'] == 1
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteGrade(grade['id'] as int),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cloud_upload),
                    onPressed: grade['is_synced'] == 1
                        ? null
                        : () => _uploadSingleGrade(grade),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}