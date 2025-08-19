import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/bloc/cart_state.dart';
import 'package:petzy/features/presentation/bloc/checkout_bloc.dart';

class CheckoutOrderSummary extends StatelessWidget {
  final CartLoaded cartState;

  const CheckoutOrderSummary({super.key, required this.cartState});

  @override
  Widget build(BuildContext context) {
    final grandTotal = cartState.items.fold<double>(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Items list
          ...cartState.items.map((item) => CheckoutOrderItem(item: item)),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              Text(
                '₹${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CheckoutOrderItem extends StatelessWidget {
  final dynamic item;

  const CheckoutOrderItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Text(
                  '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutPaymentButton extends StatelessWidget {
  final CheckoutState checkoutState;
  final CartLoaded cartState;

  const CheckoutPaymentButton({
    super.key,
    required this.checkoutState,
    required this.cartState,
  });

  @override
  Widget build(BuildContext context) {
    final grandTotal = cartState.items.fold<double>(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              checkoutState is CheckoutProcessing
                  ? null
                  : () {
                    context.read<CheckoutBloc>().add(const StartCheckout());
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: whiteColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:
              checkoutState is CheckoutProcessing
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: whiteColor,
                      strokeWidth: 2,
                    ),
                  )
                  : Text(
                    'Pay ₹${grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
    );
  }
}
