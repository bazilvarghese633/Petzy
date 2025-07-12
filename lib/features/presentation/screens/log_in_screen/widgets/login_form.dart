// login_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';
import 'package:petzy/features/presentation/bloc/auth_bloc.dart';
import 'package:petzy/features/presentation/bloc/auth_event.dart';
import 'package:petzy/features/presentation/bloc/auth_state.dart';
import 'package:petzy/features/presentation/bloc/cubit/login_form_cubit.dart';
import 'package:petzy/features/presentation/bloc/cubit/login_form_state.dart';
import 'package:petzy/features/presentation/screens/home_screen/home_screen.dart';

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submitLogin(BuildContext context) {
    final formCubit = context.read<LoginFormCubit>();

    if (_formKey.currentState!.validate()) {
      formCubit.clearErrors();
      formCubit.setLoading(true);

      context.read<AuthBloc>().add(
        LoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginFormCubit(),
      child: BlocConsumer<LoginFormCubit, LoginFormState>(
        listener: (context, formState) {
          final authState = context.read<AuthBloc>().state;

          if (authState is AuthError) {
            final msg = authState.message.toLowerCase();
            final cubit = context.read<LoginFormCubit>();

            if (msg.contains('user-not-found')) {
              cubit.setError(emailError: 'This email is not registered.');
            } else if (msg.contains('wrong-password')) {
              cubit.setError(passwordError: 'Incorrect password.');
            } else if (msg.contains('invalid-email')) {
              cubit.setError(emailError: 'Invalid email format.');
            } else {
              cubit.setError(generalError: 'Login failed. Please try again.');
            }

            cubit.setLoading(false);
          }

          if (authState is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        },
        builder: (context, formState) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: formState.emailError,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.email, color: greyColor),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                sizedBoxH20,

                TextFormField(
                  controller: _passwordController,
                  obscureText: formState.obscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: formState.passwordError,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.lock, color: greyColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        formState.obscureText
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: greyColor,
                      ),
                      onPressed: () {
                        context.read<LoginFormCubit>().toggleObscureText();
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                sizedBoxH8,

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ),
                sizedBoxH20,

                if (formState.generalError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      formState.generalError!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        formState.isLoading
                            ? null
                            : () => _submitLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        formState.isLoading
                            ? const CircularProgressIndicator(color: whiteColor)
                            : const Text(
                              'SIGN IN',
                              style: TextStyle(
                                color: whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
