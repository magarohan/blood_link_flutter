import 'dart:convert';

import 'package:blood_link/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';

class Repository {
  Repository();

  Future<AppConfig> get _config => AppConfig.loadFromAsset();

  Future<String?> loginAdmin(String email, String password) async {
    if (email == "admin" && password == "admin") {
      return "admin";
    }
    return null;
  }

  Future<Map<String, dynamic>?> loginDonor(
      String email, String password) async {
    final config = await _config;
    final uri = Uri.parse('${config.apiBaseUrl}/api/donors/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data.containsKey('donor')) {
        final prefs = await SharedPreferences.getInstance();

        final donor = data['donor'];
        final token = data['token'];

        await prefs.setString('donorId', donor['_id'] ?? '');
        await prefs.setString('donorName', donor['fullName'] ?? '');
        await prefs.setString('donorBloodType', donor['bloodType'] ?? '');
        await prefs.setString('donorRhFactor', donor['rhFactor'] ?? '');
        await prefs.setString('donorEmail', donor['email'] ?? '');
        await prefs.setString('donorLocation', donor['location'] ?? '');
        await prefs.setString('donorToken', token ?? '');

        return {
          "type": "donor",
          "data": donor,
        };
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> loginBloodBank(
      String email, String password) async {
    final config = await _config;
    final uri = Uri.parse('${config.apiBaseUrl}/api/bloodBanks/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bloodBankToken', data['token']);
      await prefs.setString('bloodBankId', data['bloodBank']['_id']);

      return {
        "type": "bloodBank",
        "data": data,
      };
    }

    return null;
  }

  Future<Map<String, dynamic>?> registerDonor(
      UserModel donor, String password) async {
    final config = await _config;
    final url = Uri.parse('${config.apiBaseUrl}/api/donors/signup');
    try {
      final body = donor.toJson();
      body['password'] = password;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String?>> getStoredSession() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "donorToken": prefs.getString('donorToken'),
      "bloodBankToken": prefs.getString('bloodBankToken'),
      "bloodBankId": prefs.getString('bloodBankId'),
    };
  }

  Future<dynamic> createDonor(String donorId, UserModel model) async {
    final config = await _config;
    final String url = '${config.apiBaseUrl}/api/donors/update/$donorId';

    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(model.toJson()),
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> fetchDonors() async {
    final config = await _config;
    final String baseUrl = '${config.apiBaseUrl}/api/donors/';
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return responseData;
    }
    return null;
  }

  Future<dynamic> deleteDonor(String id) async {
    final config = await _config;
    final String baseUrl = '${config.apiBaseUrl}/api/donors/';

    final response = await http.delete(Uri.parse('$baseUrl$id'));
    return jsonDecode(response.body);
  }

  Future<dynamic> updateDonor(String donorId, UserModel model) async {
    final config = await _config;
    final String url = '${config.apiBaseUrl}/api/donors/update/$donorId';

    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(model.toJson()),
    );
    return jsonDecode(response.body);
  }
}
