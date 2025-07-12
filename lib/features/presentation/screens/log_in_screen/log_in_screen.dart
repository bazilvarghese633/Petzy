import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';
import 'package:petzy/features/presentation/bloc/auth_bloc.dart';
import 'package:petzy/features/presentation/bloc/auth_state.dart';
import 'package:petzy/features/presentation/screens/home_screen/home_screen.dart';
import 'package:petzy/features/presentation/screens/log_in_screen/widgets/google_signin_button.dart';
import 'package:petzy/features/presentation/screens/log_in_screen/widgets/login_app_bar.dart';
import 'package:petzy/features/presentation/screens/log_in_screen/widgets/login_form.dart';
import 'package:petzy/features/presentation/screens/log_in_screen/widgets/sign_up_prompt.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: const LoginAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sizedBoxH20,
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: brownColr,
                  ),
                ),
                sizedBoxH8,
                Text(
                  'Sign in to continue',
                  style: TextStyle(fontSize: 16, color: greyColor),
                ),
                sizedBoxH40,
                LoginForm(),
                sizedBoxH30,
                GoogleSignInButton(),
                sizedBoxH30,
                SignUpPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
