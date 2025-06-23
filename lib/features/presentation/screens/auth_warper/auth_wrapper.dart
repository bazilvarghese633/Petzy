import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/presentation/bloc/auth_bloc.dart';
import 'package:petzy/features/presentation/bloc/auth_state.dart';
import 'package:petzy/features/presentation/screens/home_screen/home_screen.dart';
import 'package:petzy/features/presentation/screens/welcome_screen/welcome_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is Authenticated) {
          return HomePage();
        } else {
          return WelcomePage();
        }
      },
    );
  }
}
