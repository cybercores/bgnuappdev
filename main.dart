// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'api_service.dart';
// import 'data_entry_screen.dart';
// import 'local_data_screen.dart';
// import 'api_data_screen.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Hive.initFlutter();
//   await Hive.openBox('donors');
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Blood Donor Manager',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.redAccent,
//           brightness: Brightness.light,
//         ),
//         useMaterial3: true,
//         inputDecorationTheme: InputDecorationTheme(
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.redAccent, width: 2),
//           ),
//         ),
//         cardTheme: CardTheme(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           margin: const EdgeInsets.all(8),
//         ),
//         appBarTheme: AppBarTheme(
//           centerTitle: true,
//           elevation: 0,
//           titleTextStyle: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       home: const MainNavigationScreen(),
//     );
//   }
// }
//
// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({super.key});
//
//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }
//
// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int _currentIndex = 0;
//   final ApiService apiService = ApiService();
//   late final List<Widget> _screens;
//
//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       DataEntryScreen(apiService: apiService),
//       LocalDataScreen(apiService: apiService),
//       ApiDataScreen(apiService: apiService),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _screens,
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.3),
//               spreadRadius: 2,
//               blurRadius: 10,
//               offset: const Offset(0, -3),
//             ),
//           ],
//         ),
//         child: NavigationBar(
//           selectedIndex: _currentIndex,
//           onDestinationSelected: (index) {
//             setState(() => _currentIndex = index);
//           },
//           backgroundColor: Colors.white,
//           indicatorColor: Colors.redAccent.withOpacity(0.2),
//           labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
//           destinations: const [
//             NavigationDestination(
//               icon: Icon(Icons.person_add),
//               selectedIcon: Icon(Icons.person_add, color: Colors.redAccent),
//               label: 'Add Donor',
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.storage),
//               selectedIcon: Icon(Icons.storage, color: Colors.redAccent),
//               label: 'Local Data',
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.cloud),
//               selectedIcon: Icon(Icons.cloud, color: Colors.redAccent),
//               label: 'API Data',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:workmanager/workmanager.dart';
// import 'api_service.dart';
// import 'data_entry_screen.dart';
// import 'local_data_screen.dart';
// import 'api_data_screen.dart';
//
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     final apiService = ApiService();
//     await apiService.syncLocalDonors();
//     return true;
//   });
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Hive
//   await Hive.initFlutter();
//   await Hive.openBox('donors');
//
//   // Initialize Workmanager for background sync
//   await Workmanager().initialize(
//     callbackDispatcher,
//     isInDebugMode: false,
//   );
//
//   // Register periodic sync task (every 15 minutes)
//   Workmanager().registerPeriodicTask(
//     "syncTask",
//     "syncDonors",
//     frequency: const Duration(minutes: 15),
//   );
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Blood Donor Manager',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
//         useMaterial3: true,
//       ),
//       home: const MainNavigationScreen(),
//     );
//   }
// }
//
// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({super.key});
//
//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }
//
// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int _currentIndex = 0;
//   final ApiService apiService = ApiService();
//   late final List<Widget> _screens;
//
//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       DataEntryScreen(apiService: apiService),
//       LocalDataScreen(apiService: apiService),
//       ApiDataScreen(apiService: apiService),
//     ];
//
//     // Sync immediately when app starts
//     _syncData();
//
//     // Add connectivity listener for automatic sync
//     Connectivity().onConnectivityChanged.listen((result) {
//       if (result != ConnectivityResult.none) {
//         _syncData();
//       }
//     });
//   }
//
//   Future<void> _syncData() async {
//     await apiService.syncLocalDonors();
//     if (mounted) setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _screens,
//       ),
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _currentIndex,
//         onDestinationSelected: (index) {
//           setState(() => _currentIndex = index);
//           if (index == 1) _syncData(); // Sync when viewing local data
//         },
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.person_add),
//             label: 'Add Donor',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.storage),
//             label: 'Local Data',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.cloud),
//             label: 'API Data',
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _syncData,
//         child: const Icon(Icons.sync),
//       ),
//     );
//   }
// }



//
//
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'api_service.dart';
// import 'data_entry_screen.dart';
// import 'local_data_screen.dart';
// import 'api_data_screen.dart';
//
// // Workmanager callback function
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     final apiService = ApiService();
//     await apiService.syncLocalDonors();
//     return true;
//   });
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Hive
//   await Hive.initFlutter();
//   await Hive.openBox('donors');
//
//   // Initialize Workmanager for background sync
//   await Workmanager().initialize(
//     callbackDispatcher,
//     isInDebugMode: false,
//   );
//
//   // Register periodic sync task (every 15 minutes)
//   Workmanager().registerPeriodicTask(
//     "syncTask",
//     "syncDonors",
//     frequency: const Duration(minutes: 15),
//   );
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Blood Donor Manager',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
//         useMaterial3: true,
//       ),
//       home: const MainNavigationScreen(),
//     );
//   }
// }
//
// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({super.key});
//
//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }
//
// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int _currentIndex = 0;
//   final ApiService apiService = ApiService();
//   final Connectivity connectivity = Connectivity();
//   late final List<Widget> _screens;
//
//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       DataEntryScreen(apiService: apiService),
//       LocalDataScreen(apiService: apiService),
//       ApiDataScreen(apiService: apiService),
//     ];
//
//     // Initial sync
//     _syncData();
//
//     // Listen for connectivity changes
//     connectivity.onConnectivityChanged.listen((result) {
//       if (result != ConnectivityResult.none) {
//         _syncData();
//       }
//     });
//   }
//
//   Future<void> _syncData() async {
//     await apiService.syncLocalDonors();
//     if (mounted) {
//       setState(() {});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _screens,
//       ),
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _currentIndex,
//         onDestinationSelected: (index) {
//           setState(() => _currentIndex = index);
//           if (index == 1) _syncData(); // Sync when viewing local data
//         },
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.person_add),
//             label: 'Add Donor',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.storage),
//             label: 'Local Data',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.cloud),
//             label: 'API Data',
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _syncData,
//         tooltip: 'Sync Data',
//         child: const Icon(Icons.sync),
//       ),
//     );
//   }
// }


//
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'api_service.dart';
// import 'data_entry_screen.dart';
// import 'local_data_screen.dart';
// import 'api_data_screen.dart';
//
// // Workmanager callback function
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     final apiService = ApiService();
//     await apiService.syncLocalDonors();
//     return true;
//   });
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Hive
//   await Hive.initFlutter();
//   await Hive.openBox('donors');
//
//   // Initialize Workmanager for background sync
//   await Workmanager().initialize(
//     callbackDispatcher,
//     isInDebugMode: false,
//   );
//
//   // Register periodic sync task (every 15 minutes)
//   Workmanager().registerPeriodicTask(
//     "syncTask",
//     "syncDonors",
//     frequency: const Duration(minutes: 15),
//   );
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Blood Donor Manager',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
//         useMaterial3: true,
//       ),
//       home: const MainNavigationScreen(),
//     );
//   }
// }
//
// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({super.key});
//
//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }
//
// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int _currentIndex = 0;
//   late final ApiService _apiService;
//   late final Connectivity _connectivity;
//   late final List<Widget> _screens;
//
//   @override
//   void initState() {
//     super.initState();
//     _apiService = ApiService();
//     _connectivity = Connectivity();
//
//     _screens = [
//       DataEntryScreen(apiService: _apiService),
//       LocalDataScreen(apiService: _apiService),
//       ApiDataScreen(apiService: _apiService),
//     ];
//
//     // Initial sync
//     _syncData();
//
//     // Listen for connectivity changes
//     _connectivity.onConnectivityChanged.listen((result) {
//       if (result != ConnectivityResult.none) {
//         _syncData();
//       }
//     });
//   }
//
//   Future<void> _syncData() async {
//     await _apiService.syncLocalDonors();
//     if (mounted) {
//       setState(() {});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _screens,
//       ),
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _currentIndex,
//         onDestinationSelected: (index) {
//           setState(() => _currentIndex = index);
//           if (index == 1) _syncData(); // Sync when viewing local data
//         },
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.person_add),
//             label: 'Add Donor',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.storage),
//             label: 'Local Data',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.cloud),
//             label: 'API Data',
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _syncData,
//         tooltip: 'Sync Data',
//         child: const Icon(Icons.sync),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'api_service.dart';
// import 'data_entry_screen.dart';
// import 'local_data_screen.dart';
// import 'api_data_screen.dart';
//
// // Workmanager callback function
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     final apiService = ApiService();
//     await apiService.syncLocalDonors();
//     return true;
//   });
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Hive
//   await Hive.initFlutter();
//   await Hive.openBox('donors');
//
//   // Initialize Workmanager for background sync
//   await Workmanager().initialize(
//     callbackDispatcher,
//     isInDebugMode: false,
//   );
//
//   // Register periodic sync task (every 15 minutes)
//   await Workmanager().registerPeriodicTask(
//     "syncTask",
//     "syncDonors",
//     frequency: const Duration(minutes:15),
//     constraints: Constraints(
//       networkType: NetworkType.connected,
//     ),
//   );
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Blood Donor Manager',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
//         useMaterial3: true,
//       ),
//       home: const MainNavigationScreen(),
//     );
//   }
// }
//
// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({super.key});
//
//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }
//
// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int _currentIndex = 0;
//   late final ApiService apiService;
//   late final List<Widget> screens;
//
//   @override
//   void initState() {
//     super.initState();
//     apiService = ApiService();
//     screens = [
//       DataEntryScreen(apiService: apiService),
//       LocalDataScreen(apiService: apiService),
//       ApiDataScreen(apiService: apiService),
//     ];
//
//     // Initial sync
//     _syncData();
//
//     // Listen for connectivity changes
//     Connectivity().onConnectivityChanged.listen((result) {
//       if (result != ConnectivityResult.none) {
//         _syncData();
//       }
//     });
//   }
//
//   Future<void> _syncData() async {
//     await apiService.syncLocalDonors();
//     if (mounted) setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: screens,
//       ),
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _currentIndex,
//         onDestinationSelected: (index) {
//           setState(() => _currentIndex = index);
//           if (index == 1) _syncData();
//         },
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.person_add),
//             label: 'Add Donor',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.storage),
//             label: 'Local Data',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.cloud),
//             label: 'API Data',
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _syncData,
//         child: const Icon(Icons.sync),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';  // Contains ApiService class
import 'api_data_screen.dart';

// Import your screens with explicit prefixes to avoid conflicts
import 'api_service.dart' as api_service;
import 'data_entry_screen.dart' as data_entry;
import 'local_data_screen.dart' as local_data;
import 'api_data_screen.dart' as api_data;

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final apiService = api_service.ApiService();
    await apiService.syncLocalDonors();
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('donors');

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  await Workmanager().registerPeriodicTask(
    "syncTask",
    "syncDonors",
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Donor Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final api_service.ApiService _apiService;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _apiService = api_service.ApiService();
    _screens = [
      data_entry.DataEntryScreen(apiService: _apiService),
      local_data.LocalDataScreen(apiService: _apiService),
      api_data.ApiDataScreen(apiService: _apiService),
    ];

    _syncData();

    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _syncData();
      }
    });
  }

  Future<void> _syncData() async {
    await _apiService.syncLocalDonors();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) _syncData();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_add),
            label: 'Add Donor',
          ),
          NavigationDestination(
            icon: Icon(Icons.storage),
            label: 'Local Data',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud),
            label: 'API Data',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _syncData,
        child: const Icon(Icons.sync),
      ),
    );
  }
}