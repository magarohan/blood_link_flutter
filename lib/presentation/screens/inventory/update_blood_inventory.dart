import 'package:blood_link/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config/app_config.dart';

class UpdateBloodInventory extends StatefulWidget {
  final Map<String, dynamic> bloodType;

  const UpdateBloodInventory({super.key, required this.bloodType});

  @override
  State<UpdateBloodInventory> createState() => _UpdateBloodInventoryState();
}

class _UpdateBloodInventoryState extends State<UpdateBloodInventory> {
  late Map<String, dynamic> updatedValues;
  late Future<AppConfig> _configFuture;

  late TextEditingController wholeBloodController;
  late TextEditingController rbcController;
  late TextEditingController wbcController;
  late TextEditingController plateletsController;
  late TextEditingController plasmaController;
  late TextEditingController cryoController;

  @override
  void initState() {
    super.initState();
    updatedValues = Map<String, dynamic>.from(widget.bloodType);
    _configFuture = AppConfig.loadFromAsset();

    wholeBloodController =
        TextEditingController(text: updatedValues['wholeBlood'].toString());
    rbcController =
        TextEditingController(text: updatedValues['rbc'].toString());
    wbcController =
        TextEditingController(text: updatedValues['wbc'].toString());
    plateletsController =
        TextEditingController(text: updatedValues['platelets'].toString());
    plasmaController =
        TextEditingController(text: updatedValues['plasma'].toString());
    cryoController =
        TextEditingController(text: updatedValues['cryo'].toString());
  }

  @override
  void dispose() {
    wholeBloodController.dispose();
    rbcController.dispose();
    wbcController.dispose();
    plateletsController.dispose();
    plasmaController.dispose();
    cryoController.dispose();
    super.dispose();
  }

  int _parseValue(dynamic value) {
    return int.tryParse(value.toString().replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
  }

  Future<void> updateBloodInventory(AppConfig config) async {
    String id = widget.bloodType['id'];
    String url = '${config.apiBaseUrl}/api/bloods/$id';

    final data = {
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
      final response = await http.patch(Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(data));

      if (response.statusCode == 200) {
        print("✅ Blood inventory updated successfully!");
        Navigator.pop(context, updatedValues);
      } else {
        print("❌ Failed to update: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: ${response.body}')),
        );
      }
    } catch (error) {
      print("❌ Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $error')),
      );
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
        final config = snapshot.data!;
        return Scaffold(
          backgroundColor: MyColors.backgroundColor,
          appBar: AppBar(
            title: const Text('Update Blood Inventory',
                style: TextStyle(color: Colors.white)),
            backgroundColor: MyColors.primaryColor,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Updating: ${widget.bloodType['type']}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                    'Whole Blood (Pints)', wholeBloodController, 'wholeBlood'),
                _buildTextField('Red Blood Cells (ml)', rbcController, 'rbc'),
                _buildTextField('White Blood Cells (ml)', wbcController, 'wbc'),
                _buildTextField(
                    'Platelets (ml)', plateletsController, 'platelets'),
                _buildTextField('Plasma (ml)', plasmaController, 'plasma'),
                _buildTextField('Cryoprecipitate (ml)', cryoController, 'cryo'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => updateBloodInventory(config),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Update Inventory',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        onChanged: (value) {
          setState(() {
            updatedValues[key] = _parseValue(value);
          });
        },
      ),
    );
  }
}
