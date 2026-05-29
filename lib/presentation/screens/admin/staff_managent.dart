import 'package:blood_link/presentation/screens/auth/signup.dart';
import 'package:blood_link/themes/colors.dart';
import 'package:flutter/material.dart';

class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        title: const Text("Staff Management",
            style: TextStyle(color: Colors.white)),
        backgroundColor: MyColors.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildStaffCard("John Doe", "Manager"),
          _buildStaffCard("Jane Smith", "Nurse"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignupScreen()),
          );
        },
        backgroundColor: MyColors.primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStaffCard(String name, String position) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        title: Text(name),
        subtitle: Text(position),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Edit staff logic
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: MyColors.primaryColor),
              onPressed: () {
                // Delete staff logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
