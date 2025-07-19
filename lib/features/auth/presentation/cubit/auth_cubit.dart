import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/auth/domain/use_cases/sign_out.dart';
import 'package:urs_beauty/features/auth/domain/use_cases/sign_up.dart';
import 'package:urs_beauty/features/auth/domain/use_cases/sing_in.dart';
import 'package:urs_beauty/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;

  AuthCubit({
    required SignIn signIn,
    required SignUp signUp,
    required SignOut signOut,
  })  : _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        super(AuthState.initial());

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _signIn.execute(email, password);
      emit(state.copyWith(status: AuthStatus.authenticated));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _signUp.execute(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      emit(state.copyWith(status: AuthStatus.authenticated));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _signOut.execute();
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}