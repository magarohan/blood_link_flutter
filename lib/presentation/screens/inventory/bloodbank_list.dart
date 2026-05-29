import 'package:blood_link/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:blood_link/themes/colors.dart';
import 'package:blood_link/presentation/screens/inventory/blood_bank_inventory.dart';
import 'package:blood_link/presentation/screens/map_page.dart';

class BloodBankList extends StatefulWidget {
  const BloodBankList({super.key});

  @override
  State<BloodBankList> createState() => _BloodBankListState();
}

class _BloodBankListState extends State<BloodBankList> {
  List<Map<String, dynamic>> bloodBankList = [];
  bool isLoading = true;
  late AppConfig _config;

  @override
  void initState() {
    super.initState();
    _loadConfigAndFetchBloodBanks();
  }

  Future<void> _loadConfigAndFetchBloodBanks() async {
    try {
      _config = await AppConfig.loadFromAsset();
      await fetchBloodBanks(_config);
    } catch (e) {
      print('Error loading config or fetching blood banks: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchBloodBanks(AppConfig config) async {
    final String url = '${config.apiBaseUrl}/api/bloodBanks';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          bloodBankList = data.map((item) {
            return {
              'id': item['_id'],
              'name': item['name'],
              'address': item['address'],
              'contact': item['contact'],
              'latitude': item['latitude'] is String
                  ? double.tryParse(item['latitude']) ?? 0.0
                  : (item['latitude']?.toDouble() ?? 0.0),
              'longitude': item['longitude'] is String
                  ? double.tryParse(item['longitude']) ?? 0.0
                  : (item['longitude']?.toDouble() ?? 0.0),
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load blood banks with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching blood banks: $error');
      setState(() {
        isLoading = false;
      });
      // Optionally you can show a SnackBar or error UI here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        elevation: 2,
        title: const Text(
          "Blood Banks",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bloodBankList.isEmpty
              ? const Center(child: Text('No blood banks available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: bloodBankList.length,
                  itemBuilder: (context, index) {
                    return _buildBloodBankCard(
                        bloodBankList[index], _config.apiBaseUrl);
                  },
                ),
    );
  }

  Widget _buildBloodBankCard(
      Map<String, dynamic> bloodBank, String apiBaseUrl) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MyColors.primaryColor),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bloodBank['name'] ?? 'N/A',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MyColors.primaryColor),
          ),
          const SizedBox(height: 5),
          Text('Address: ${bloodBank['address']}'),
          Text('Contact: ${bloodBank['contact']}'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BloodBank(
                          bloodBankId: bloodBank['id'], apiBaseUrl: apiBaseUrl),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('View Inventory',
                    style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  double? lat = bloodBank['latitude'];
                  double? lng = bloodBank['longitude'];

                  if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(
                          name: bloodBank['name'],
                          latitude: lat,
                          longitude: lng,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid location data')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('View Location',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
