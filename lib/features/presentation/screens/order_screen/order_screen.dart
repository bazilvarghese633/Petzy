import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/screens/home_screen/widgets/custom_navbar.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Center(
          child: const Text(
            "My Orders",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: whiteColor,
        foregroundColor: brownColr,
      ),
      body: const Center(child: Text("Your orders will appear here.")),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1, onTap: (_) {}),
    );
  }
}
