// import 'package:flutter/material.dart';
// import 'helpers.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ApiDataPage extends StatefulWidget {
//   const ApiDataPage({super.key});

//   @override
//   State<ApiDataPage> createState() => _ApiDataPageState();
// }

// class _ApiDataPageState extends State<ApiDataPage> {
//   List<dynamic> _apiGrades = [];
//   bool _isLoading = true;
//   bool _hasError = false;
//   final TextEditingController _searchController = TextEditingController();
//   String? _currentUserId;

//   @override
//   void initState() {
//     super.initState();
//     _fetchApiData();
//   }

//   Future<void> _fetchApiData({String? userId}) async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//       _currentUserId = userId; // Store the current user ID being searched
//     });

//     try {
//       final uri = userId != null && userId.isNotEmpty
//           ? Uri.parse(
//               'https://devtechtop.com/management/public/api/select_data?user_id=$userId')
//           : Uri.parse(
//               'https://devtechtop.com/management/public/api/select_data');

//       final response = await http.get(
//         uri,
//         headers: {'Accept': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> grades = [];

//         // Handle different response formats
//         if (data is Map && data.containsKey('data')) {
//           grades = data['data'] is List ? data['data'] : [data['data']];
//         } else if (data is List) {
//           grades = data;
//         } else {
//           grades = [data];
//         }

//         // Additional filtering just in case (though API should handle this)
//         if (userId != null && userId.isNotEmpty) {
//           grades = grades
//               .where((grade) => grade['user_id']?.toString() == userId)
//               .toList();
//         }

//         setState(() {
//           _apiGrades = grades;
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _hasError = true;
//           _isLoading = false;
//         });
//         showToast('API Error: ${response.statusCode}');
//         debugPrint('API Response: ${response.body}');
//       }
//     } catch (e) {
//       setState(() {
//         _hasError = true;
//         _isLoading = false;
//       });
//       showToast('Error: $e');
//       debugPrint('Error details: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: _currentUserId != null && _currentUserId!.isNotEmpty
//             ? Text('Grades for User: $_currentUserId')
//             : const Text('All Grades'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               _searchController.clear();
//               _fetchApiData(); // Reset to show all data
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       labelText: 'Enter User ID',
//                       prefixIcon: const Icon(Icons.search),
//                       suffixIcon: _searchController.text.isNotEmpty
//                           ? IconButton(
//                               icon: const Icon(Icons.clear),
//                               onPressed: () {
//                                 _searchController.clear();
//                                 _fetchApiData(); // Clear search and show all
//                               },
//                             )
//                           : null,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onSubmitted: (value) => _fetchApiData(userId: value.trim()),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_searchController.text.isNotEmpty) {
//                       _fetchApiData(userId: _searchController.text.trim());
//                     }
//                   },
//                   child: const Text('Search'),
//                 ),
//               ],
//             ),
//           ),
//           if (_currentUserId != null && _currentUserId!.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Chip(
//                   label: Text('Showing results for: $_currentUserId'),
//                   onDeleted: () {
//                     _searchController.clear();
//                     _fetchApiData(); // Clear filter
//                   },
//                 ),
//               ),
//             ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _hasError
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text('Failed to load data'),
//                             ElevatedButton(
//                               onPressed: () =>
//                                   _fetchApiData(userId: _currentUserId),
//                               child: const Text('Retry'),
//                             ),
//                           ],
//                         ),
//                       )
//                     : _apiGrades.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   _currentUserId != null &&
//                                           _currentUserId!.isNotEmpty
//                                       ? 'No data found for user $_currentUserId'
//                                       : 'No data available',
//                                 ),
//                                 if (_currentUserId != null &&
//                                     _currentUserId!.isNotEmpty)
//                                   TextButton(
//                                     onPressed: () {
//                                       _searchController.clear();
//                                       _fetchApiData(); // Show all data
//                                     },
//                                     child: const Text('Show all data'),
//                                   ),
//                               ],
//                             ),
//                           )
//                         : RefreshIndicator(
//                             onRefresh: () =>
//                                 _fetchApiData(userId: _currentUserId),
//                             child: ListView.builder(
//                               itemCount: _apiGrades.length,
//                               itemBuilder: (context, index) {
//                                 final grade = _apiGrades[index];
//                                 return Card(
//                                   margin: const EdgeInsets.symmetric(
//                                       horizontal: 16, vertical: 8),
//                                   elevation: 2,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: ListTile(
//                                     title: Text(
//                                       grade['course_name']?.toString() ??
//                                           'No Course',
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     subtitle: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                             'User ID: ${grade['user_id']?.toString() ?? 'N/A'}'),
//                                         Text(
//                                             'Semester: ${grade['semester_no']?.toString() ?? 'N/A'}'),
//                                         Text(
//                                             'Credit Hours: ${grade['credit_hours']?.toString() ?? 'N/A'}'),
//                                         Text(
//                                             'Marks: ${grade['marks']?.toString() ?? 'N/A'}'),
//                                       ],
//                                     ),
//                                     trailing: const Icon(
//                                         Icons.arrow_forward_ios,
//                                         size: 16),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'helpers.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ApiDataPage extends StatefulWidget {
//   const ApiDataPage({super.key});

//   @override
//   State<ApiDataPage> createState() => _ApiDataPageState();
// }

// class _ApiDataPageState extends State<ApiDataPage> {
//   List<dynamic> _apiGrades = [];
//   bool _isLoading = true;
//   bool _hasError = false;
//   final TextEditingController _searchController = TextEditingController();
//   String? _currentUserId;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchApiData();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchApiData({String? userId}) async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//       _currentUserId = userId;
//       _errorMessage = '';
//     });

//     try {
//       final response = await getGradeData(userId: userId);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> grades = [];

//         if (data is Map && data.containsKey('data')) {
//           grades = data['data'] is List ? data['data'] : [data['data']];
//         } else if (data is List) {
//           grades = data;
//         } else {
//           grades = [data];
//         }

//         // Filter empty or null items
//         grades = grades.where((grade) => grade != null).toList();

//         setState(() {
//           _apiGrades = grades;
//           _isLoading = false;
//         });
//       } else {
//         final errorData = jsonDecode(response.body);
//         throw Exception(
//             errorData['message'] ?? 'API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         _hasError = true;
//         _isLoading = false;
//         _errorMessage = e.toString();
//       });
//       debugPrint('Error fetching API data: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: _currentUserId != null && _currentUserId!.isNotEmpty
//             ? Text('Grades for User: $_currentUserId')
//             : const Text('All Grades'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               _searchController.clear();
//               _fetchApiData();
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       labelText: 'Enter User ID',
//                       prefixIcon: const Icon(Icons.search),
//                       suffixIcon: _searchController.text.isNotEmpty
//                           ? IconButton(
//                               icon: const Icon(Icons.clear),
//                               onPressed: () {
//                                 _searchController.clear();
//                                 _fetchApiData();
//                               },
//                             )
//                           : null,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onSubmitted: (value) => _fetchApiData(userId: value.trim()),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_searchController.text.isNotEmpty) {
//                       _fetchApiData(userId: _searchController.text.trim());
//                     } else {
//                       showToast('Please enter a User ID');
//                     }
//                   },
//                   child: const Text('Search'),
//                 ),
//               ],
//             ),
//           ),
//           if (_currentUserId != null && _currentUserId!.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Chip(
//                   label: Text('Showing results for: $_currentUserId'),
//                   onDeleted: () {
//                     _searchController.clear();
//                     _fetchApiData();
//                   },
//                 ),
//               ),
//             ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _hasError
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               _errorMessage.isNotEmpty
//                                   ? _errorMessage
//                                   : 'Failed to load data',
//                               textAlign: TextAlign.center,
//                             ),
//                             const SizedBox(height: 16),
//                             ElevatedButton(
//                               onPressed: () =>
//                                   _fetchApiData(userId: _currentUserId),
//                               child: const Text('Retry'),
//                             ),
//                           ],
//                         ),
//                       )
//                     : _apiGrades.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   _currentUserId != null &&
//                                           _currentUserId!.isNotEmpty
//                                       ? 'No data found for user $_currentUserId'
//                                       : 'No data available',
//                                 ),
//                                 if (_currentUserId != null &&
//                                     _currentUserId!.isNotEmpty)
//                                   TextButton(
//                                     onPressed: () {
//                                       _searchController.clear();
//                                       _fetchApiData();
//                                     },
//                                     child: const Text('Show all data'),
//                                   ),
//                               ],
//                             ),
//                           )
//                         : RefreshIndicator(
//                             onRefresh: () =>
//                                 _fetchApiData(userId: _currentUserId),
//                             child: ListView.builder(
//                               itemCount: _apiGrades.length,
//                               itemBuilder: (context, index) {
//                                 final grade = _apiGrades[index];
//                                 return Card(
//                                   margin: const EdgeInsets.symmetric(
//                                       horizontal: 16, vertical: 8),
//                                   elevation: 2,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: ListTile(
//                                     title: Text(
//                                       grade['course_name']?.toString() ??
//                                           'No Course',
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     subtitle: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                             'User ID: ${grade['user_id']?.toString() ?? 'N/A'}'),
//                                         Text(
//                                             'Semester: ${grade['semester_no']?.toString() ?? 'N/A'}'),
//                                         Text(
//                                             'Credit Hours: ${grade['credit_hours']?.toString() ?? 'N/A'}'),
//                                         Text(
//                                             'Marks: ${grade['marks']?.toString() ?? 'N/A'}'),
//                                       ],
//                                     ),
//                                     trailing: const Icon(
//                                         Icons.arrow_forward_ios,
//                                         size: 16),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'helpers.dart';
import 'dart:convert';

class ApiDataPage extends StatefulWidget {
  const ApiDataPage({super.key});

  @override
  State<ApiDataPage> createState() => _ApiDataPageState();
}

class _ApiDataPageState extends State<ApiDataPage> {
  List<dynamic> _apiGrades = [];
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();
  String? _currentUserId;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchApiData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchApiData({String? userId}) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _currentUserId = userId;
      _errorMessage = '';
    });

    try {
      final response = await getGradeData(userId: userId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> grades = [];

        if (data is Map && data.containsKey('data')) {
          grades = data['data'] is List ? data['data'] : [data['data']];
        } else if (data is List) {
          grades = data;
        } else {
          grades = [data];
        }

        // Filter empty or null items
        grades = grades.where((grade) => grade != null).toList();

        setState(() {
          _apiGrades = grades;
          _isLoading = false;
        });
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'API Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = e.toString();
      });
      debugPrint('Error fetching API data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentUserId != null && _currentUserId!.isNotEmpty
            ? Text('Grades for User: $_currentUserId')
            : const Text('All Grades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _searchController.clear();
              _fetchApiData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Enter User ID',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _fetchApiData();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (value) => _fetchApiData(userId: value.trim()),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      _fetchApiData(userId: _searchController.text.trim());
                    } else {
                      showToast('Please enter a User ID');
                    }
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          if (_currentUserId != null && _currentUserId!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text('Showing results for: $_currentUserId'),
                  onDeleted: () {
                    _searchController.clear();
                    _fetchApiData();
                  },
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage.isNotEmpty
                                  ? _errorMessage
                                  : 'Failed to load data',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  _fetchApiData(userId: _currentUserId),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _apiGrades.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentUserId != null &&
                                          _currentUserId!.isNotEmpty
                                      ? 'No data found for user $_currentUserId'
                                      : 'No data available',
                                ),
                                if (_currentUserId != null &&
                                    _currentUserId!.isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      _fetchApiData();
                                    },
                                    child: const Text('Show all data'),
                                  ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () =>
                                _fetchApiData(userId: _currentUserId),
                            child: ListView.builder(
                              itemCount: _apiGrades.length,
                              itemBuilder: (context, index) {
                                final grade = _apiGrades[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      grade['course_name']?.toString() ??
                                          'No Course',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
