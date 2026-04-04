import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';

import 'package:petzy/features/presentation/bloc/buy_now_state.dart';

class BuyNowPaymentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final BuyNowState state;

  const BuyNowPaymentButton({
    super.key,
    required this.onPressed,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the amount from state
    double amount = 0.0;
    if (state is BuyNowLoaded) {
      amount = (state as BuyNowLoaded).totalAmount;
    }

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
          state.paymentMethod == 'cod'
              ? 'Place Order (COD) - ₹${amount.toStringAsFixed(2)}'
              : 'Pay ₹${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
