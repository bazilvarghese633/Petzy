import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/wallet_entity.dart';
import 'package:petzy/features/domain/repository/wallet_repository.dart';
import 'package:petzy/features/domain/usecase/get_wallet.dart';
import 'package:petzy/features/presentation/bloc/cart_bloc.dart';
import 'package:petzy/features/presentation/bloc/cart_state.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selectedPaymentMethod = 'razorpay';
  WalletEntity? _wallet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final wallet = await GetWalletUseCase(
          context.read<WalletRepository>(),
        ).call(userId);
        setState(() {
          _wallet = wallet;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'Choose Payment Method',
          style: TextStyle(fontWeight: FontWeight.bold, color: brownColr),
        ),
        backgroundColor: whiteColor,
        foregroundColor: appTitleColor,
        centerTitle: true,
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          if (cartState is! CartLoaded) return const SizedBox.shrink();

          final total = cartState.items.fold<double>(
            0.0,
            (sum, item) => sum + (item.price * item.quantity),
          );

          return Column(
            children: [
              Expanded(
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        )
                        : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _buildOrderSummary(total),
                            const SizedBox(height: 24),
                            _buildPaymentMethods(total),
                          ],
                        ),
              ),
              _buildProceedButton(total),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(double total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount'),
                Text(
                  '₹${total.toStringAsFixed(2)}',
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
    );
  }

  Widget _buildPaymentMethods(double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
        const SizedBox(height: 16),

        // Wallet Payment Option
        _buildPaymentOption(
          'wallet',
          'Wallet',
          Icons.wallet,
          _wallet != null
              ? 'Balance: ₹${_wallet!.balance.toStringAsFixed(2)}'
              : 'Loading...',
          _wallet != null && _wallet!.balance >= total,
        ),

        const SizedBox(height: 12),

        // Razorpay Payment Option
        _buildPaymentOption(
          'razorpay',
          'Razorpay',
          Icons.payment,
          'UPI, Cards, NetBanking & More',
          true,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    IconData icon,
    String subtitle,
    bool isEnabled,
  ) {
    return Card(
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged:
            isEnabled
                ? (String? newValue) {
                  setState(() {
                    _selectedPaymentMethod = newValue!;
                  });
                }
                : null,
        title: Row(
          children: [
            Icon(icon, color: isEnabled ? primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isEnabled ? secondaryColor : Colors.grey,
              ),
            ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: isEnabled ? Colors.grey[600] : Colors.grey),
        ),
        activeColor: primaryColor,
      ),
    );
  }

  Widget _buildProceedButton(double total) {
    bool canProceed = true;
    String buttonText = 'Proceed to Pay';

    if (_selectedPaymentMethod == 'wallet') {
      if (_wallet == null) {
        canProceed = false;
        buttonText = 'Loading Wallet...';
      } else if (_wallet!.balance < total) {
        canProceed = false;
        buttonText = 'Insufficient Wallet Balance';
      } else {
        buttonText = 'Pay from Wallet';
      }
    }

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
          onPressed: canProceed ? () => _proceedWithPayment(total) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: whiteColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _proceedWithPayment(double total) {
    // Navigate back with selected payment method
    Navigator.pop(context, {
      'paymentMethod': _selectedPaymentMethod,
      'amount': total,
    });
  }
}
