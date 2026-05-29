import 'package:blood_link/config/app_config.dart';
import 'package:blood_link/data/models/user_model.dart';
import 'package:blood_link/presentation/widgets/custom_text_field.dart';
import 'package:blood_link/repository/repository.dart';
import 'package:blood_link/themes/colors.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _rhFactorController = TextEditingController();
  final _locationController = TextEditingController();

  final Repository _authRepository = Repository();
  late Future<AppConfig> _configFuture;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _configFuture = AppConfig.loadFromAsset();
  }

  Future<void> _register() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final bloodType = _bloodTypeController.text.trim();
    final rhFactor = _rhFactorController.text.trim();
    final location = _locationController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phoneNumber.isEmpty ||
        bloodType.isEmpty ||
        rhFactor.isEmpty ||
        location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final donor = UserModel(
        id: '',
        name: fullName,
        email: email,
        phoneNumber: phoneNumber,
        bloodType: bloodType,
        rhFactor: rhFactor,
        location: location,
      );

      await _authRepository.registerDonor(donor, password);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppConfig>(
      future: _configFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          backgroundColor: MyColors.backgroundColor,
          appBar: AppBar(
            title: const Text('Sign Up', style: TextStyle(color: Colors.white)),
            backgroundColor: MyColors.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/blood_drop.png',
                              height: 60,
                            ),
                            Text(
                              'Blood Link',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: MyColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    controller: _fullNameController,
                    hint: 'Full Name',
                    isPassword: false,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _emailController,
                    hint: 'Email',
                    isPassword: false,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hint: "Password",
                    controller: _passwordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _phoneController,
                    hint: 'Phone Number',
                    isPassword: false,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _bloodTypeController,
                    hint: 'Blood Type',
                    isPassword: false,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _rhFactorController,
                    hint: 'Rh Factor',
                    isPassword: false,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _locationController,
                    hint: 'Location',
                    isPassword: false,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _register,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Register',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Log In.',
                          style: TextStyle(
                            color: MyColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
