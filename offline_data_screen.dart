import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineDataScreen extends StatefulWidget {
  const OfflineDataScreen({super.key});

  @override
  _OfflineDataScreenState createState() => _OfflineDataScreenState();
}

class _OfflineDataScreenState extends State<OfflineDataScreen> {
  List<Map<String, dynamic>> _offlineDonors = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadOfflineData();
  }

  Future<void> _loadOfflineData() async {
    setState(() => _isLoading = true);
    final donors = await DatabaseHelper.instance.getDonors();
    setState(() {
      _offlineDonors = donors;
      _isLoading = false;
    });
  }

  Future<void> _syncData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection available')),
      );
      return;
    }

    setState(() => _isSyncing = true);
    try {
      for (final donor in _offlineDonors) {
        await ApiService().addDonor(donor);
        await DatabaseHelper.instance.deleteDonor(donor['id']);
      }
      await _loadOfflineData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Synced ${_offlineDonors.length} donors')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error syncing: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Data'),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const CircularProgressIndicator()
                : const Icon(Icons.cloud_upload),
            onPressed: _syncData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _offlineDonors.isEmpty
          ? const Center(child: Text('No offline data available'))
          : ListView.builder(
        itemCount: _offlineDonors.length,
        itemBuilder: (context, index) {
          final donor = _offlineDonors[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                vertical: 4, horizontal: 8),
            child: ListTile(
              title: Text(donor['name'] ?? 'No Name'),
              subtitle: Text(
                  '${donor['blood_group']} - ${donor['city']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await DatabaseHelper.instance
                      .deleteDonor(donor['id']);
                  await _loadOfflineData();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

