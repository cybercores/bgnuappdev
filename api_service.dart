import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ApiService {
  final Logger _logger = Logger();
  final String _baseUrl = 'https://bgnuerp.online/api/gradeapi';

  Future<List<dynamic>> fetchGrades() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body) as List;
      } else {
        _logger.e('API Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to load grades. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Network Error: $e');
      throw Exception('Network error occurred. Please try again.');
    }
  }
}
