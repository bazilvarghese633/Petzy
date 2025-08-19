import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';
import 'package:shimmer/shimmer.dart';

class ProductShimmerCard extends StatelessWidget {
  const ProductShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: grey300,
      highlightColor: grey100,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            sizedBoxH6,

            // Name placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(height: 12, width: 80, color: whiteColor),
            ),
            const SizedBox(height: 4),

            // Description placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(height: 10, width: 100, color: whiteColor),
            ),
            const Spacer(),

            // Unit and price placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 20, width: 50, color: whiteColor),
                  Container(height: 20, width: 40, color: whiteColor),
                ],
              ),
            ),
            sizedBoxH8,

            // Add to cart button placeholder
            Container(
              height: 40,
              decoration: const BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
