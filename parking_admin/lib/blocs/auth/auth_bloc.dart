import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/blocs/auth/auth_event.dart';
import 'package:parking_admin/blocs/auth/auth_state.dart';
import 'package:parking_admin/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await repository.login(event.email, event.password);
      if (success) {
        emit(AuthSuccess());
      } else {
        emit(const AuthFailure('Ogiltig e-postadress eller lösenord.'));
      }
    } catch (e) {
      emit(AuthFailure('Inloggningsfel: $e'));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    await repository.logout();
    emit(AuthInitial());
  }
}