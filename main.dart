import 'package:flutter/material.dart';
import 'data_entry_screen.dart';
import 'api_data_screen.dart';
import 'offline_data_screen.dart';

void main() {
  runApp(const BloodDonorApp());
}

class BloodDonorApp extends StatelessWidget {
  const BloodDonorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Donor App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DataEntryScreen(),
        '/donors': (context) => const ApiDataScreen(),
        '/offline': (context) => const OfflineDataScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}


