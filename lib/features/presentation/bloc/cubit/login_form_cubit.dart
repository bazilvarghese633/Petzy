// login_form_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_form_state.dart';

class LoginFormCubit extends Cubit<LoginFormState> {
  LoginFormCubit() : super(LoginFormState());

  void toggleObscureText() {
    emit(state.copyWith(obscureText: !state.obscureText));
  }

  void setLoading(bool loading) {
    emit(state.copyWith(isLoading: loading));
  }

  void setError({
    String? emailError,
    String? passwordError,
    String? generalError,
  }) {
    emit(
      state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
        generalError: generalError,
      ),
    );
  }

  void clearErrors() {
    emit(
      state.copyWith(emailError: null, passwordError: null, generalError: null),
    );
  }
}
