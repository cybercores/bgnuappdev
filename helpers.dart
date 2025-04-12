import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<bool> checkInternet() async {
  try {
    final response = await http.get(Uri.parse('https://www.google.com'));
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
  final prefs = await SharedPreferences.getInstance();
  final localData = prefs.getStringList('localGrades') ?? [];
  localData.add(jsonEncode(data));
  await prefs.setStringList('localGrades', localData);
}

Future<List<Map<String, dynamic>>> getLocalData() async {
  final prefs = await SharedPreferences.getInstance();
  final localData = prefs.getStringList('localGrades') ?? [];
  return localData
      .map((item) => jsonDecode(item) as Map<String, dynamic>)
      .toList();
}

Future<void> clearLocalData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('localGrades');
}

Map<String, String> convertToStringMap(Map<String, dynamic> data) {
  return data.map((key, value) => MapEntry(key, value.toString()));
}
