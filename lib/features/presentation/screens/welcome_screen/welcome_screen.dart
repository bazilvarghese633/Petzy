import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';
import 'package:petzy/features/presentation/screens/home_screen/home_screen.dart';

import 'package:petzy/features/presentation/screens/log_in_screen/log_in_screen.dart';
import 'package:petzy/features/presentation/screens/sign_in_screen/sign_up_screen.dart';
import 'package:petzy/features/presentation/screens/welcome_screen/widgets/welcome_screen_widgests.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppTitle(),
              sizedBoxH32,
              const PetImage(),
              sizedBoxH40,
              CustomElevatedButton(
                text: 'Sign Up',
                textColor: primaryColor,
                backgroundColor: whiteColor,
                sideColor: whiteColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
              ),
              sizedBoxH16,
              CustomElevatedButton(
                text: 'Log In',
                textColor: whiteColor,
                backgroundColor: primaryColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
              sizedBoxH16,
              SkipButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
