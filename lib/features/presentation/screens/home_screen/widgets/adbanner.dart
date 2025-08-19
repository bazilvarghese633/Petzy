import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:petzy/features/presentation/bloc/product_bloc.dart';
import 'package:petzy/features/presentation/bloc/product_state.dart';

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController bannerController = PageController(
      viewportFraction: 0.9,
    );

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoaded && state.products.isNotEmpty) {
          final adProducts = state.products.take(5).toList();

          return Column(
            children: [
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: bannerController,
                  itemCount: adProducts.length,
                  itemBuilder: (context, index) {
                    final product = adProducts[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              product.imageUrls.isNotEmpty
                                  ? product.imageUrls.first
                                  : '',
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Shimmer.fromColors(
                                  baseColor: grey300,
                                  highlightColor: grey100,
                                  child: Container(color: greyColor),
                                );
                              },
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    color: grey300,
                                    child: const Center(
                                      child: Icon(Icons.broken_image),
                                    ),
                                  ),
                            ),
                            Positioned(
                              left: 16,
                              top: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Limited Offer',
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              bottom: 16,
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  color: whiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 6,
                                      color: blackColor,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              sizedBoxH8,
              SmoothPageIndicator(
                controller: bannerController,
                count: adProducts.length,
                effect: const ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 6,
                  activeDotColor: primaryColor,
                  dotColor: Color.fromARGB(239, 212, 208, 208),
                ),
              ),
            ],
          );
        }

        // 🔄 SHIMMER LOADING (if loading or fallback)
        return Column(
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: bannerController,
                itemCount: 3, // Show 3 shimmer banners
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Shimmer.fromColors(
                      baseColor: grey300,
                      highlightColor: grey100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: greyColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SmoothPageIndicator(
              controller: bannerController,
              count: 3,
              effect: const ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                spacing: 6,
                activeDotColor: primaryColor,
                dotColor: Color.fromARGB(239, 212, 208, 208),
              ),
            ),
          ],
        );
      },
    );
  }
}
