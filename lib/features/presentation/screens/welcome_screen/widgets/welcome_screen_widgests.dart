import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'PETZY',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4E342E),
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Your Pets Happy Companion',
          style: TextStyle(fontSize: 16, color: Colors.brown),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class PetImage extends StatelessWidget {
  const PetImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Screenshot_2025-04-01_at_9.52.23_AM-removebg-preview.png',
      height: 250,
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final Color? sideColor;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    this.sideColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side:
              sideColor != null
                  ? BorderSide(color: sideColor!, width: 1)
                  : BorderSide.none,
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SkipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SkipButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: const Text('Skip', style: TextStyle(color: Colors.grey)),
    );
  }
}
