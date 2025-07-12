import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterFormState {
  final bool isLoading;
  final bool obscureText;

  RegisterFormState({this.isLoading = false, this.obscureText = true});

  RegisterFormState copyWith({bool? isLoading, bool? obscureText}) {
    return RegisterFormState(
      isLoading: isLoading ?? this.isLoading,
      obscureText: obscureText ?? this.obscureText,
    );
  }
}

class RegisterFormCubit extends Cubit<RegisterFormState> {
  RegisterFormCubit() : super(RegisterFormState());

  void setLoading(bool value) {
    emit(state.copyWith(isLoading: value));
  }

  void toggleObscureText() {
    emit(state.copyWith(obscureText: !state.obscureText));
  }
}
