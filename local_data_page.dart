// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'helpers.dart';
// import 'dart:convert';

// class LocalDataPage extends StatefulWidget {
//   const LocalDataPage({super.key});

//   @override
//   State<LocalDataPage> createState() => _LocalDataPageState();
// }

// class _LocalDataPageState extends State<LocalDataPage> {
//   List<Map<String, dynamic>> _localData = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadLocalData();
//   }

//   Future<void> _loadLocalData() async {
//     setState(() => _isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final pendingData = prefs.getStringList('pendingGrades') ?? [];
//       _localData = pendingData
//           .map((data) => json.decode(data) as Map<String, dynamic>)
//           .toList();
//       logDebug('Loaded ${_localData.length} local items');
//     } catch (e) {
//       logDebug('Error loading local data: $e');
//       if (mounted) {
//         showToast('Error loading local data', context: context);
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _deleteItem(int index) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final pendingData = prefs.getStringList('pendingGrades') ?? [];
//       pendingData.removeAt(index);
//       await prefs.setStringList('pendingGrades', pendingData);
//       await _loadLocalData();
//       if (mounted) {
//         showToast('Item deleted successfully', context: context);
//       }
//     } catch (e) {
//       logDebug('Error deleting item: $e');
//       if (mounted) {
//         showToast('Error deleting item', context: context);
//       }
//     }
//   }

//   Future<void> _syncAll() async {
//     try {
//       final hasInternet = await checkInternet();
//       if (!hasInternet) {
//         if (mounted) {
//           showToast('No internet connection', context: context);
//         }
//         return;
//       }

//       setState(() => _isLoading = true);
//       await processPendingSubmissions(context);
//       await _loadLocalData();

//       if (mounted) {
//         showToast('Sync completed', context: context);
//       }
//     } catch (e) {
//       logDebug('Error syncing: $e');
//       if (mounted) {
//         showToast('Error during sync', context: context);
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Local Data'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.sync),
//             onPressed: _localData.isEmpty ? null : _syncAll,
//             tooltip: 'Sync All',
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _localData.isEmpty
//               ? const Center(child: Text('No local data available'))
//               : ListView.builder(
//                   padding: const EdgeInsets.all(8),
//                   itemCount: _localData.length,
//                   itemBuilder: (context, index) {
//                     final data = _localData[index];
//                     return Card(
//                       elevation: 2,
//                       margin: const EdgeInsets.symmetric(vertical: 4),
//                       child: ListTile(
//                         title: Text(
//                           data['course_name'] ?? 'No Course Name',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('User ID: ${data['user_id']}'),
//                             Text('Semester: ${data['semester_no']}'),
//                             Text(
//                                 'Marks: ${data['marks']} (${data['credit_hours']} CH)'),
//                           ],
//                         ),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () => _confirmDelete(context, index),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }

//   Future<void> _confirmDelete(BuildContext context, int index) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Delete'),
//         content: const Text('Are you sure you want to delete this item?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true && mounted) {
//       await _deleteItem(index);
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'helpers.dart';
// import 'dart:convert';

// class LocalDataPage extends StatefulWidget {
//   const LocalDataPage({super.key});

//   @override
//   State<LocalDataPage> createState() => _LocalDataPageState();
// }

// class _LocalDataPageState extends State<LocalDataPage> {
//   List<Map<String, dynamic>> _localData = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadLocalData();
//   }

//   Future<void> _loadLocalData() async {
//     setState(() => _isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final pendingData = prefs.getStringList('pendingGrades') ?? [];
//       _localData = pendingData
//           .map((data) => json.decode(data) as Map<String, dynamic>)
//           .toList();
//       logDebug('Loaded ${_localData.length} local items');
//     } catch (e) {
//       logDebug('Error loading local data: $e');
//       if (mounted) {
//         showToast('Error loading local data', context: context);
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _deleteItem(int index) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final pendingData = prefs.getStringList('pendingGrades') ?? [];
//       pendingData.removeAt(index);
//       await prefs.setStringList('pendingGrades', pendingData);
//       await _loadLocalData();
//       if (mounted) {
//         showToast('Item deleted successfully', context: context);
//       }
//     } catch (e) {
//       logDebug('Error deleting item: $e');
//       if (mounted) {
//         showToast('Error deleting item', context: context);
//       }
//     }
//   }

//   Future<void> _syncAll() async {
//     try {
//       final hasInternet = await checkInternet();
//       if (!hasInternet) {
//         if (!mounted) return;
//         showToast('No internet connection', context: context);
//         return;
//       }

//       setState(() => _isLoading = true);

//       // Check mounted before proceeding with context operations
//       if (!mounted) return;
//       await processPendingSubmissions(context);

//       if (!mounted) return;
//       await _loadLocalData();

//       if (mounted) {
//         showToast('Sync completed', context: context);
//       }
//     } catch (e) {
//       logDebug('Error syncing: $e');
//       if (mounted) {
//         showToast('Error during sync', context: context);
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Local Data'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.sync),
//             onPressed: _localData.isEmpty ? null : _syncAll,
//             tooltip: 'Sync All',
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _localData.isEmpty
//               ? const Center(child: Text('No local data available'))
//               : ListView.builder(
//                   padding: const EdgeInsets.all(8),
//                   itemCount: _localData.length,
//                   itemBuilder: (context, index) {
//                     final data = _localData[index];
//                     return Card(
//                       elevation: 2,
//                       margin: const EdgeInsets.symmetric(vertical: 4),
//                       child: ListTile(
//                         title: Text(
//                           data['course_name'] ?? 'No Course Name',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('User ID: ${data['user_id']}'),
//                             Text('Semester: ${data['semester_no']}'),
//                             Text(
//                                 'Marks: ${data['marks']} (${data['credit_hours']} CH)'),
//                           ],
//                         ),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () => _confirmDelete(context, index),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }

//   Future<void> _confirmDelete(BuildContext context, int index) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Delete'),
//         content: const Text('Are you sure you want to delete this item?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true && mounted) {
//       await _deleteItem(index);
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers.dart';
import 'dart:convert';

class LocalDataPage extends StatefulWidget {
  const LocalDataPage({super.key});

  @override
  State<LocalDataPage> createState() => _LocalDataPageState();
}

class _LocalDataPageState extends State<LocalDataPage> {
  List<Map<String, dynamic>> _localData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingData = prefs.getStringList('pendingGrades') ?? [];
      _localData = pendingData
          .map((data) => json.decode(data) as Map<String, dynamic>)
          .toList();
      logDebug('Loaded ${_localData.length} local items');
    } catch (e) {
      logDebug('Error loading local data: $e');
      if (mounted) {
        showToast('Error loading local data', context: context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteItem(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingData = prefs.getStringList('pendingGrades') ?? [];
      pendingData.removeAt(index);
      await prefs.setStringList('pendingGrades', pendingData);
      await _loadLocalData();
      if (mounted) {
        showToast('Item deleted successfully', context: context);
      }
    } catch (e) {
      logDebug('Error deleting item: $e');
      if (mounted) {
        showToast('Error deleting item', context: context);
      }
    }
  }

  Future<void> _syncAll() async {
    try {
      final hasInternet = await checkInternet();
      if (!hasInternet) {
        if (!mounted) return;
        showToast('No internet connection', context: context);
        return;
      }

      setState(() => _isLoading = true);

      if (!mounted) return;
      await processPendingSubmissions(context);

      if (!mounted) return;
      await _loadLocalData();

      if (mounted) {
        showToast('Sync completed', context: context);
      }
    } catch (e) {
      logDebug('Error syncing: $e');
      if (mounted) {
        showToast('Error during sync', context: context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _localData.isEmpty ? null : _syncAll,
            tooltip: 'Sync All',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _localData.isEmpty
              ? const Center(child: Text('No local data available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _localData.length,
                  itemBuilder: (context, index) {
                    final data = _localData[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          data['course_name'] ?? 'No Course Name',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User ID: ${data['user_id']}'),
                            Text('Semester: ${data['semester_no']}'),
                            Text(
                                'Marks: ${data['marks']} (${data['credit_hours']} CH)'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteItem(index);
    }
  }
}
