// import 'package:flutter/material.dart';
// import 'helpers.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class LocalDataPage extends StatefulWidget {
//   const LocalDataPage({super.key});

//   @override
//   State<LocalDataPage> createState() => _LocalDataPageState();
// }

// class _LocalDataPageState extends State<LocalDataPage> {
//   List<Map<String, dynamic>> _localGrades = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadLocalData();
//   }

//   Future<void> _loadLocalData() async {
//     setState(() => _isLoading = true);
//     try {
//       final localData = await getLocalData();
//       setState(() {
//         _localGrades = localData;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       showToast('Error loading local data: $e');
//     }
//   }

//   Future<void> _syncWithApi() async {
//     if (!await checkInternet()) {
//       showToast('No internet connection');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       for (final grade in _localGrades) {
//         final response = await http.post(
//           Uri.parse('https://devtechtop.com/management/public/api/grades'),
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//           },
//           body: jsonEncode(grade),
//         );

//         if (response.statusCode != 200 && response.statusCode != 201) {
//           throw Exception('Failed to sync grade: ${grade['course_name']}');
//         }
//       }

//       await clearLocalData();
//       showToast('All local data synced with API');
//       _loadLocalData();
//     } catch (e) {
//       setState(() => _isLoading = false);
//       showToast('Sync Error: $e');
//     }
//   }

//   Future<void> _deleteLocalData() async {
//     try {
//       await clearLocalData();
//       showToast('Local data cleared');
//       _loadLocalData();
//     } catch (e) {
//       showToast('Error clearing data: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Local Grades'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadLocalData,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _localGrades.isEmpty
//               ? const Center(
//                   child: Text(
//                     'No local data available',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 )
//               : RefreshIndicator(
//                   onRefresh: _loadLocalData,
//                   child: ListView.builder(
//                     itemCount: _localGrades.length,
//                     itemBuilder: (context, index) {
//                       final grade = _localGrades[index];
//                       return Card(
//                         margin: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 8),
//                         elevation: 2,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: ListTile(
//                           title: Text(
//                             grade['course_name']?.toString() ?? 'No Course',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                   'User ID: ${grade['user_id']?.toString() ?? 'N/A'}'),
//                               Text(
//                                   'Semester: ${grade['semester_no']?.toString() ?? 'N/A'}'),
//                               Text(
//                                   'Credit Hours: ${grade['credit_hours']?.toString() ?? 'N/A'}'),
//                               Text(
//                                   'Marks: ${grade['marks']?.toString() ?? 'N/A'}'),
//                             ],
//                           ),
//                           trailing:
//                               const Icon(Icons.arrow_forward_ios, size: 16),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: _syncWithApi,
//             tooltip: 'Sync with API',
//             backgroundColor: Colors.green,
//             child: const Icon(Icons.cloud_upload),
//           ),
//           const SizedBox(height: 16),
//           FloatingActionButton(
//             onPressed: _deleteLocalData,
//             tooltip: 'Clear local data',
//             backgroundColor: Colors.red,
//             child: const Icon(Icons.delete),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'helpers.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class LocalDataPage extends StatefulWidget {
//   const LocalDataPage({super.key});

//   @override
//   State<LocalDataPage> createState() => _LocalDataPageState();
// }

// class _LocalDataPageState extends State<LocalDataPage> {
//   List<Map<String, dynamic>> _localGrades = [];
//   bool _isLoading = true;
//   bool _isSyncing = false;
//   bool _isDeleting = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadLocalData();
//   }

//   Future<void> _loadLocalData() async {
//     setState(() => _isLoading = true);
//     try {
//       final localData = await getLocalData();
//       setState(() {
//         _localGrades = localData;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       showToast('Error loading local data: $e');
//     }
//   }

//   Future<void> _syncWithApi() async {
//     if (!await checkInternet()) {
//       showToast('No internet connection');
//       return;
//     }

//     setState(() => _isSyncing = true);

//     try {
//       final failedSyncs = <Map<String, dynamic>>[];

//       for (final grade in _localGrades) {
//         try {
//           final response = await postGradeData(grade);

//           if (response.statusCode != 200 && response.statusCode != 201) {
//             failedSyncs.add(grade);
//             debugPrint('Failed to sync grade: ${grade['course_name']}');
//           }
//         } catch (e) {
//           failedSyncs.add(grade);
//           debugPrint('Error syncing grade: $e');
//         }
//       }

//       if (failedSyncs.isEmpty) {
//         await clearLocalData();
//         showToast('All local data synced successfully');
//         _loadLocalData();
//       } else {
//         // Save back only the failed syncs
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setStringList(
//           'localGrades',
//           failedSyncs.map((g) => jsonEncode(g)).toList(),
//         );
//         showToast(
//             'Partial sync: ${_localGrades.length - failedSyncs.length} succeeded, ${failedSyncs.length} failed');
//         _loadLocalData();
//       }
//     } catch (e) {
//       showToast('Sync Error: $e');
//     } finally {
//       setState(() => _isSyncing = false);
//     }
//   }

//   Future<void> _deleteLocalData() async {
//     setState(() => _isDeleting = true);
//     try {
//       await clearLocalData();
//       showToast('Local data cleared');
//       _loadLocalData();
//     } catch (e) {
//       showToast('Error clearing data: $e');
//     } finally {
//       setState(() => _isDeleting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Local Grades'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadLocalData,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _localGrades.isEmpty
//               ? const Center(
//                   child: Text(
//                     'No local data available',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 )
//               : RefreshIndicator(
//                   onRefresh: _loadLocalData,
//                   child: ListView.builder(
//                     itemCount: _localGrades.length,
//                     itemBuilder: (context, index) {
//                       final grade = _localGrades[index];
//                       return Card(
//                         margin: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 8),
//                         elevation: 2,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: ListTile(
//                           title: Text(
//                             grade['course_name']?.toString() ?? 'No Course',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                   'User ID: ${grade['user_id']?.toString() ?? 'N/A'}'),
//                               Text(
//                                   'Semester: ${grade['semester_no']?.toString() ?? 'N/A'}'),
//                               Text(
//                                   'Credit Hours: ${grade['credit_hours']?.toString() ?? 'N/A'}'),
//                               Text(
//                                   'Marks: ${grade['marks']?.toString() ?? 'N/A'}'),
//                             ],
//                           ),
//                           trailing:
//                               const Icon(Icons.arrow_forward_ios, size: 16),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: _isSyncing ? null : _syncWithApi,
//             tooltip: 'Sync with API',
//             backgroundColor: Colors.green,
//             child: _isSyncing
//                 ? const CircularProgressIndicator(color: Colors.white)
//                 : const Icon(Icons.cloud_upload),
//           ),
//           const SizedBox(height: 16),
//           FloatingActionButton(
//             onPressed: _isDeleting ? null : _deleteLocalData,
//             tooltip: 'Clear local data',
//             backgroundColor: Colors.red,
//             child: _isDeleting
//                 ? const CircularProgressIndicator(color: Colors.white)
//                 : const Icon(Icons.delete),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalDataPage extends StatefulWidget {
  const LocalDataPage({super.key});

  @override
  State<LocalDataPage> createState() => _LocalDataPageState();
}

class _LocalDataPageState extends State<LocalDataPage> {
  List<Map<String, dynamic>> _localGrades = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    setState(() => _isLoading = true);
    try {
      final localData = await getLocalData();
      setState(() {
        _localGrades = localData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      showToast('Error loading local data: $e');
    }
  }

  Future<void> _syncWithApi() async {
    if (!await checkInternet()) {
      showToast('No internet connection');
      return;
    }

    setState(() => _isSyncing = true);

    try {
      final failedSyncs = <Map<String, dynamic>>[];

      for (final grade in _localGrades) {
        try {
          final response = await postGradeData(grade);

          if (response.statusCode != 200 && response.statusCode != 201) {
            failedSyncs.add(grade);
            debugPrint('Failed to sync grade: ${grade['course_name']}');
          }
        } catch (e) {
          failedSyncs.add(grade);
          debugPrint('Error syncing grade: $e');
        }
      }

      if (failedSyncs.isEmpty) {
        await clearLocalData();
        showToast('All local data synced successfully');
        _loadLocalData();
      } else {
        // Save back only the failed syncs
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(
          'localGrades',
          failedSyncs.map((g) => jsonEncode(g)).toList(),
        );
        showToast(
            'Partial sync: ${_localGrades.length - failedSyncs.length} succeeded, ${failedSyncs.length} failed');
        _loadLocalData();
      }
    } catch (e) {
      showToast('Sync Error: $e');
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  Future<void> _deleteLocalData() async {
    setState(() => _isDeleting = true);
    try {
      await clearLocalData();
      showToast('Local data cleared');
      _loadLocalData();
    } catch (e) {
      showToast('Error clearing data: $e');
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Grades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLocalData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _localGrades.isEmpty
              ? const Center(
                  child: Text(
                    'No local data available',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLocalData,
                  child: ListView.builder(
                    itemCount: _localGrades.length,
                    itemBuilder: (context, index) {
                      final grade = _localGrades[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            grade['course_name']?.toString() ?? 'No Course',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'User ID: ${grade['user_id']?.toString() ?? 'N/A'}'),
                              Text(
                                  'Semester: ${grade['semester_no']?.toString() ?? 'N/A'}'),
                              Text(
                                  'Credit Hours: ${grade['credit_hours']?.toString() ?? 'N/A'}'),
                              Text(
                                  'Marks: ${grade['marks']?.toString() ?? 'N/A'}'),
                            ],
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _isSyncing ? null : _syncWithApi,
            tooltip: 'Sync with API',
            backgroundColor: Colors.green,
            child: _isSyncing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.cloud_upload),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _isDeleting ? null : _deleteLocalData,
            tooltip: 'Clear local data',
            backgroundColor: Colors.red,
            child: _isDeleting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
