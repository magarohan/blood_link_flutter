import 'package:blood_link/core/constants/enums.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String location;
  final String? bloodType;
  final String? rhFactor;
  final UserType? userType;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.location,
    this.bloodType,
    this.rhFactor,
    this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      bloodType: json['blood_type'],
      rhFactor: json['rh_factor'],
      location: json['location'],
      userType: UserType.values.firstWhere(
        (e) => e.name == json['user_type'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'phone_number': phoneNumber,
      'blood_type': bloodType,
      'rh_factor': rhFactor,
      'location': location,
      'user_type': userType?.name,
    };
  }
}
