import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';

class BuyNowQuantitySelector extends StatelessWidget {
  final ProductEntity product;
  final int quantity;
  final Function(int) onQuantityChanged;

  const BuyNowQuantitySelector({
    super.key,
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: whiteColor,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quantity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed:
                          quantity > 1
                              ? () => onQuantityChanged(quantity - 1)
                              : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: primaryColor,
                      disabledColor: greyColor,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          quantity < product.quantity
                              ? () => onQuantityChanged(quantity + 1)
                              : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: primaryColor,
                      disabledColor: greyColor,
                    ),
                  ],
                ),
                Text(
                  'Stock: ${product.quantity}',
                  style: TextStyle(fontSize: 14, color: grey600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
