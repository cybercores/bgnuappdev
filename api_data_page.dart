import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'helpers.dart';
import 'dart:convert';

class ApiDataPage extends StatefulWidget {
  const ApiDataPage({super.key});

  @override
  State<ApiDataPage> createState() => _ApiDataPageState();
}

class _ApiDataPageState extends State<ApiDataPage> {
  List<dynamic> _apiData = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchApiData();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchApiData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('https://devtechtop.com/management/public/api/select_data'),
      );
      print('Fetched API data: ${response.statusCode}'); // Debug

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _apiData = data['data'] ?? [];
          _filteredData = List.from(_apiData);
        });
      } else {
        setState(() => _hasError = true);
        if (mounted) {
          showToast('Failed to load data', context: context);
        }
      }
    } catch (e) {
      print('Error fetching data: $e'); // Debug
      setState(() => _hasError = true);
      if (mounted) {
        showToast('Error loading data', context: context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredData = _apiData.where((item) {
        return item['user_id'].toString().contains(query) ||
            item['course_name'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchApiData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by User ID or Course Name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterData();
                  },
                ),
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
                            const Text('Failed to load data'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchApiData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredData.isEmpty
                        ? const Center(child: Text('No data available'))
                        : ListView.builder(
                            itemCount: _filteredData.length,
                            itemBuilder: (context, index) {
                              final item = _filteredData[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: ListTile(
                                  title: Text(
                                    item['course_name'] ?? 'No Course Name',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('User ID: ${item['user_id']}'),
                                      Text('Semester: ${item['semester_no']}'),
                                      Text(
                                          'Marks: ${item['marks']} (${item['credit_hours']} CH)'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
