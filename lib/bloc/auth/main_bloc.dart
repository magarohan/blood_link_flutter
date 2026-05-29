import 'package:blood_link/bloc/auth/main_event.dart';
import 'package:blood_link/bloc/auth/main_state.dart';
import 'package:blood_link/core/constants/enums.dart';
import 'package:blood_link/repository/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<DonorLoggedIn>(_onDonorLoggedIn);
    on<AdminLoggedIn>(_onAdminLoggedIn);
    on<BloodBankLoggedIn>(_onBloodBankLoggedIn);
    on<DonorsFetched>(_onDonorsFetched);
    on<DonorDeleted>(_onDonorDeleted);
    on<DonorUpdated>(_onDonorUpdated);
  }
  Repository repository = Repository();

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<MainState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final session = await repository.getStoredSession();
      if (session['donorToken'] != null && session['donorToken']!.isNotEmpty) {
        emit(state.copyWith(status: AppStatus.success, userType: 'donor'));
      } else if (session['bloodBankToken'] != null &&
          session['bloodBankToken']!.isNotEmpty) {
        emit(state.copyWith(status: AppStatus.success, userType: 'bloodBank'));
      } else {
        emit(state.copyWith(status: AppStatus.initial));
      }
    } catch (e) {
      emit(state.copyWith(status: AppStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<MainState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final admin = await repository.loginDonor(event.email, event.password);
      if (admin != null) {
        emit(state.copyWith(status: AppStatus.success, userType: 'admin'));
        return;
      }

      final donor = await repository.loginDonor(event.email, event.password);
      if (donor != null) {
        emit(state.copyWith(status: AppStatus.success, userType: 'donor'));
        return;
      }

      final bloodBank =
          await repository.loginBloodBank(event.email, event.password);
      if (bloodBank != null) {
        emit(state.copyWith(status: AppStatus.success, userType: 'bloodBank'));
        return;
      }

      emit(state.copyWith(
          status: AppStatus.failure, error: 'Invalid email or password'));
    } catch (e) {
      emit(state.copyWith(status: AppStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<MainState> emit) async {
    emit(state.copyWith(status: AppStatus.initial, userType: null));
  }

  Future<void> _onDonorLoggedIn(
      DonorLoggedIn event, Emitter<MainState> emit) async {
    emit(state.copyWith(donorLoggedInState: AppStatus.loading));
    try {
      final response = await repository.loginDonor(event.email, event.password);
      emit(state.copyWith(donorLoggedInState: AppStatus.success));
      emit(state.copyWith(donorLoggedInState: AppStatus.completed));
    } catch (e) {
      emit(state.copyWith(donorLoggedInState: AppStatus.failure));
    }
  }

  Future<void> _onAdminLoggedIn(
      AdminLoggedIn event, Emitter<MainState> emit) async {
    emit(state.copyWith(adminLoggedInState: AppStatus.loading));
    try {
      final response = await repository.loginDonor(event.email, event.password);
      emit(state.copyWith(adminLoggedInState: AppStatus.success));
      emit(state.copyWith(adminLoggedInState: AppStatus.completed));
    } catch (e) {
      emit(state.copyWith(adminLoggedInState: AppStatus.failure));
    }
  }

  Future<void> _onBloodBankLoggedIn(
      BloodBankLoggedIn event, Emitter<MainState> emit) async {
    emit(state.copyWith(bloodBankLoggedInState: AppStatus.loading));
    try {
      final response =
          await repository.loginBloodBank(event.email, event.password);
      emit(state.copyWith(bloodBankLoggedInState: AppStatus.success));
      emit(state.copyWith(bloodBankLoggedInState: AppStatus.completed));
    } catch (e) {
      emit(state.copyWith(bloodBankLoggedInState: AppStatus.failure));
    }
  }

  Future<void> _onDonorsFetched(
      DonorsFetched event, Emitter<MainState> emit) async {
    emit(state.copyWith(fetchDonorsState: AppStatus.loading));
    try {
      final response = await repository.fetchDonors();
      emit(state.copyWith(
          fetchDonorsState: AppStatus.success, donors: response));
      emit(state.copyWith(fetchDonorsState: AppStatus.completed));
    } catch (e) {
      emit(state.copyWith(fetchDonorsState: AppStatus.failure));
    }
  }

  Future<void> _onDonorDeleted(
      DonorDeleted event, Emitter<MainState> emit) async {
    emit(state.copyWith(deleteDonorState: AppStatus.loading));
    try {
      await repository.deleteDonor(event.id);
      emit(state.copyWith(deleteDonorState: AppStatus.success));
      emit(state.copyWith(deleteDonorState: AppStatus.completed));
    } catch (e) {
      emit(state.copyWith(deleteDonorState: AppStatus.failure));
    }
  }

  Future<void> _onDonorUpdated(
      DonorUpdated event, Emitter<MainState> emit) async {
    emit(state.copyWith(updateDonorState: AppStatus.loading));
    try {
      await repository.updateDonor(event.id, event.model);
      emit(state.copyWith(updateDonorState: AppStatus.success));
      emit(state.copyWith(updateDonorState: AppStatus.completed));
    } catch (e) {
      emit(state.copyWith(updateDonorState: AppStatus.failure));
    }
  }
}
