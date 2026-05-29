import 'package:blood_link/bloc/auth/main_bloc.dart';
import 'package:blood_link/bloc/auth/main_event.dart';
import 'package:blood_link/bloc/auth/main_state.dart';
import 'package:blood_link/core/constants/enums.dart';
import 'package:blood_link/core/constants/icons.dart';
import 'package:blood_link/presentation/screens/admin_home.dart';
import 'package:blood_link/presentation/screens/blood_bank.dart';
import 'package:blood_link/presentation/screens/home.dart';
import 'package:blood_link/presentation/widgets/custom_background_widget.dart';
import 'package:blood_link/presentation/widgets/custom_button_widget.dart';
import 'package:blood_link/presentation/widgets/custom_dropdown_widget.dart';
import 'package:blood_link/presentation/widgets/custom_text_field.dart';
import 'package:blood_link/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AppConfig config;
  final List<String> userType = ["Donor", "Hospital", "Blood Bank"];
  String? _selectedUserType;

  @override
  void initState() {
    super.initState();
    _selectedUserType = userType[0];
    _initialize();
  }

  Future<void> _initialize() async {
    config = await AppConfig.loadFromAsset();
    if (mounted) {
      context.read<MainBloc>().add(AuthCheckRequested());
    }
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both Email and Password are required')),
      );
      return;
    }

    context.read<MainBloc>().add(LoginRequested(
          email: email,
          password: password,
        ));
  }

  void _handleNavigation(String userType) async {
    if (userType == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AdminHome(apiBaseUrl: config.apiBaseUrl)),
      );
    } else if (userType == 'donor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (userType == 'bloodBank') {
      final prefs = await SharedPreferences.getInstance();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BloodBank(
            bloodBankId: prefs.getString('bloodBankId') ?? '',
            apiBaseUrl: config.apiBaseUrl,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainBloc, MainState>(
      listener: (context, state) {
        if (state.status == AppStatus.success && state.userType != null) {
          _handleNavigation(state.userType!);
        } else if (state.status == AppStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error ?? 'Authentication failed')),
          );
        }
      },
      child: BlocBuilder<MainBloc, MainState>(
        builder: (context, state) {
          if (state.status == AppStatus.loading && state.userType == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return CustomBackgroundWidget(
            body: Scaffold(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              body: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/blood_drop.png', height: 60),
                        Text(
                          'Blood Link',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: MyColors.primaryColor),
                        ),
                      ],
                    ),
                    CustomTextField(
                      icon: SvgPicture.asset(
                        kMailIcon,
                        colorFilter: ColorFilter.mode(
                            MyColors.primaryColor, BlendMode.srcIn),
                      ),
                      isPassword: false,
                      controller: _emailController,
                      hint: "email@bloodlink.com",
                      label: "Enter your email address",
                    ),
                    CustomTextField(
                      isPassword: true,
                      label: "Enter Password",
                      icon: SvgPicture.asset(
                        kPasswordIcon,
                        colorFilter: ColorFilter.mode(
                            MyColors.primaryColor, BlendMode.srcIn),
                      ),
                      controller: _passwordController,
                      hint: "********",
                    ),
                    CustomDropdownWidget(
                      label: "User Type",
                      items: userType,
                      value: _selectedUserType,
                      onChanged: (value) {
                        setState(() {
                          _selectedUserType = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    state.status == AppStatus.loading
                        ? const CircularProgressIndicator()
                        : CustomButton(
                            title: "Login",
                            onTap: _login,
                            isFilled: true,
                          ),
                    Row(
                      spacing: 5,
                      children: [
                        Expanded(
                          child: Divider(
                            color: MyColors.primaryColor.withValues(alpha: 0.5),
                          ),
                        ),
                        const Text("New to blood link ?"),
                        Expanded(
                          child: Divider(
                            color: MyColors.primaryColor.withValues(alpha: 0.5),
                          ),
                        )
                      ],
                    ),
                    CustomButton(
                        title: "Create an account",
                        onTap: () {},
                        isFilled: false)
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
