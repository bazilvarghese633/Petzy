import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';
import 'package:petzy/features/presentation/bloc/auth_bloc.dart';
import 'package:petzy/features/presentation/bloc/auth_event.dart';
import 'package:petzy/features/presentation/bloc/auth_state.dart';
import 'package:petzy/features/presentation/bloc/cubit/register_screeen_cubit.dart';
import 'package:petzy/features/presentation/screens/home_screen/home_screen.dart';
import 'form_fields.dart';
import 'form_buttons.dart';

class RegisterForm extends StatelessWidget {
  RegisterForm({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  void _handleSignUp(BuildContext context) {
    final cubit = context.read<RegisterFormCubit>();

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    cubit.setLoading(true);

    context.read<AuthBloc>().add(
      RegisterEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            final cubit = context.read<RegisterFormCubit>();
            if (state is AuthError) {
              cubit.setLoading(false);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is Authenticated) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<RegisterFormCubit, RegisterFormState>(
        builder: (context, formState) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sizedBoxH4,
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: brownColr,
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// Username, Email, Password Fields
                  RegisterFormFields(
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    obscureText: formState.obscureText,
                  ),
                  const SizedBox(height: 24),

                  /// Sign Up, Google, Navigation buttons
                  RegisterFormButtons(
                    isLoading: formState.isLoading,
                    onSignUp: () => _handleSignUp(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
