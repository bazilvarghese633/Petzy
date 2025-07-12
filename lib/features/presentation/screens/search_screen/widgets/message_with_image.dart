import 'package:flutter/material.dart';

class MessageWithImage extends StatelessWidget {
  final String imagePath;
  final String message;
  final Color color;

  const MessageWithImage({
    super.key,
    required this.imagePath,
    required this.message,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 180,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder:
                  (_, __, ___) => const Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
