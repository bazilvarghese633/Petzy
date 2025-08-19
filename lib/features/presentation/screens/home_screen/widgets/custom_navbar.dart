import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/screens/category_screen/category_screen.dart';
import 'package:petzy/features/presentation/screens/home_screen/home_screen.dart';
import 'package:petzy/features/presentation/screens/log_in_screen/log_in_screen.dart';
import 'package:petzy/features/presentation/screens/order_screen/order_screen.dart';
import 'package:petzy/features/presentation/screens/settings_screen/settings_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // Your existing navigation logic - UNCHANGED
  void _navigateTo(BuildContext context, int index) {
    if (index == currentIndex) return;

    final user = FirebaseAuth.instance.currentUser;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CategoryScreen()),
        );
        break;
      case 3:
        if (user == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: primaryColor.withOpacity(0.1),
            hoverColor: primaryColor.withOpacity(0.1),
            gap: 8,
            activeColor: primaryColor,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            // The duration property directly controls the smoothness of the text "coming in"
            // along with other animations.
            duration: const Duration(
              milliseconds: 800,
            ), // Keep or adjust this value
            tabBackgroundColor: primaryColor.withOpacity(0.1),
            color: greyColor,
            tabs: const [
              GButton(icon: Icons.home_outlined, text: 'Home'),
              GButton(icon: Icons.receipt_long_outlined, text: 'My Orders'),
              GButton(icon: Icons.category_outlined, text: 'Category'),
              GButton(icon: Icons.settings_outlined, text: 'Settings'),
            ],
            selectedIndex: currentIndex,
            onTabChange: (index) => _navigateTo(context, index),
          ),
        ),
      ),
    );
  }
}
