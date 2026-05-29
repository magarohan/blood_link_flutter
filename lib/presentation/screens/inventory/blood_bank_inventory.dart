import 'package:blood_link/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http;
import 'dart:convert';
import 'package:pie_chart/pie_chart.dart';

class BloodBank
    extends StatefulWidget {
  final String
      bloodBankId;
  final String
      apiBaseUrl;

  const BloodBank(
      {super.key,
      required this.bloodBankId,
      required this.apiBaseUrl});

  @override
  State<BloodBank> createState() =>
      _BloodBankState();
}

class _BloodBankState
    extends State<BloodBank> {
  List<Map<String, dynamic>>
      bloodInventory =
      [];
  bool
      isLoading =
      true;

  @override
  void
      initState() {
    super.initState();
    fetchBloodInventory();
  }

  // Fetch blood inventory of a specific blood bank
  Future<void>
      fetchBloodInventory() async {
    String
        url =
        '${widget.apiBaseUrl}/api/bloods/bank/${widget.bloodBankId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          bloodInventory = data.map((item) {
            return {
              'type': '${item['bloodType']}${item['rhFactor']}',
              'bloodType': item['bloodType'],
              'rhFactor': item['rhFactor'],
              'wholeBlood': '${item['components']['wholeBlood']} Pints',
              'rbc': '${item['components']['redBloodCells']} ml',
              'wbc': '${item['components']['whiteBloodCells']} ml',
              'platelets': '${item['components']['platelets']} ml',
              'plasma': '${item['components']['plasma']} ml',
              'cryo': '${item['components']['cryoprecipitate']} ml',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load blood inventory');
      }
    } catch (error) {
      print('Error fetching blood inventory: $error');
      setState(() {
        isLoading = false;
        bloodInventory = [];
      });
    }
  }

  // Function to generate pie chart data
  Map<String, double>
      getPieChartData() {
    Map<String, double>
        dataMap =
        {};
    for (var item
        in bloodInventory) {
      String type = item['type'];
      double quantity = double.tryParse(item['wholeBlood'].toString().split(' ')[0]) ?? 0.0;
      dataMap[type] = quantity;
    }
    return dataMap;
  }

  @override
  Widget
      build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Blood Inventory', style: TextStyle(color: Colors.white)),
        backgroundColor: MyColors.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bloodInventory.isEmpty
              ? const Center(child: Text('No blood inventory available'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Pie Chart
                      PieChart(
                        dataMap: getPieChartData(),
                        chartRadius: MediaQuery.of(context).size.width / 2.5,
                        colorList: const [
                          Colors.red,
                          Colors.blue,
                          Colors.green,
                          Colors.orange,
                          Colors.purple,
                          Colors.yellow,
                          Colors.teal,
                          Colors.pink,
                        ],
                        legendOptions: const LegendOptions(
                          showLegendsInRow: false,
                          legendPosition: LegendPosition.right,
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValuesInPercentage: true,
                          showChartValuesOutside: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Blood Inventory List
                      ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(10),
                        itemCount: bloodInventory.length,
                        itemBuilder: (context, index) {
                          var bloodType = bloodInventory[index];
                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(51),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bloodType['type'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text('Whole Blood: ${bloodType['wholeBlood']}'),
                                Text('RBC: ${bloodType['rbc']}'),
                                Text('WBC: ${bloodType['wbc']}'),
                                Text('Platelets: ${bloodType['platelets']}'),
                                Text('Plasma: ${bloodType['plasma']}'),
                                Text('Cryoprecipitate: ${bloodType['cryo']}'),
                                const SizedBox(height: 10),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
