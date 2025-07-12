import 'package:flutter/material.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';

class ProductStockAndCategory extends StatelessWidget {
  final ProductEntity product;

  const ProductStockAndCategory({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              product.quantity > 0 ? "In stock" : "Out of stock",
              style: TextStyle(
                color: product.quantity > 0 ? Colors.orange : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Category:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(product.category),
          ],
        ),
      ],
    );
  }
}
