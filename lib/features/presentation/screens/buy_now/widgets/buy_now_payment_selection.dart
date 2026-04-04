import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/bloc/buy_now_bloc.dart';
import 'package:petzy/features/presentation/bloc/buy_now_event.dart';
import 'package:petzy/features/presentation/bloc/buy_now_state.dart';

class BuyNowPaymentSelection extends StatelessWidget {
  final BuyNowState state;

  const BuyNowPaymentSelection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
          isLoading: state is BuyNowLoadingWallet,
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
      margin: const EdgeInsets.symmetric(vertical: 6),
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
            context.read<BuyNowBloc>().add(ChangePaymentMethod(value));
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
