// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'database_helper.dart';
//
// class ApiService {
//   final String _baseUrl = "https://goodvibe.cybercoreuk.com/api";
//   final Map<String, String> _headers = {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//   };
//
//   Future<Map<String, dynamic>> submitDonor(Map<String, dynamic> data) async {
//     try {
//       // Prepare the payload according to API requirements
//       final payload = {
//         'name': data['name'],
//         'email': data['email'],
//         'phone_number': data['phone'],
//         'password': 'defaultPassword', // Required by API
//         'cnic': '0000000000000', // Default CNIC if not provided
//         'blood_group': data['blood_group'],
//         'city': data['city'] ?? 'Unknown',
//         'gender': data['gender'] ?? 'Other',
//         'age': int.tryParse(data['age'] ?? '0') ?? 0,
//       };
//
//       print('Submitting donor data: ${json.encode(payload)}');
//
//       final response = await http.post(
//         Uri.parse("$_baseUrl/donors"),
//         headers: _headers,
//         body: json.encode(payload),
//       );
//
//       print('API Response Status: ${response.statusCode}');
//       print('API Response Body: ${response.body}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = json.decode(response.body);
//         return {
//           'success': true,
//           'data': responseData,
//           'message': 'Donor submitted successfully!'
//         };
//       } else if (response.statusCode == 422) {
//         final errors = json.decode(response.body)['errors'];
//         return {
//           'success': false,
//           'error': 'Validation failed',
//           'details': errors,
//           'message': 'Please check your input fields'
//         };
//       } else {
//         // Save to SQLite when API fails
//         await DatabaseHelper.instance.insertDonor(data);
//         return {
//           'success': false,
//           'error': 'API Error ${response.statusCode}: ${response.body}',
//           'message': 'Data saved locally due to API error'
//         };
//       }
//     } catch (e) {
//       // Save to SQLite when offline
//       await DatabaseHelper.instance.insertDonor(data);
//       return {
//         'success': false,
//         'error': 'Network error: ${e.toString()}',
//         'message': 'Data saved locally due to network error'
//       };
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchDonors() async {
//     try {
//       final response = await http.get(
//         Uri.parse("$_baseUrl/donors"),
//         headers: _headers,
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return {
//           'success': true,
//           'data': data is List ? data : [data],
//         };
//       } else {
//         final localData = await DatabaseHelper.instance.getAllDonors();
//         return {
//           'success': localData.isNotEmpty,
//           'data': localData,
//           'error': 'API Error ${response.statusCode}',
//           'message': localData.isEmpty
//               ? 'No data available'
//               : 'Showing local data as fallback'
//         };
//       }
//     } catch (e) {
//       final localData = await DatabaseHelper.instance.getAllDonors();
//       return {
//         'success': localData.isNotEmpty,
//         'data': localData,
//         'error': 'Network error: ${e.toString()}',
//         'message': localData.isEmpty
//             ? 'No data available'
//             : 'Showing local data as fallback'
//       };
//     }
//   }
//
//   Future<void> syncLocalDonors() async {
//     final unsyncedDonors = await DatabaseHelper.instance.getUnsyncedDonors();
//     for (var donor in unsyncedDonors) {
//       try {
//         final payload = {
//           'name': donor['name'],
//           'email': donor['email'],
//           'phone_number': donor['phone'],
//           'password': 'defaultPassword',
//           'cnic': '0000000000000',
//           'blood_group': donor['blood_group'],
//           'city': donor['city'] ?? 'Unknown',
//           'gender': donor['gender'] ?? 'Other',
//           'age': donor['age'] ?? 0,
//         };
//
//         final response = await http.post(
//           Uri.parse("$_baseUrl/donors"),
//           headers: _headers,
//           body: json.encode(payload),
//         );
//
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           await DatabaseHelper.instance.updateDonorSyncStatus(donor['id'] as int);
//         }
//       } catch (e) {
//         print('Error syncing donor: ${e.toString()}');
//       }
//     }
//   }
// }



// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'database_helper.dart';
//
// class ApiService {
//   final String _baseUrl = "https://goodvibe.cybercoreuk.com/api";
//   final Map<String, String> _headers = {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//   };
//
//   Future<Map<String, dynamic>> submitDonor(Map<String, dynamic> data) async {
//     try {
//       final payload = {
//         'name': data['name'],
//         'email': data['email'],
//         'phone_number': data['phone'],
//         'password': 'defaultPassword',
//         'cnic': '0000000000000',
//         'blood_group': data['blood_group'],
//         'city': data['city'] ?? 'Unknown',
//         'gender': data['gender'] ?? 'Other',
//         'age': data['age'] != null ? int.tryParse(data['age'].toString()) ?? 0 : 0,
//       };
//
//       print('Submitting to API: ${json.encode(payload)}');
//
//       final response = await http.post(
//         Uri.parse("$_baseUrl/donors"),
//         headers: _headers,
//         body: json.encode(payload),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = json.decode(response.body);
//         return {
//           'success': true,
//           'data': responseData,
//           'message': 'Donor submitted successfully!'
//         };
//       } else if (response.statusCode == 422) {
//         final errors = json.decode(response.body)['errors'];
//         return {
//           'success': false,
//           'error': 'Validation failed',
//           'details': errors,
//           'message': 'Please check your input fields'
//         };
//       } else {
//         await DatabaseHelper.instance.insertDonor(data);
//         return {
//           'success': false,
//           'error': 'API Error ${response.statusCode}',
//           'message': 'Data saved locally'
//         };
//       }
//     } catch (e) {
//       await DatabaseHelper.instance.insertDonor(data);
//       return {
//         'success': false,
//         'error': 'Network error: ${e.toString()}',
//         'message': 'Data saved locally'
//       };
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchDonors() async {
//     try {
//       final response = await http.get(
//         Uri.parse("$_baseUrl/donors"),
//         headers: _headers,
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return {
//           'success': true,
//           'data': data is List ? data : [data],
//         };
//       } else {
//         final localData = await DatabaseHelper.instance.getAllDonors();
//         return {
//           'success': localData.isNotEmpty,
//           'data': localData,
//           'error': 'API Error ${response.statusCode}',
//           'message': 'Showing local data'
//         };
//       }
//     } catch (e) {
//       final localData = await DatabaseHelper.instance.getAllDonors();
//       return {
//         'success': localData.isNotEmpty,
//         'data': localData,
//         'error': 'Network error: ${e.toString()}',
//         'message': 'Showing local data'
//       };
//     }
//   }
//
//   Future<void> syncLocalDonors() async {
//     final unsyncedDonors = await DatabaseHelper.instance.getUnsyncedDonors();
//     for (var donor in unsyncedDonors) {
//       try {
//         final payload = {
//           'name': donor['name'],
//           'email': donor['email'],
//           'phone_number': donor['phone'],
//           'password': 'defaultPassword',
//           'cnic': '0000000000000',
//           'blood_group': donor['blood_group'],
//           'city': donor['city'] ?? 'Unknown',
//           'gender': donor['gender'] ?? 'Other',
//           'age': donor['age'] ?? 0,
//         };
//
//         final response = await http.post(
//           Uri.parse("$_baseUrl/donors"),
//           headers: _headers,
//           body: json.encode(payload),
//         );
//
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           await DatabaseHelper.instance.updateDonorSyncStatus(donor['id'] as int);
//         }
//       } catch (e) {
//         print('Sync error for donor ${donor['id']}: ${e.toString()}');
//       }
//     }
//   }
// }




// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'database_helper.dart';
//
// class ApiService {
//   final String _baseUrl = "https://goodvibe.cybercoreuk.com/api";
//   final Map<String, String> _headers = {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//   };
//
//   Future<Map<String, dynamic>> submitDonor(Map<String, dynamic> data) async {
//     try {
//       // Prepare the payload with all required fields
//       final payload = {
//         "name": data['name'],
//         "email": data['email'],
//         "phone_number": data['phone'],
//         "password": "defaultPassword123", // Default password
//         "cnic": "1234567890123", // Default CNIC
//         "blood_group": data['blood_group'],
//         "city": data['city'] ?? "Unknown",
//         "gender": data['gender'] ?? "Other",
//         "age": data['age'] != null ? int.tryParse(data['age'].toString()) ?? 0 : 0,
//       };
//
//       print("Submitting to API: ${json.encode(payload)}");
//
//       final response = await http.post(
//         Uri.parse("$_baseUrl/donors"),
//         headers: _headers,
//         body: json.encode(payload),
//       );
//
//       print("API Response: ${response.statusCode} - ${response.body}");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = json.decode(response.body);
//         return {
//           'success': true,
//           'data': responseData,
//           'message': 'Donor registered successfully!'
//         };
//       } else if (response.statusCode == 422) {
//         // Handle validation errors
//         final errorResponse = json.decode(response.body);
//         final errors = errorResponse['errors'] ?? {};
//         String errorMessage = 'Validation failed:';
//
//         errors.forEach((key, value) {
//           errorMessage += '\n$key: ${value.join(', ')}';
//         });
//
//         return {
//           'success': false,
//           'error': 'Validation failed',
//           'details': errors,
//           'message': errorMessage
//         };
//       } else {
//         // Save to local database if API fails
//         await DatabaseHelper.instance.insertDonor(data);
//         return {
//           'success': false,
//           'error': 'API Error ${response.statusCode}',
//           'message': 'Data saved locally. Will sync when online.'
//         };
//       }
//     } catch (e) {
//       // Save to local database if network fails
//       await DatabaseHelper.instance.insertDonor(data);
//       return {
//         'success': false,
//         'error': 'Network error',
//         'message': 'Data saved locally. Will sync when online.'
//       };
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchDonors() async {
//     try {
//       final response = await http.get(
//         Uri.parse("$_baseUrl/donors"),
//         headers: _headers,
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return {
//           'success': true,
//           'data': data is List ? data : [data],
//         };
//       } else {
//         final localData = await DatabaseHelper.instance.getAllDonors();
//         return {
//           'success': localData.isNotEmpty,
//           'data': localData,
//           'error': 'API Error ${response.statusCode}',
//           'message': 'Showing local data'
//         };
//       }
//     } catch (e) {
//       final localData = await DatabaseHelper.instance.getAllDonors();
//       return {
//         'success': localData.isNotEmpty,
//         'data': localData,
//         'error': 'Network error',
//         'message': 'Showing local data'
//       };
//     }
//   }
//
//   Future<void> syncLocalDonors() async {
//     final unsyncedDonors = await DatabaseHelper.instance.getUnsyncedDonors();
//
//     for (var donor in unsyncedDonors) {
//       try {
//         final payload = {
//           "name": donor['name'],
//           "email": donor['email'],
//           "phone_number": donor['phone'],
//           "password": "defaultPassword123",
//           "cnic": "1234567890123",
//           "blood_group": donor['blood_group'],
//           "city": donor['city'] ?? "Unknown",
//           "gender": donor['gender'] ?? "Other",
//           "age": donor['age'] ?? 0,
//         };
//
//         final response = await http.post(
//           Uri.parse("$_baseUrl/donors"),
//           headers: _headers,
//           body: json.encode(payload),
//         );
//
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           await DatabaseHelper.instance.updateDonorSyncStatus(donor['id'] as int);
//           print("Successfully synced donor: ${donor['id']}");
//         } else {
//           print("Failed to sync donor ${donor['id']}: ${response.body}");
//         }
//       } catch (e) {
//         print("Error syncing donor ${donor['id']}: ${e.toString()}");
//       }
//     }
//   }
// }



// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'database_helper.dart';
//
// class ApiService {
//   final String _baseUrl = "https://goodvibe.cybercoreuk.com/api";
//   final Map<String, String> _headers = {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//   };
//
//   Future<bool> _checkInternetConnection() async {
//     final connectivityResult = await Connectivity().checkConnectivity();
//     return connectivityResult != ConnectivityResult.none;
//   }
//
//   Future<Map<String, dynamic>> submitDonor(Map<String, dynamic> data) async {
//     try {
//       final hasConnection = await _checkInternetConnection();
//       final payload = _preparePayload(data);
//
//       if (hasConnection) {
//         final response = await _sendToApi(payload);
//
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           return _handleSuccessResponse(response);
//         } else {
//           return await _handleApiError(response, data);
//         }
//       } else {
//         return await _saveToLocalAndQueue(data);
//       }
//     } catch (e) {
//       return await _handleNetworkError(e, data);
//     }
//   }
//
//   Map<String, dynamic> _preparePayload(Map<String, dynamic> data) {
//     return {
//       "name": data['name'],
//       "email": data['email'],
//       "phone_number": data['phone'],
//       "password": "defaultPassword123",
//       "cnic": "1234567890123",
//       "blood_group": data['blood_group'],
//       "city": data['city'] ?? "Unknown",
//       "gender": data['gender'] ?? "Other",
//       "age": data['age'] != null ? int.tryParse(data['age'].toString()) ?? 0 : 0,
//     };
//   }
//
//   Future<http.Response> _sendToApi(Map<String, dynamic> payload) async {
//     print("Submitting to API: ${json.encode(payload)}");
//     return await http.post(
//       Uri.parse("$_baseUrl/donors"),
//       headers: _headers,
//       body: json.encode(payload),
//     );
//   }
//
//   Map<String, dynamic> _handleSuccessResponse(http.Response response) {
//     final responseData = json.decode(response.body);
//     return {
//       'success': true,
//       'data': responseData,
//       'message': 'Donor registered successfully!'
//     };
//   }
//
//   Future<Map<String, dynamic>> _handleApiError(
//       http.Response response,
//       Map<String, dynamic> data
//       ) async {
//     await DatabaseHelper.instance.insertDonor(data);
//
//     if (response.statusCode == 422) {
//       final errorResponse = json.decode(response.body);
//       return {
//         'success': false,
//         'error': 'Validation failed',
//         'details': errorResponse['errors'] ?? {},
//         'message': 'Validation failed. Data saved locally.'
//       };
//     } else {
//       return {
//         'success': false,
//         'error': 'API Error ${response.statusCode}',
//         'message': 'Data saved locally. Will retry later.'
//       };
//     }
//   }
//
//   Future<Map<String, dynamic>> _saveToLocalAndQueue(Map<String, dynamic> data) async {
//     await DatabaseHelper.instance.insertDonor(data);
//     return {
//       'success': false,
//       'error': 'No internet connection',
//       'message': 'Data saved locally. Will sync when online.'
//     };
//   }
//
//   Future<Map<String, dynamic>> _handleNetworkError(
//       dynamic e,
//       Map<String, dynamic> data
//       ) async {
//     await DatabaseHelper.instance.insertDonor(data);
//     return {
//       'success': false,
//       'error': 'Network error',
//       'message': 'Data saved locally. Will sync when online.'
//     };
//   }
//
//   Future<void> syncLocalDonors() async {
//     try {
//       final hasConnection = await _checkInternetConnection();
//       if (!hasConnection) return;
//
//       final unsyncedDonors = await DatabaseHelper.instance.getUnsyncedDonors();
//
//       for (var donor in unsyncedDonors) {
//         try {
//           final payload = _preparePayload(donor);
//           final response = await _sendToApi(payload);
//
//           if (response.statusCode == 200 || response.statusCode == 201) {
//             await DatabaseHelper.instance.updateDonorSyncStatus(donor['id'] as int);
//             print("Successfully synced donor: ${donor['id']}");
//           } else {
//             await DatabaseHelper.instance.recordSyncAttempt(donor['id'] as int);
//             print("Failed to sync donor ${donor['id']}: ${response.body}");
//           }
//         } catch (e) {
//           await DatabaseHelper.instance.recordSyncAttempt(donor['id'] as int);
//           print("Error syncing donor ${donor['id']}: ${e.toString()}");
//         }
//       }
//     } catch (e) {
//       print("Error in sync process: ${e.toString()}");
//     }
//   }
//
// // ... rest of the ApiService class remains the same ...
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class ApiService {
  final String _baseUrl = "https://goodvibe.cybercoreuk.com/api";
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Check internet connection status
  Future<bool> get isConnected async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Submit donor data with automatic offline handling
  Future<Map<String, dynamic>> submitDonor(Map<String, dynamic> data) async {
    try {
      // Prepare the API payload
      final payload = {
        "name": data['name'],
        "email": data['email'],
        "phone_number": data['phone'],
        "password": "defaultPassword123", // Required by API
        "cnic": "1234567890123", // Required by API
        "blood_group": data['blood_group'],
        "city": data['city'] ?? "Unknown",
        "gender": data['gender'] ?? "Other",
        "age": data['age'] != null ? int.tryParse(data['age'].toString()) ?? 0 : 0,
      };

      // Try to send to API if connected
      if (await isConnected) {
        final response = await http.post(
          Uri.parse("$_baseUrl/donors"),
          headers: _headers,
          body: json.encode(payload),
        );

        // Handle API response
        if (response.statusCode == 200 || response.statusCode == 201) {
          return _handleSuccess(response);
        } else if (response.statusCode == 422) {
          return await _handleValidationError(response, data);
        } else {
          return await _handleApiError(response, data);
        }
      } else {
        // Save to local storage if offline
        return await _saveToLocalStorage(data);
      }
    } catch (e) {
      // Handle any unexpected errors
      return await _handleUnexpectedError(e, data);
    }
  }

  // Fetch donors from API with local fallback
  Future<Map<String, dynamic>> fetchDonors() async {
    try {
      if (await isConnected) {
        final response = await http.get(
          Uri.parse("$_baseUrl/donors"),
          headers: _headers,
        );

        if (response.statusCode == 200) {
          return {
            'success': true,
            'data': json.decode(response.body),
            'source': 'api',
          };
        } else {
          return await _getLocalDonorsWithError(response);
        }
      } else {
        return await _getLocalDonors();
      }
    } catch (e) {
      return await _getLocalDonorsWithException(e);
    }
  }

  // Synchronize local unsynced donors with API
  Future<void> syncLocalDonors() async {
    try {
      if (!await isConnected) return;

      final unsyncedDonors = await _dbHelper.getUnsyncedDonors();
      if (unsyncedDonors.isEmpty) return;

      for (final donor in unsyncedDonors) {
        try {
          final payload = {
            "name": donor['name'],
            "email": donor['email'],
            "phone_number": donor['phone'],
            "password": "defaultPassword123",
            "cnic": "1234567890123",
            "blood_group": donor['blood_group'],
            "city": donor['city'] ?? "Unknown",
            "gender": donor['gender'] ?? "Other",
            "age": donor['age'] ?? 0,
          };

          final response = await http.post(
            Uri.parse("$_baseUrl/donors"),
            headers: _headers,
            body: json.encode(payload),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            await _dbHelper.updateDonorSyncStatus(donor['id'] as int);
          } else {
            await _dbHelper.recordSyncAttempt(donor['id'] as int);
          }
        } catch (e) {
          await _dbHelper.recordSyncAttempt(donor['id'] as int);
        }
      }
    } catch (e) {
      print("Sync error: ${e.toString()}");
    }
  }

  // --- Helper Methods --- //

  Map<String, dynamic> _handleSuccess(http.Response response) {
    return {
      'success': true,
      'message': 'Donor submitted successfully!',
      'data': json.decode(response.body),
    };
  }

  Future<Map<String, dynamic>> _handleValidationError(
      http.Response response,
      Map<String, dynamic> data,
      ) async {
    final errors = json.decode(response.body)['errors'] ?? {};
    await _dbHelper.insertDonor(data);

    return {
      'success': false,
      'message': 'Validation failed. Data saved locally.',
      'errors': errors,
      'saved_locally': true,
    };
  }

  Future<Map<String, dynamic>> _handleApiError(
      http.Response response,
      Map<String, dynamic> data,
      ) async {
    await _dbHelper.insertDonor(data);

    return {
      'success': false,
      'message': 'API Error. Data saved locally.',
      'error': 'API Error ${response.statusCode}',
      'saved_locally': true,
    };
  }

  Future<Map<String, dynamic>> _saveToLocalStorage(
      Map<String, dynamic> data,
      ) async {
    await _dbHelper.insertDonor(data);

    return {
      'success': false,
      'message': 'No internet connection. Data saved locally.',
      'saved_locally': true,
    };
  }

  Future<Map<String, dynamic>> _handleUnexpectedError(
      dynamic error,
      Map<String, dynamic> data,
      ) async {
    await _dbHelper.insertDonor(data);

    return {
      'success': false,
      'message': 'Error occurred. Data saved locally.',
      'error': error.toString(),
      'saved_locally': true,
    };
  }

  Future<Map<String, dynamic>> _getLocalDonors() async {
    final localData = await _dbHelper.getAllDonors();
    return {
      'success': localData.isNotEmpty,
      'data': localData,
      'source': 'local',
      'message': localData.isEmpty
          ? 'No local data available'
          : 'Showing local data (offline)',
    };
  }

  Future<Map<String, dynamic>> _getLocalDonorsWithError(
      http.Response response,
      ) async {
    final localData = await _dbHelper.getAllDonors();
    return {
      'success': localData.isNotEmpty,
      'data': localData,
      'source': 'local',
      'error': 'API Error ${response.statusCode}',
      'message': 'Showing local data (API failed)',
    };
  }

  Future<Map<String, dynamic>> _getLocalDonorsWithException(
      dynamic error,
      ) async {
    final localData = await _dbHelper.getAllDonors();
    return {
      'success': localData.isNotEmpty,
      'data': localData,
      'source': 'local',
      'error': error.toString(),
      'message': 'Showing local data (network error)',
    };
  }
}