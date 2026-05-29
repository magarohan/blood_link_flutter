import 'package:blood_link/bloc/auth/main_state.dart';
import 'package:blood_link/core/constants/enums.dart';
import 'package:blood_link/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/auth/main_bloc.dart';
import '../../../bloc/auth/main_event.dart';
import '../../../config/app_config.dart';
import '../../../data/models/user_model.dart';

class UpdateDonorPage extends StatefulWidget {
  final Map<String, dynamic> donor;

  const UpdateDonorPage({super.key, required this.donor});

  @override
  UpdateDonorPageState createState() => UpdateDonorPageState();
}

class UpdateDonorPageState extends State<UpdateDonorPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _rhFactorController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  late Future<AppConfig> _configFuture;

  @override
  void initState() {
    super.initState();
    _configFuture = AppConfig.loadFromAsset();
    _nameController.text = widget.donor['fullName'] ?? '';
    _emailController.text = widget.donor['email'] ?? '';
    _phoneController.text = widget.donor['phoneNumber'] ?? '';
    _bloodTypeController.text = widget.donor['bloodType'] ?? '';
    _rhFactorController.text = widget.donor['rhFactor'] ?? '';
    _locationController.text = widget.donor['location'] ?? '';
  }

  // Future<void> updateDonor(AppConfig config) async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   String donorId = widget.donor["id"] ?? '';
  //   if (donorId.isEmpty) {
  //     print("Error: Donor ID is missing");
  //     setState(() {
  //       isLoading = false;
  //     });
  //     return;
  //   }
  //
  //   Map<String, String> updatedDonor = {
  //     "fullName": _nameController.text,
  //     "email": _emailController.text,
  //     "phoneNumber": _phoneController.text,
  //     "bloodType": _bloodTypeController.text,
  //     "rhFactor": _rhFactorController.text,
  //     "location": _locationController.text,
  //   };
  //
  //   try {
  //     final response = await http.patch(
  //       Uri.parse('${config.apiBaseUrl}/api/donors/update/$donorId'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode(updatedDonor),
  //     );id
  //
  //     if (response.statusCode == 200) {
  //       print('Donor updated successfully');
  //       Navigator.pop(context); // Go back after success
  //     } else {
  //       print('Failed to update donor: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error updating donor: $e');
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

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
        return BlocListener<MainBloc, MainState>(
          listener: (context, state) {
            if (state.updateDonorState == AppStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Donor updated successfully')),
              );
              Navigator.pop(context);
            } else if (state.updateDonorState == AppStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to update donor')),
              );
            }
          },
          child: Scaffold(
            backgroundColor: MyColors.backgroundColor,
            appBar: AppBar(
              title: const Text('Update Donor',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: MyColors.primaryColor,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: _phoneController,
                      decoration:
                          const InputDecoration(labelText: 'Phone Number'),
                    ),
                    TextField(
                      controller: _bloodTypeController,
                      decoration:
                          const InputDecoration(labelText: 'Blood Group'),
                    ),
                    TextField(
                      controller: _rhFactorController,
                      decoration: const InputDecoration(labelText: 'RH Factor'),
                    ),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final donor = UserModel(
                          id: widget.donor['_id'] ?? '',
                          name: _nameController.text,
                          email: _emailController.text,
                          phoneNumber: _phoneController.text,
                          bloodType: _bloodTypeController.text,
                          rhFactor: _rhFactorController.text,
                          location: _locationController.text,
                        );
                        context
                            .read<MainBloc>()
                            .add(DonorUpdated(id: donor.id, model: donor));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primaryColor),
                      child: BlocBuilder<MainBloc, MainState>(
                        builder: (context, state) {
                          if (state.updateDonorState == AppStatus.loading) {
                            return const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            );
                          }
                          return const Text('Update Donor',
                              style: TextStyle(color: Colors.white));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
