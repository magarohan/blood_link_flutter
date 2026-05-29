import 'package:blood_link/bloc/auth/main_bloc.dart';
import 'package:blood_link/config/app_config.dart';
import 'package:blood_link/presentation/screens/add_request_page.dart';
import 'package:blood_link/presentation/screens/admin/donor_management.dart';
import 'package:blood_link/presentation/screens/admin/staff_managent.dart';
import 'package:blood_link/presentation/screens/auth/login.dart';
import 'package:blood_link/presentation/screens/auth/profile.dart';
import 'package:blood_link/presentation/screens/auth/signup.dart';
import 'package:blood_link/presentation/screens/blood_request_page.dart';
import 'package:blood_link/presentation/screens/home.dart';
import 'package:blood_link/presentation/screens/inventory/bloodbank_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['URL'] ?? '',
    anonKey: dotenv.env['KEY'] ?? '',
  );
  final config = await AppConfig.loadFromAsset();
  runApp(MyApp(apiBaseUrl: config.apiBaseUrl));
}

class MyApp extends StatelessWidget {
  final String apiBaseUrl;
  const MyApp({super.key, required this.apiBaseUrl});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MainBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Blood Link',
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/staffManagementPage': (context) => const StaffManagementPage(),
          '/donorManagementPage': (context) => const DonorManagementPage(),
          '/bloodRequestsPage': (context) => const BloodRequestsPage(),
          '/bloodBankList': (context) => const BloodBankList(),
          '/addRequestPage': (context) =>
              AddRequestPage(config: AppConfig(apiBaseUrl: apiBaseUrl)),
          '/donorHome': (context) => const HomeScreen(),
          '/profile': (context) => const ProfilePage(),
        },
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.red,
        ),
      ),
    );
  }
}
