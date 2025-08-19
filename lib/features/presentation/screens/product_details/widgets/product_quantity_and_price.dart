import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/presentation/bloc/product_details.dart';

class ProductQuantityAndPrice extends StatelessWidget {
  final ProductEntity product;
  final int quantity;

  const ProductQuantityAndPrice({
    super.key,
    required this.product,
    required this.quantity,
  });

  String _getPluralizedUnit(String unit, int quantity) {
    final cleanedUnit = unit.toLowerCase().replaceFirst("per ", "");
    if (quantity == 1) {
      return "1 $cleanedUnit";
    } else {
      return "$quantity ${cleanedUnit}s";
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxQuantity = product.quantity; // Available stock

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed:
                  quantity > 1
                      ? () => context.read<ProductDetailBloc>().add(
                        DecrementQuantity(),
                      )
                      : null,
            ),
            Text('$quantity', style: const TextStyle(fontSize: 18)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed:
                  quantity < maxQuantity
                      ? () => context.read<ProductDetailBloc>().add(
                        IncrementQuantity(),
                      )
                      : null,
            ),
          ],
        ),
        Text(
          _getPluralizedUnit(product.unit, quantity),
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        Text(
          '₹${(product.price * quantity).toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
      ],
    );
  }
}
