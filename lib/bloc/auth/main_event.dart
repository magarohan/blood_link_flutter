import 'package:blood_link/data/models/user_model.dart';

abstract class MainEvent {}

class AuthCheckRequested extends MainEvent {}

class LoginRequested extends MainEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});
}

class LogoutRequested extends MainEvent {}

class AdminLoggedIn extends MainEvent {
  final String email;
  final String password;
  AdminLoggedIn({required this.email, required this.password});
}

class DonorLoggedIn extends MainEvent {
  final String email;
  final String password;
  DonorLoggedIn({required this.email, required this.password});
}

class BloodBankLoggedIn extends MainEvent {
  final String email;
  final String password;
  BloodBankLoggedIn({required this.email, required this.password});
}

class DonorRegistered extends MainEvent {
  final UserModel donor;
  DonorRegistered({required this.donor});
}

class DonorsFetched extends MainEvent {
  final String id;
  final UserModel model;
  DonorsFetched({required this.id, required this.model});
}

class DonorDeleted extends MainEvent {
  final String id;
  DonorDeleted({required this.id});
}

class DonorUpdated extends MainEvent {
  late final String id;
  final UserModel model;
  DonorUpdated({required this.id, required this.model});
}
