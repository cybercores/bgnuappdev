import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database_helper.dart';

class ApiService {
  final String _baseUrl = "https://devtechtop.com/management/public/api";
  final String _selectDataEndpoint = "/select_data";
  final String _gradeEndpoint = "/grades";

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, dynamic>> submitGrade(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl$_gradeEndpoint"),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        // Save to SQLite when API fails
        await DatabaseHelper.instance.insertGrade(data);
        return {
          'success': false,
          'error': 'Error ${response.statusCode}: ${response.body}. Data saved locally.',
        };
      }
    } catch (e) {
      // Save to SQLite when offline
      await DatabaseHelper.instance.insertGrade(data);
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}. Data saved locally.',
      };
    }
  }

  Future<Map<String, dynamic>> fetchGrades() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl$_selectDataEndpoint"),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data is List ? data : [data], // Ensure we always return a list
        };
      } else {
        // Fallback to local data when API fails
        final localData = await DatabaseHelper.instance.getAllGrades();
        return {
          'success': localData.isNotEmpty,
          'data': localData,
          'error': localData.isEmpty
              ? 'Failed to fetch data: ${response.statusCode}'
              : 'Using local data as fallback',
        };
      }
    } catch (e) {
      // Fallback to local data when offline
      final localData = await DatabaseHelper.instance.getAllGrades();
      return {
        'success': localData.isNotEmpty,
        'data': localData,
        'error': localData.isEmpty
            ? 'Network error: ${e.toString()}'
            : 'Using local data as fallback',
      };
    }
  }

  Future<void> syncLocalGrades() async {
    final unsyncedGrades = await DatabaseHelper.instance.getUnsyncedGrades();
    for (var grade in unsyncedGrades) {
      try {
        final response = await http.post(
          Uri.parse("$_baseUrl$_gradeEndpoint"),
          headers: _headers,
          body: json.encode({
            'user_id': grade['user_id'],
            'course_name': grade['course_name'],
            'semester_no': grade['semester_no'],
            'credit_hours': grade['credit_hours'],
            'marks': grade['marks'],
            'grade': grade['grade'],
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          await DatabaseHelper.instance.updateGradeSyncStatus(grade['id'] as int);
        }
      } catch (e) {
        continue; // Skip this grade and try others
      }
    }
  }
}