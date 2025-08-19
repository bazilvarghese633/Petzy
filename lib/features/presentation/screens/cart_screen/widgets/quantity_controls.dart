import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/bloc/cart_bloc.dart';
import 'package:petzy/features/presentation/bloc/cart_event.dart';

class QuantityControls extends StatelessWidget {
  final dynamic item;
  final int? maxStock; // Add this parameter to pass stock from parent

  const QuantityControls({
    super.key,
    required this.item,
    this.maxStock, // Pass stock from parent widget
  });

  @override
  Widget build(BuildContext context) {
    // Use maxStock parameter instead of trying to get it from item
    final int availableStock =
        maxStock ?? 999; // Default to 999 if no stock provided
    final bool canIncrease = item.quantity < availableStock;

    return Container(
      decoration: BoxDecoration(
        color: grey100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: grey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuantityButton(
            icon: Icons.remove,
            onPressed:
                item.quantity > 1
                    ? () {
                      context.read<CartBloc>().add(
                        UpdateCartItemQuantity(item.id, item.quantity - 1),
                      );
                    }
                    : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              '${item.quantity}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: secondaryColor,
              ),
            ),
          ),
          QuantityButton(
            icon: Icons.add,
            onPressed:
                canIncrease
                    ? () {
                      context.read<CartBloc>().add(
                        UpdateCartItemQuantity(item.id, item.quantity + 1),
                      );
                    }
                    : null,
          ),
        ],
      ),
    );
  }
}

class QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const QuantityButton({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 16,
          color: onPressed != null ? primaryColor : grey300,
        ),
      ),
    );
  }
}
