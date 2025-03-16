import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class RegistrationController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String status = 'Active';

  Future<void> saveData() async {
    if (formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String key = DateTime.now().toString();

      // Store user data as a JSON string
      Map<String, dynamic> userData = {
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'status': status,
      };
      await prefs.setString(key, jsonEncode(userData));

      Fluttertoast.showToast(
        msg: "Data Saved Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      nameController.clear();
      emailController.clear();
      passwordController.clear();
    }
  }
}
