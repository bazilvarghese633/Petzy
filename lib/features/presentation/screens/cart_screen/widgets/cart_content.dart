import 'package:flutter/material.dart';
import 'package:petzy/features/presentation/bloc/cart_state.dart';
import 'package:petzy/features/presentation/screens/cart_screen/widgets/cart_item_card.dart';
import 'package:petzy/features/presentation/screens/cart_screen/widgets/cart_summery.dart';

class CartContent extends StatelessWidget {
  final CartLoaded state;

  const CartContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              return CartItemCard(item: state.items[index]);
            },
          ),
        ),
        CartSummary(state: state),
      ],
    );
  }
}
