import 'dart:convert';
import 'package:flutter/services.dart'
    show
        rootBundle;

class AppConfig {
  final String
      apiBaseUrl;

  AppConfig(
      {required this.apiBaseUrl});

  static Future<AppConfig>
      loadFromAsset() async {
    final configString =
        await rootBundle.loadString('assets/config.json');
    final jsonMap =
        json.decode(configString);
    return AppConfig(apiBaseUrl: jsonMap['apiBaseUrl']);
  }
}
