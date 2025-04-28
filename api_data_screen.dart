// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:sqflite/sqflite.dart';
// import 'database_helper.dart';
//
// class ApiService {
//   final String _baseUrl = "https://goodvibe.cybercoreuk.com/api";
//   final Map<String, String> _headers = {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//   };
//   final DatabaseHelper _dbHelper = DatabaseHelper.instance;
//
//   // Check internet connection status
//   Future<bool> get isConnected async {
//     final connectivityResult = await Connectivity().checkConnectivity();
//     return connectivityResult != ConnectivityResult.none;
//   }
//
//   // Submit donor data with automatic offline handling
//   Future<Map<String, dynamic>> submitDonor(Map<String, dynamic> data) async {
//     try {
//       // Prepare the API payload
//       final payload = {
//         "name": data['name'],
//         "email": data['email'],
//         "phone_number": data['phone'],
//         "password": "defaultPassword123", // Required by API
//         "cnic": "1234567890123", // Required by API
//         "blood_group": data['blood_group'],
//         "city": data['city'] ?? "Unknown",
//         "gender": data['gender'] ?? "Other",
//         "age": data['age'] != null ? int.tryParse(data['age'].toString()) ?? 0 : 0,
//       };
//
//       // Try to send to API if connected
//       if (await isConnected) {
//         final response = await http.post(
//           Uri.parse("$_baseUrl/donors"),
//           headers: _headers,
//           body: json.encode(payload),
//         );
//
//         // Handle API response
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           return _handleSuccess(response);
//         } else if (response.statusCode == 422) {
//           return await _handleValidationError(response, data);
//         } else {
//           return await _handleApiError(response, data);
//         }
//       } else {
//         // Save to local storage if offline
//         return await _saveToLocalStorage(data);
//       }
//     } catch (e) {
//       // Handle any unexpected errors
//       return await _handleUnexpectedError(e, data);
//     }
//   }
//
//   // Fetch donors from API with local fallback
//   Future<Map<String, dynamic>> fetchDonors() async {
//     try {
//       if (await isConnected) {
//         final response = await http.get(
//           Uri.parse("$_baseUrl/donors"),
//           headers: _headers,
//         );
//
//         if (response.statusCode == 200) {
//           return {
//             'success': true,
//             'data': json.decode(response.body),
//             'source': 'api',
//           };
//         } else {
//           return await _getLocalDonorsWithError(response);
//         }
//       } else {
//         return await _getLocalDonors();
//       }
//     } catch (e) {
//       return await _getLocalDonorsWithException(e);
//     }
//   }
//
//   // Synchronize local unsynced donors with API
//   Future<void> syncLocalDonors() async {
//     try {
//       if (!await isConnected) return;
//
//       final unsyncedDonors = await _dbHelper.getUnsyncedDonors();
//       if (unsyncedDonors.isEmpty) return;
//
//       for (final donor in unsyncedDonors) {
//         try {
//           final payload = {
//             "name": donor['name'],
//             "email": donor['email'],
//             "phone_number": donor['phone'],
//             "password": "defaultPassword123",
//             "cnic": "1234567890123",
//             "blood_group": donor['blood_group'],
//             "city": donor['city'] ?? "Unknown",
//             "gender": donor['gender'] ?? "Other",
//             "age": donor['age'] ?? 0,
//           };
//
//           final response = await http.post(
//             Uri.parse("$_baseUrl/donors"),
//             headers: _headers,
//             body: json.encode(payload),
//           );
//
//           if (response.statusCode == 200 || response.statusCode == 201) {
//             await _dbHelper.updateDonorSyncStatus(donor['id'] as int);
//           } else {
//             await _dbHelper.recordSyncAttempt(donor['id'] as int);
//           }
//         } catch (e) {
//           await _dbHelper.recordSyncAttempt(donor['id'] as int);
//         }
//       }
//     } catch (e) {
//       print("Sync error: ${e.toString()}");
//     }
//   }
//
//   // --- Helper Methods --- //
//
//   Map<String, dynamic> _handleSuccess(http.Response response) {
//     return {
//       'success': true,
//       'message': 'Donor submitted successfully!',
//       'data': json.decode(response.body),
//     };
//   }
//
//   Future<Map<String, dynamic>> _handleValidationError(
//       http.Response response,
//       Map<String, dynamic> data,
//       ) async {
//     final errors = json.decode(response.body)['errors'] ?? {};
//     await _dbHelper.insertDonor(data);
//
//     return {
//       'success': false,
//       'message': 'Validation failed. Data saved locally.',
//       'errors': errors,
//       'saved_locally': true,
//     };
//   }
//
//   Future<Map<String, dynamic>> _handleApiError(
//       http.Response response,
//       Map<String, dynamic> data,
//       ) async {
//     await _dbHelper.insertDonor(data);
//
//     return {
//       'success': false,
//       'message': 'API Error. Data saved locally.',
//       'error': 'API Error ${response.statusCode}',
//       'saved_locally': true,
//     };
//   }
//
//   Future<Map<String, dynamic>> _saveToLocalStorage(
//       Map<String, dynamic> data,
//       ) async {
//     await _dbHelper.insertDonor(data);
//
//     return {
//       'success': false,
//       'message': 'No internet connection. Data saved locally.',
//       'saved_locally': true,
//     };
//   }
//
//   Future<Map<String, dynamic>> _handleUnexpectedError(
//       dynamic error,
//       Map<String, dynamic> data,
//       ) async {
//     await _dbHelper.insertDonor(data);
//
//     return {
//       'success': false,
//       'message': 'Error occurred. Data saved locally.',
//       'error': error.toString(),
//       'saved_locally': true,
//     };
//   }
//
//   Future<Map<String, dynamic>> _getLocalDonors() async {
//     final localData = await _dbHelper.getAllDonors();
//     return {
//       'success': localData.isNotEmpty,
//       'data': localData,
//       'source': 'local',
//       'message': localData.isEmpty
//           ? 'No local data available'
//           : 'Showing local data (offline)',
//     };
//   }
//
//   Future<Map<String, dynamic>> _getLocalDonorsWithError(
//       http.Response response,
//       ) async {
//     final localData = await _dbHelper.getAllDonors();
//     return {
//       'success': localData.isNotEmpty,
//       'data': localData,
//       'source': 'local',
//       'error': 'API Error ${response.statusCode}',
//       'message': 'Showing local data (API failed)',
//     };
//   }
//
//   Future<Map<String, dynamic>> _getLocalDonorsWithException(
//       dynamic error,
//       ) async {
//     final localData = await _dbHelper.getAllDonors();
//     return {
//       'success': localData.isNotEmpty,
//       'data': localData,
//       'source': 'local',
//       'error': error.toString(),
//       'message': 'Showing local data (network error)',
//     };
//   }
// }

// lib/api_data_screen.dart
import 'package:flutter/material.dart';
import 'api_service.dart';

class ApiDataScreen extends StatefulWidget {
  final ApiService apiService;

  const ApiDataScreen({super.key, required this.apiService});

  @override
  State<ApiDataScreen> createState() => _ApiDataScreenState();
}

class _ApiDataScreenState extends State<ApiDataScreen> {
  List<dynamic> _donors = [];
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

    final result = await widget.apiService.fetchDonors();

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _donors = result['data'] ?? [];
      } else {
        _error = result['error'] ?? 'Failed to load data';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Donors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : _donors.isEmpty
          ? const Center(child: Text('No donors found'))
          : ListView.builder(
        itemCount: _donors.length,
        itemBuilder: (context, index) {
          final donor = _donors[index];
          return ListTile(
            title: Text(donor['name'] ?? 'Unknown'),
            subtitle: Text(donor['blood_group'] ?? ''),
          );
        },
      ),
    );
  }
}