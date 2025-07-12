// login_form_state.dart
class LoginFormState {
  final bool isLoading;
  final bool obscureText;
  final String? emailError;
  final String? passwordError;
  final String? generalError;

  LoginFormState({
    this.isLoading = false,
    this.obscureText = true,
    this.emailError,
    this.passwordError,
    this.generalError,
  });

  LoginFormState copyWith({
    bool? isLoading,
    bool? obscureText,
    String? emailError,
    String? passwordError,
    String? generalError,
  }) {
    return LoginFormState(
      isLoading: isLoading ?? this.isLoading,
      obscureText: obscureText ?? this.obscureText,
      emailError: emailError,
      passwordError: passwordError,
      generalError: generalError,
    );
  }
}
