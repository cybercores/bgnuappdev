import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'goodvibe.cybercoreuk.com';
  static const String _apiPath = '/api/donors';

  Future<List<dynamic>> getDonors() async {
    final uri = Uri.https(_baseUrl, _apiPath);
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load donors: ${response.statusCode}');
    }
  }

  Future<void> addDonor(Map<String, dynamic> donorData) async {
    final uri = Uri.https(_baseUrl, _apiPath);
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(donorData),
    );

    if (response.statusCode != 201) {
      final errorBody = json.decode(response.body);
      throw Exception(
          'Failed to add donor (${response.statusCode}): ${errorBody['message'] ?? response.body}');
    }
  }
}


