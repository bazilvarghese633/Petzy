import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/presentation/bloc/product_details.dart';

class ProductImageCarousel extends StatelessWidget {
  final List<String> imageUrls;
  final PageController pageController;

  const ProductImageCarousel({
    super.key,
    required this.imageUrls,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final currentPage = context.watch<ProductDetailBloc>().state.currentPage;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: pageController,
              itemCount: imageUrls.length,
              onPageChanged:
                  (index) => context.read<ProductDetailBloc>().add(
                    UpdatePageIndex(index),
                  ),
              itemBuilder: (context, index) {
                return Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, size: 100),
                      ),
                );
              },
            ),
            if (imageUrls.length > 1)
              Positioned(
                bottom: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    imageUrls.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: currentPage == index ? 16 : 8,
                      decoration: BoxDecoration(
                        color:
                            currentPage == index
                                ? Colors.orange
                                : Colors.orange.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
