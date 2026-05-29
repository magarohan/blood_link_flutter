import 'package:blood_link/config/app_config.dart';
import 'package:blood_link/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BloodRequestsPage extends StatefulWidget {
  const BloodRequestsPage({super.key});

  @override
  BloodRequestsPageState createState() => BloodRequestsPageState();
}

class BloodRequestsPageState extends State<BloodRequestsPage> {
  List<dynamic> bloodRequests = [];
  bool isLoading = true;
  String errorMessage = '';

  late AppConfig _config;

  @override
  void initState() {
    super.initState();
    _loadConfigAndData();
  }

  Future<void> _loadConfigAndData() async {
    try {
      _config = await AppConfig.loadFromAsset();
      await fetchBloodRequests(_config);
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load configuration or data';
        isLoading = false;
      });
    }
  }

  Future<void> fetchBloodRequests(AppConfig config) async {
    final String url = '${config.apiBaseUrl}/api/requests';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          bloodRequests = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load blood requests: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "Error fetching data: $error";
        isLoading = false;
      });
    }
  }

  Future<void> deleteBloodRequest(String id) async {
    final String url = '${_config.apiBaseUrl}/api/requests/$id';

    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          bloodRequests.removeWhere((request) => request['_id'] == id);
        });
      } else {
        throw Exception('Failed to delete request: ${response.statusCode}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting request: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Blood Requests",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: MyColors.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: bloodRequests.length,
                  itemBuilder: (context, index) {
                    final request = bloodRequests[index];
                    return _buildRequestCard(
                      request['_id'],
                      request['name'],
                      request['location'],
                      request['bloodType'],
                      request['rhFactor'],
                      Map<String, dynamic>.from(request['components'] ?? {}),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/AddRequestPage').then((value) {
            if (value == true) {
              // Reload list if a new request was added
              fetchBloodRequests(_config);
            }
          });
        },
        backgroundColor: MyColors.primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    String id,
    String name,
    String location,
    String bloodType,
    String rhFactor,
    Map<String, dynamic> components,
  ) {
    String bloodTypeWithRh = '$bloodType$rhFactor';

    // Generate components description string
    String componentsText = '';
    if (components.isNotEmpty) {
      components.forEach((key, value) {
        if (value > 0) {
          componentsText +=
              '${_formatComponentKey(key)}: $value unit${value > 1 ? 's' : ''}\n';
        }
      });
    } else {
      componentsText = 'No components available';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: MyColors.primaryColor,
          child: Text(
            bloodTypeWithRh,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location),
            Text(componentsText.trim()),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: MyColors.primaryColor),
          onPressed: () => deleteBloodRequest(id),
        ),
      ),
    );
  }

  // Helper to prettify component keys (e.g. wholeBlood -> Whole Blood)
  String _formatComponentKey(String key) {
    final RegExp regExp = RegExp(r'(?<=[a-z])([A-Z])');
    return key.replaceAllMapped(regExp, (m) => ' ${m.group(0)}').capitalize();
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }
}
