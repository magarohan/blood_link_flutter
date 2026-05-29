import 'package:shared_preferences/shared_preferences.dart';

class DonorPreferences {
  static Future<void> saveDonorData(
      Map<String, dynamic> donor, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('donorId', donor['_id'] ?? '');
    await prefs.setString('donorName', donor['fullName'] ?? '');
    await prefs.setString('donorEmail', donor['email'] ?? '');
    await prefs.setString('donorBloodType', donor['bloodType'] ?? '');
    await prefs.setString('donorRhFactor', donor['rhFactor'] ?? '');
    await prefs.setString('donorLocation', donor['location'] ?? '');
    await prefs.setString('donorToken', token);
  }

  static Future<Map<String, String>> getDonorData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'donorId': prefs.getString('donorId') ?? '',
      'donorName': prefs.getString('donorName') ?? '',
      'donorEmail': prefs.getString('donorEmail') ?? '',
      'donorBloodType': prefs.getString('donorBloodType') ?? '',
      'donorRhFactor': prefs.getString('donorRhFactor') ?? '',
      'donorLocation': prefs.getString('donorLocation') ?? '',
      'donorToken': prefs.getString('donorToken') ?? '',
    };
  }
}
