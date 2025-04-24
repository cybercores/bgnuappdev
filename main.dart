import 'package:flutter/material.dart';
import 'data_entry_page.dart';
import 'local_data_page.dart';
import 'api_data_page.dart';

void main() {
  runApp(const GradeManagementApp());
}

class GradeManagementApp extends StatelessWidget {
  const GradeManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      home: const MainNavigationPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const DataEntryPage(),
    const LocalDataPage(),
    const ApiDataPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Management'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_document),
            label: 'Data Entry',
          ),
          NavigationDestination(
            icon: Icon(Icons.storage_rounded),
            label: 'Local Data',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_upload),
            label: 'API Data',
          ),
        ],
      ),
    );
  }
}
