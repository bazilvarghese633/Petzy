import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/presentation/bloc/cart_bloc.dart';
import 'package:petzy/features/presentation/bloc/cart_state.dart';
import 'package:petzy/features/presentation/bloc/checkout_bloc.dart';
import 'checkout_widgets.dart';

class CheckoutBody extends StatelessWidget {
  const CheckoutBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        if (cartState is! CartLoaded || cartState.items.isEmpty) {
          return const Center(child: Text('No items in cart'));
        }

        return BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, checkoutState) {
            return Column(
              children: [
                Expanded(child: CheckoutOrderSummary(cartState: cartState)),
                CheckoutPaymentButton(
                  checkoutState: checkoutState,
                  cartState: cartState,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
