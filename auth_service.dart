import 'package:flutter/material.dart';
import 'database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<bool> login(String email, String password) async {
    try {
      final user = await _dbHelper.getUserByEmail(email);
      if (user != null && user['password'] == password) {
        await _dbHelper.setLoggedInUser(email);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> signup(
      String name, String email, String phone, String password) async {
    try {
      await _dbHelper.insertUser({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });
      await _dbHelper.setLoggedInUser(email);
      return true;
    } catch (e) {
      debugPrint('Signup error: $e');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final user = await _dbHelper.getLoggedInUser();
      return user != null;
    } catch (e) {
      debugPrint('Session check error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      return await _dbHelper.getLoggedInUser();
    } catch (e) {
      debugPrint('Get user error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _dbHelper.logoutUser();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
