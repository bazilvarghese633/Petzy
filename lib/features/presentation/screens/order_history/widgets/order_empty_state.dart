import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';

class OrderEmptyState extends StatelessWidget {
  const OrderEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: grey300),
          const SizedBox(height: 16),
          Text(
            'No order history found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your past orders will appear here',
            style: TextStyle(fontSize: 14, color: grey600),
          ),
        ],
      ),
    );
  }
}
