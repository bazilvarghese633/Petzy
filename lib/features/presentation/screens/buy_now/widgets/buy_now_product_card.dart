import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';

class BuyNowProductCard extends StatelessWidget {
  final ProductEntity product;

  const BuyNowProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: whiteColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: grey200,
                      child: const Icon(Icons.broken_image, color: greyColor),
                    ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (product.description != null)
                    Text(
                      product.description!,
                      style: TextStyle(fontSize: 14, color: grey600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${product.price.toStringAsFixed(2)}',
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
      ),
    );
  }
}
