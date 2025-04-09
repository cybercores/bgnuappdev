import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Future<List<Map<String, dynamic>>> fetchGrades() async {
    const apiUrl = 'https://bgnuerp.online/api/gradeapi';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network Error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Data Parsing Error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected Error: ${e.toString()}');
    }
  }
}
