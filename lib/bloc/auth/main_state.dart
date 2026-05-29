import 'package:blood_link/core/constants/enums.dart';

import '../../data/models/user_model.dart';

class MainState {
  final AppStatus status;
  final String? userType;
  final String? error;

  final AppStatus adminLoggedInState;
  final AppStatus donorLoggedInState;
  final AppStatus bloodBankLoggedInState;

  final AppStatus fetchDonorsState;
  final AppStatus deleteDonorState;
  final AppStatus updateDonorState;
  final AppStatus createDonorState;
  final List<UserModel>? donors;

  MainState(
      {this.status = AppStatus.initial,
      this.userType,
      this.error,
      this.adminLoggedInState = AppStatus.initial,
      this.donorLoggedInState = AppStatus.initial,
      this.bloodBankLoggedInState = AppStatus.initial,
      this.fetchDonorsState = AppStatus.initial,
      this.deleteDonorState = AppStatus.initial,
      this.updateDonorState = AppStatus.initial,
      this.createDonorState = AppStatus.initial,
      this.donors});

  MainState copyWith({
    AppStatus? status,
    String? userType,
    String? error,
    AppStatus? adminLoggedInState,
    AppStatus? donorLoggedInState,
    AppStatus? bloodBankLoggedInState,
    AppStatus? fetchDonorsState,
    AppStatus? createDonorState,
    AppStatus? deleteDonorState,
    AppStatus? updateDonorState,
    List<UserModel>? donors,
  }) {
    return MainState(
      status: status ?? this.status,
      userType: userType ?? this.userType,
      error: error ?? this.error,
      adminLoggedInState: adminLoggedInState ?? this.adminLoggedInState,
      donorLoggedInState: donorLoggedInState ?? this.donorLoggedInState,
      bloodBankLoggedInState:
          bloodBankLoggedInState ?? this.bloodBankLoggedInState,
      fetchDonorsState: fetchDonorsState ?? this.fetchDonorsState,
      deleteDonorState: deleteDonorState ?? this.deleteDonorState,
      updateDonorState: updateDonorState ?? this.updateDonorState,
      createDonorState: createDonorState ?? this.createDonorState,
      donors: donors ?? this.donors,
    );
  }
}
