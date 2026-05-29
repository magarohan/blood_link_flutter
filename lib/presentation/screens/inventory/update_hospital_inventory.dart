import 'package:blood_link/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateHospitalInventory extends StatefulWidget {
  final Map<String, dynamic> bloodType;
  final String apiBaseUrl;

  const UpdateHospitalInventory(
      {super.key, required this.bloodType, required this.apiBaseUrl});

  @override
  State<UpdateHospitalInventory> createState() => _UpdateBloodInventoryState();
}

class _UpdateBloodInventoryState extends State<UpdateHospitalInventory> {
  late Map<String, dynamic> updatedValues;
  final Map<String, String> _units = {
    'wholeBlood': 'Pints',
    'rbc': 'ml',
    'wbc': 'ml',
    'platelets': 'ml',
    'plasma': 'ml',
    'cryo': 'ml',
  };

  @override
  void initState() {
    super.initState();
    updatedValues = Map<String, dynamic>.from(widget.bloodType);
  }

  int _parseValue(dynamic value) {
    return int.tryParse(value.toString().replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
  }

  Future<void> updateBloodInventory() async {
    String url = '${widget.apiBaseUrl}/api/hospitalBloods/updateBlood';

    String bloodType = widget.bloodType['bloodType'];
    String rhFactor = widget.bloodType['rhFactor'];

    print("Updating: Blood Type: $bloodType, Rh Factor: $rhFactor");

    final Map<String, dynamic> data = {
      "bloodType": bloodType,
      "rhFactor": rhFactor,
      "components": {
        "wholeBlood": _parseValue(updatedValues['wholeBlood']),
        "redBloodCells": _parseValue(updatedValues['rbc']),
        "whiteBloodCells": _parseValue(updatedValues['wbc']),
        "platelets": _parseValue(updatedValues['platelets']),
        "plasma": _parseValue(updatedValues['plasma']),
        "cryoprecipitate": _parseValue(updatedValues['cryo']),
      }
    };

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print("✅ Blood inventory updated successfully!");
        Navigator.pop(context, updatedValues);
      } else {
        print("❌ Failed to update: ${response.body}");
      }
    } catch (error) {
      print("❌ Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
          title: Text('Update ${widget.bloodType['type']}, ',
              style: const TextStyle(color: Colors.white)),
          backgroundColor: MyColors.primaryColor),
      body: Column(
        children: [
          for (String key in [
            'wholeBlood',
            'rbc',
            'wbc',
            'platelets',
            'plasma',
            'cryo'
          ])
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(key.toUpperCase()),
                IconButton(
                    onPressed: () => setState(() => updatedValues[key] =
                        '${_parseValue(updatedValues[key]) - 1} ${_units[key]}'),
                    icon: const Icon(Icons.remove)),
                Text('${updatedValues[key]}'),
                IconButton(
                    onPressed: () => setState(() => updatedValues[key] =
                        '${_parseValue(updatedValues[key]) + 1} ${_units[key]}'),
                    icon: const Icon(Icons.add)),
              ],
            ),
          ElevatedButton(
            onPressed: updateBloodInventory,
            style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primaryColor),
            child: const Text(
              "Save Changes",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
