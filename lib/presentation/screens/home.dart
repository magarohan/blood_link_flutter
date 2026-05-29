import 'package:blood_link/config/app_config.dart';
import 'package:blood_link/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login.dart';
// import 'donation_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? donorName;
  String? donorBloodType;
  String? donorRhFactor;
  bool isLoading = true;
  List<Map<String, dynamic>> bloodRequests = [];
  late Future<AppConfig> _configFuture;

  @override
  void initState() {
    super.initState();
    _configFuture = AppConfig.loadFromAsset();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('donorToken');

    if (token != null && token.isNotEmpty) {
      _loadDonorInfo();
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _loadDonorInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('donorName');
    final bloodType = prefs.getString('donorBloodType');
    final rhFactor = prefs.getString('donorRhFactor');

    if (name != null && bloodType != null && rhFactor != null) {
      setState(() {
        donorName = name;
        donorBloodType = bloodType;
        donorRhFactor = rhFactor;
      });
      final config = await _configFuture;
      _fetchMatchingBloodRequests(config.apiBaseUrl, bloodType, rhFactor);
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No donor info found. Please log in again.')),
      );
    }
  }

  Future<void> _fetchMatchingBloodRequests(
      String apiBaseUrl, String bloodType, String rhFactor) async {
    final url = Uri.parse(
        '$apiBaseUrl/api/requests/search?bloodType=$bloodType&rhFactor=$rhFactor');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            bloodRequests = List<Map<String, dynamic>>.from(data);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No matching blood requests found.')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No matching blood requests found.')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while fetching requests.')),
      );
      print(error);
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
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          donorName != null ? 'Welcome, $donorName!' : 'Welcome!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: MyColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: bloodRequests.isEmpty
          ? const Center(child: Text('No matching blood requests found.'))
          : ListView.builder(
              itemCount: bloodRequests.length,
              itemBuilder: (context, index) {
                final request = bloodRequests[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 2,
                  child: ListTile(
                    title: Text('Requested by: ${request['name']}'),
                    subtitle: Text('Location: ${request['location']}'),
                    trailing: Text(
                      '${request['bloodType']} ${request['rhFactor']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MyColors.primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const DonationPage()),
          // );
        },
        label: const Text('Donate'),
        icon: const Icon(Icons.favorite),
        backgroundColor: MyColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: MyColors.primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/BloodBankList');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/Profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
