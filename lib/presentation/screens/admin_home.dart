import 'package:blood_link/presentation/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'inventory/update_hospital_inventory.dart';
import 'package:blood_link/themes/colors.dart';

class AdminHome extends StatefulWidget {
  final String apiBaseUrl;

  const AdminHome({super.key, required this.apiBaseUrl});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<Map<String, dynamic>> bloodInventory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBloodInventory();
  }

  Future<void> fetchBloodInventory() async {
    final String url = '${widget.apiBaseUrl}/api/hospitalBloods/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          bloodInventory = data.map((item) {
            return {
              'type': '${item['bloodType']}${item['rhFactor']}',
              'bloodType': item['bloodType'],
              'rhFactor': item['rhFactor'],
              'wholeBlood': '${item['components']['wholeBlood']} Pints',
              'rbc': '${item['components']['redBloodCells']} ml',
              'wbc': '${item['components']['whiteBloodCells']} ml',
              'platelets': '${item['components']['platelets']} ml',
              'plasma': '${item['components']['plasma']} ml',
              'cryo': '${item['components']['cryoprecipitate']} ml',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load blood inventory');
      }
    } catch (error) {
      print('Error fetching blood inventory: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        elevation: 2,
        title: Column(
          children: [
            const Text("Admin Panel",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFeatureCard(
                    context, Icons.people, "Staffs", '/StaffManagementPage'),
                _buildFeatureCard(
                    context, Icons.person, "Donors", '/DonorManagementPage'),
                _buildFeatureCard(
                    context, Icons.doorbell, "Requests", '/BloodRequestsPage'),
              ],
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        toolbarHeight: 150, // Increases the AppBar height
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Blood Inventory",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MyColors.primaryColor),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : bloodInventory.isEmpty
                    ? const Center(child: Text('No blood inventory available'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bloodInventory.length,
                        itemBuilder: (context, index) {
                          return _buildInventoryCard(bloodInventory[index]);
                        },
                      ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: MyColors.primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/BloodBankList');
          } else if (index == 2) {
            _logout();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> bloodType) {
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
            bloodType['type'] ?? 'N/A',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MyColors.primaryColor),
          ),
          const SizedBox(height: 10),
          Text('Whole blood: ${bloodType['wholeBlood']}'),
          Text('RBC: ${bloodType['rbc']}'),
          Text('WBC: ${bloodType['wbc']}'),
          Text('Platelets: ${bloodType['platelets']}'),
          Text('Plasma: ${bloodType['plasma']}'),
          Text('Cryoprecipitate: ${bloodType['cryo']}'),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UpdateHospitalInventory(
                        bloodType: bloodType, apiBaseUrl: widget.apiBaseUrl)),
              ).then((_) {
                fetchBloodInventory();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, IconData icon, String title, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route,
            arguments: {'apiBaseUrl': widget.apiBaseUrl});
      },
      child: Container(
        width: 110,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: MyColors.primaryColor),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: MyColors.primaryColor, size: 30),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: MyColors.primaryColor)),
          ],
        ),
      ),
    );
  }
}
