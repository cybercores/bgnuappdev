// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// // Logger setup
// void logDebug(String message) {
//   debugPrint(message);
// }

// // Check internet connection
// Future<bool> checkInternet() async {
//   final connectivityResult = await Connectivity().checkConnectivity();
//   return connectivityResult != ConnectivityResult.none;
// }

// // Post data to API using GET method
// Future<http.Response> postGradeData(Map<String, dynamic> data) async {
//   final uri = Uri.parse('https://devtechtop.com/management/public/api/grades')
//       .replace(queryParameters: data);

//   logDebug('Sending GET request to: ${uri.toString()}');
//   return await http.get(uri);
// }

// // Save data locally
// Future<void> saveToLocal(Map<String, dynamic> data) async {
//   final prefs = await SharedPreferences.getInstance();
//   final pendingData = prefs.getStringList('pendingGrades') ?? [];
//   pendingData.add(json.encode(data));
//   await prefs.setStringList('pendingGrades', pendingData);
//   logDebug('Saved locally: ${pendingData.length} items');
// }

// // Show toast message
// void showToast(String message, {required BuildContext context}) {
//   if (ScaffoldMessenger.of(context).mounted) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }

// // Process pending submissions
// Future<void> processPendingSubmissions(BuildContext context) async {
//   final prefs = await SharedPreferences.getInstance();
//   final pendingData = prefs.getStringList('pendingGrades') ?? [];

//   if (pendingData.isEmpty) return;

//   final hasInternet = await checkInternet();
//   if (!hasInternet) {
//     if (context.mounted) {
//       showToast('No internet to sync pending data', context: context);
//     }
//     return;
//   }

//   for (var dataString in pendingData) {
//     try {
//       final data = json.decode(dataString) as Map<String, dynamic>;
//       final response = await postGradeData(data);

//       if (response.statusCode == 200) {
//         pendingData.remove(dataString);
//         logDebug('Synced pending data successfully');
//       }
//     } catch (e) {
//       logDebug('Error syncing pending data: $e');
//       break;
//     }
//   }

//   await prefs.setStringList('pendingGrades', pendingData);
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Logger setup
void logDebug(String message) {
  debugPrint(message);
}

// Check internet connection
Future<bool> checkInternet() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

// Post data to API using POST method
Future<http.Response> postGradeData(Map<String, dynamic> data) async {
  final uri = Uri.parse('https://devtechtop.com/management/public/api/grades');

  logDebug('Sending POST request to: ${uri.toString()}');
  logDebug('Request data: $data');

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return response;
  } catch (e) {
    logDebug('Request error: $e');
    rethrow;
  }
}

// Save data locally
Future<void> saveToLocal(Map<String, dynamic> data) async {
  final prefs = await SharedPreferences.getInstance();
  final pendingData = prefs.getStringList('pendingGrades') ?? [];
  pendingData.add(json.encode(data));
  await prefs.setStringList('pendingGrades', pendingData);
  logDebug('Saved locally: ${pendingData.length} items');
}

// Show toast message
void showToast(String message, {required BuildContext context}) {
  if (ScaffoldMessenger.of(context).mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Process pending submissions
Future<void> processPendingSubmissions(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final pendingData = prefs.getStringList('pendingGrades') ?? [];

  if (pendingData.isEmpty) return;

  final hasInternet = await checkInternet();
  if (!hasInternet) {
    if (context.mounted) {
      showToast('No internet to sync pending data', context: context);
    }
    return;
  }

  final failedSubmissions = <String>[];

  for (var dataString in pendingData) {
    try {
      final data = json.decode(dataString) as Map<String, dynamic>;
      final response = await postGradeData(data);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        logDebug('Synced pending data successfully');
      } else {
        failedSubmissions.add(dataString);
        logDebug('Failed to sync pending data: ${response.statusCode}');
      }
    } catch (e) {
      failedSubmissions.add(dataString);
      logDebug('Error syncing pending data: $e');
    }
  }

  await prefs.setStringList('pendingGrades', failedSubmissions);
  if (context.mounted && failedSubmissions.isEmpty) {
    showToast('All pending data synced successfully', context: context);
  }
}
