import 'dart:convert';

import 'package:blood_link/presentation/widgets/custom_button_widget.dart';
import 'package:blood_link/presentation/widgets/custom_text_field.dart';
import 'package:blood_link/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController bloodTypeController;
  late TextEditingController rhFactorController;
  late TextEditingController locationController;

  String? donorId;
  late Future<AppConfig> _configFuture;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    bloodTypeController = TextEditingController();
    rhFactorController = TextEditingController();
    locationController = TextEditingController();

    _configFuture = AppConfig.loadFromAsset();
    _loadDonorInfo();
  }

  Future<void> _loadDonorInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      donorId = prefs.getString('donorId');
      nameController.text = prefs.getString('donorName') ?? '';
      emailController.text = prefs.getString('donorEmail') ?? '';
      bloodTypeController.text = prefs.getString('donorBloodType') ?? '';
      rhFactorController.text = prefs.getString('donorRhFactor') ?? '';
      locationController.text = prefs.getString('donorLocation') ?? '';
    });
  }

  Future<void> _saveProfile(AppConfig config) async {
    if (donorId == null || donorId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid donor ID")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('donorName', nameController.text);
    await prefs.setString('donorEmail', emailController.text);
    await prefs.setString('donorBloodType', bloodTypeController.text);
    await prefs.setString('donorRhFactor', rhFactorController.text);
    await prefs.setString('donorLocation', locationController.text);

    final apiUrl = '${config.apiBaseUrl}/api/donors/update/$donorId';

    final response = await http.patch(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "fullName": nameController.text,
        "email": emailController.text,
        "bloodType": bloodTypeController.text,
        "rhFactor": rhFactorController.text,
        "location": locationController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile updated successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: MyColors.primaryColor,
      ),
      body: FutureBuilder<AppConfig>(
        future: _configFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final config = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  CustomTextField(hint: "Name", controller: nameController),
                  CustomTextField(hint: "Email", controller: emailController),
                  CustomTextField(
                      hint: "Blood Type", controller: bloodTypeController),
                  CustomTextField(
                      hint: "Rh Factor", controller: rhFactorController),
                  CustomTextField(
                      hint: "Location", controller: locationController),
                  const SizedBox(height: 20),
                  CustomButton(
                      title: "Save Profile",
                      onTap: () => _saveProfile(config),
                      isFilled: true)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
