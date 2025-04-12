import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// Future<bool> checkInternet() async {
//   try {
//     final response = await http.get(Uri.parse('https://www.google.com'));
//     return response.statusCode == 200;
//   } catch (e) {
//     return false;
//   }
// }

// void showToast(String message) {
//   Fluttertoast.showToast(
//     msg: message,
//     toastLength: Toast.LENGTH_SHORT,
//     gravity: ToastGravity.BOTTOM,
//     backgroundColor: Colors.black54,
//     textColor: Colors.white,
//   );
// }

// Future<void> saveToLocal(Map<String, dynamic> data) async {
//   final prefs = await SharedPreferences.getInstance();
//   final localData = prefs.getStringList('localGrades') ?? [];
//   localData.add(jsonEncode(data));
//   await prefs.setStringList('localGrades', localData);
// }

// Future<List<Map<String, dynamic>>> getLocalData() async {
//   final prefs = await SharedPreferences.getInstance();
//   final localData = prefs.getStringList('localGrades') ?? [];
//   return localData
//       .map((item) => jsonDecode(item) as Map<String, dynamic>)
//       .toList();
// }

// Future<void> clearLocalData() async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.remove('localGrades');
// }

// Map<String, String> convertToStringMap(Map<String, dynamic> data) {
//   return data.map((key, value) => MapEntry(key, value.toString()));
// }

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<bool> checkInternet() async {
  try {
    final response = await http
        .get(Uri.parse('https://www.google.com'))
        .timeout(const Duration(seconds: 5));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black54,
    textColor: Colors.white,
  );
}

Future<void> saveToLocal(Map<String, dynamic> data) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final localData = prefs.getStringList('localGrades') ?? [];
    localData.add(jsonEncode(data));
    await prefs.setStringList('localGrades', localData);
  } catch (e) {
    debugPrint('Error saving to local: $e');
    throw Exception('Failed to save data locally');
  }
}

Future<List<Map<String, dynamic>>> getLocalData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final localData = prefs.getStringList('localGrades') ?? [];
    return localData
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  } catch (e) {
    debugPrint('Error getting local data: $e');
    throw Exception('Failed to load local data');
  }
}

Future<void> clearLocalData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('localGrades');
  } catch (e) {
    debugPrint('Error clearing local data: $e');
    throw Exception('Failed to clear local data');
  }
}

Map<String, String> convertToStringMap(Map<String, dynamic> data) {
  return data.map((key, value) => MapEntry(key, value.toString()));
}

Future<http.Response> postGradeData(Map<String, dynamic> data) async {
  return await http.post(
    Uri.parse('https://devtechtop.com/management/public/api/grades'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode(data),
  );
}

Future<http.Response> getGradeData({String? userId}) async {
  final uri = userId != null && userId.isNotEmpty
      ? Uri.parse(
          'https://devtechtop.com/management/public/api/select_data?user_id=$userId')
      : Uri.parse('https://devtechtop.com/management/public/api/select_data');

  return await http.get(
    uri,
    headers: {'Accept': 'application/json'},
  );
}
