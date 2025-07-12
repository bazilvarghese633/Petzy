import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';
import 'package:petzy/features/presentation/bloc/auth_bloc.dart';
import 'package:petzy/features/presentation/bloc/auth_event.dart';
import 'package:petzy/features/presentation/bloc/cubit/register_screeen_cubit.dart';
import 'package:petzy/features/presentation/screens/home_screen/home_screen.dart';
import 'package:petzy/features/presentation/screens/log_in_screen/log_in_screen.dart';

class RegisterFormButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSignUp;

  const RegisterFormButtons({
    super.key,
    required this.isLoading,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: whiteColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBackgroundColor: grey300,
            ),
            child:
                isLoading
                    ? const CircularProgressIndicator(color: whiteColor)
                    : const Text(
                      "Sign Up",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
          ),
        ),
        sizedBoxH20,
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text("or"),
            ),
            Expanded(child: Divider()),
          ],
        ),
        sizedBoxH16,
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(GoogleSignInEvent());
              context.read<RegisterFormCubit>().setLoading(true);
            },
            icon: const Icon(Icons.g_mobiledata),
            label: const Text("Google"),
            style: ElevatedButton.styleFrom(
              backgroundColor: whiteColor,
              foregroundColor: greyColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              shadowColor: greyColor,
              elevation: 2,
            ),
          ),
        ),
        sizedBoxH16,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already have an account? "),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text(
                "Log In",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        sizedBoxH12,
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
            child: const Text("Skip", style: TextStyle(color: Colors.grey)),
          ),
        ),
        sizedBoxH24,
      ],
    );
  }
}
