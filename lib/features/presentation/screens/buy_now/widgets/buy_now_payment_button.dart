import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';

class BuyNowPaymentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double totalAmount;

  const BuyNowPaymentButton({
    super.key,
    required this.onPressed,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: whiteColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          'Pay ₹${totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
