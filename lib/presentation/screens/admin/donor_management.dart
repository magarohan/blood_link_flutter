import 'package:blood_link/presentation/screens/admin/update_donor_page.dart';
import 'package:blood_link/repository/repository.dart';
import 'package:blood_link/themes/colors.dart';
import 'package:flutter/material.dart';

class DonorManagementPage extends StatefulWidget {
  const DonorManagementPage({super.key});

  @override
  DonorManagementPageState createState() => DonorManagementPageState();
}

class DonorManagementPageState extends State<DonorManagementPage> {
  final Repository repository = Repository();
  List<dynamic> donors = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchDonors();
  }

  Future<void> _fetchDonors() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });
    try {
      final fetchedDonors = await repository.fetchDonors();
      setState(() {
        donors = fetchedDonors ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load donors: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Donor Management",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: MyColors.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: TextStyle(color: MyColors.primaryColor)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: donors.length,
                  itemBuilder: (context, index) {
                    return _buildDonorCard(donors[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/Signup').then((value) {
            _fetchDonors();
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

  Widget _buildDonorCard(Map<String, dynamic> donor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        title: Text(donor["fullName"] ?? "No Name"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: ${donor["email"] ?? "N/A"}"),
            Text("Phone: ${donor["phoneNumber"] ?? "N/A"}"),
            Text("Blood Type: ${donor["bloodType"] ?? "N/A"}"),
            Text("RH Factor: ${donor["rhFactor"] ?? "N/A"}"),
            Text("Location: ${donor["location"] ?? "N/A"}"),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateDonorPage(donor: donor),
                  ),
                ).then((value) {
                  _fetchDonors();
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: MyColors.primaryColor),
              onPressed: () async {
                try {
                  await repository.deleteDonor(donor["_id"]);
                  _fetchDonors();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Delete failed: $e")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
