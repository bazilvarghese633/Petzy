import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/domain/repository/cart_repository.dart';
import 'package:petzy/features/domain/repository/order_repository.dart';
import 'package:petzy/features/domain/repository/product_repository.dart';
import 'package:petzy/features/domain/repository/profile_repository.dart';
import 'package:petzy/features/presentation/screens/checkout_screen/checkout_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/bloc/cart_bloc.dart';
import 'package:petzy/features/presentation/bloc/cart_state.dart';
import 'package:petzy/features/presentation/bloc/checkout_bloc.dart';
import 'package:petzy/features/domain/usecase/create_order.dart';
import 'package:petzy/features/domain/usecase/reduce_product_stock.dart';
import 'package:petzy/features/domain/usecase/update_order_status.dart';
import 'package:petzy/features/domain/usecase/clear_cart.dart';
import 'package:petzy/features/domain/usecase/get_profile.dart';

class CartSummary extends StatelessWidget {
  final CartLoaded state;

  const CartSummary({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: grey300.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.totalItems} items',
                style: TextStyle(fontSize: 16, color: grey600),
              ),
              Text(
                '₹${state.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PlaceOrderButton(
            totalPrice: state.totalPrice,
            onPressed: () => _navigateToCheckout(context),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BlocProvider(
              create:
                  (context) => CheckoutBloc(
                    cartBloc: context.read<CartBloc>(),
                    createOrderUseCase: CreateOrderUseCase(
                      context.read<OrderRepository>(),
                    ),
                    reduceProductStockUseCase: ReduceProductStockUseCase(
                      context.read<ProductRepository>(),
                    ),
                    updateOrderStatusUseCase: UpdateOrderStatusUseCase(
                      context.read<OrderRepository>(),
                    ),
                    clearCartUseCase: ClearCartUseCase(
                      context.read<CartRepository>(),
                    ),
                    getProfileUseCase: GetProfileUseCase(
                      context.read<ProfileRepository>(),
                    ),
                    razorpay: Razorpay(),
                    firebaseAuth: FirebaseAuth.instance,
                  ),
              child: const CheckoutScreen(),
            ),
      ),
    );
  }
}

class PlaceOrderButton extends StatelessWidget {
  final double? totalPrice;
  final VoidCallback? onPressed;
  final String? customText;

  const PlaceOrderButton({
    super.key,
    this.totalPrice,
    this.onPressed,
    this.customText,
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          customText ??
              (totalPrice != null
                  ? 'Place Order - ₹${totalPrice!.toStringAsFixed(2)}'
                  : 'Place Order'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
