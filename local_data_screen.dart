import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'api_service.dart';
import 'database_helper.dart';

class LocalDataScreen extends StatefulWidget {
  final ApiService apiService;

  const LocalDataScreen({super.key, required this.apiService});

  @override
  State<LocalDataScreen> createState() => _LocalDataScreenState();
}

class _LocalDataScreenState extends State<LocalDataScreen> {
  List<Map<String, dynamic>> _donors = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final data = await DatabaseHelper.instance.getAllDonors();
      setState(() {
        _donors = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load local data: ${e.toString()}';
      });
    }
  }

  Future<void> _syncData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      await widget.apiService.syncLocalDonors();
      await _loadLocalData(); // Refresh the data after sync

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync completed'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadSingleDonor(Map<String, dynamic> donor) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await widget.apiService.submitDonor({
        'name': donor['name'],
        'email': donor['email'],
        'phone': donor['phone'],
        'blood_group': donor['blood_group'],
        'address': donor['address'],
        'last_donation_date': donor['last_donation_date'],
      });

      if (result['success'] == true) {
        await DatabaseHelper.instance.updateDonorSyncStatus(donor['id'] as int);
        await _loadLocalData(); // Refresh the list

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donor uploaded successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${result['error']}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDonor(int id) async {
    try {
      await DatabaseHelper.instance.deleteDonor(id);
      await _loadLocalData(); // Refresh the list

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donor deleted'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Donors'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade700, Colors.red.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            onPressed: _syncData,
            tooltip: 'Sync all data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : _error.isNotEmpty
          ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
          : _donors.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storage, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No local donors found',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _donors.length,
        itemBuilder: (context, index) {
          final donor = _donors[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade100,
                child: Icon(Icons.person, color: Colors.redAccent),
              ),
              title: Text(
                donor['name'] ?? 'No Name',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Email: ${donor['email']}'),
                  Text('Phone: ${donor['phone']}'),
                  Text('Blood Group: ${donor['blood_group']}'),
                  const SizedBox(height: 8),
                  Text(
                    donor['is_synced'] == 1
                        ? 'Synced with API'
                        : 'Not synced',
                    style: TextStyle(
                      color: donor['is_synced'] == 1
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteDonor(donor['id'] as int),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cloud_upload, color: Colors.blue),
                    onPressed: donor['is_synced'] == 1
                        ? null
                        : () => _uploadSingleDonor(donor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}