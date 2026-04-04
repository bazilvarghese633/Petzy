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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: secondaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Items list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              ...cartState.items.map((item) => CheckoutOrderItem(item: item)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
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
        ),
      ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
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
                        checkoutState.paymentMethod == 'cod' 
                          ? 'Place Order (COD) - ₹${grandTotal.toStringAsFixed(2)}'
                          : 'Pay ₹${grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodSelection extends StatelessWidget {
  final CheckoutState state;

  const PaymentMethodSelection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: secondaryColor,
            ),
          ),
        ),
        _buildMethodTile(
          context,
          id: 'razorpay',
          title: 'Razorpay',
          subtitle: 'Cards, UPI, NetBanking',
          icon: Icons.payment,
        ),
        _buildMethodTile(
          context,
          id: 'wallet',
          title: 'Petzy Wallet',
          subtitle: 'Balance: ₹${state.walletBalance.toStringAsFixed(2)}',
          icon: Icons.account_balance_wallet_outlined,
          isLoading: state is CheckoutLoadingWallet,
        ),
        _buildMethodTile(
          context,
          id: 'cod',
          title: 'Cash on Delivery',
          subtitle: 'Pay when you receive',
          icon: Icons.local_shipping_outlined,
        ),
      ],
    );
  }

  Widget _buildMethodTile(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    bool isLoading = false,
  }) {
    final isSelected = state.paymentMethod == id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: id,
        groupValue: state.paymentMethod,
        onChanged: (value) {
          if (value != null) {
            context.read<CheckoutBloc>().add(ChangePaymentMethod(value));
          }
        },
        activeColor: primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        title: Row(
          children: [
            Icon(icon, color: isSelected ? primaryColor : secondaryColor),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: secondaryColor,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Row(
            children: [
              Text(
                subtitle,
                style: TextStyle(
                  color: isSelected ? primaryColor.withOpacity(0.8) : Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: SizedBox(
                    height: 12,
                    width: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
