import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DataListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          SharedPreferences prefs = snapshot.data!;
          List<String> keys = prefs.getKeys().toList();
          keys.sort((a, b) => b.compareTo(a)); // Sort keys in descending order

          return ListView.builder(
            itemCount: keys.length,
            itemBuilder: (context, index) {
              String key = keys[index];
              String? userData = prefs.getString(key);

              if (userData == null) {
                return SizedBox.shrink(); // Skip invalid entries
              }

              // Parse the user data
              Map<String, dynamic> user =
                  Map<String, dynamic>.from(jsonDecode(userData));
              String name = user['name'] ?? '';
              String email = user['email'] ?? '';
              String password = user['password'] ?? '';
              String status = user['status'] ?? 'Inactive';

              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(vertical: 4),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      status == 'Active' ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      status == 'Active' ? Icons.check : Icons.close,
                      color: status == 'Active' ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: $name'),
                        Text('Email: $email'),
                        Text('Password: $password'),
                        Text('Status: $status'),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
