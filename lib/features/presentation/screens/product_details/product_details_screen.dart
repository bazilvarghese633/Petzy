import 'dart:async';
import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (widget.product.imageUrls.length <= 1) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= widget.product.imageUrls.length) {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(product.name),
        elevation: 1,
        backgroundColor: whiteColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image Carousel
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: product.imageUrls.length,
                    onPageChanged:
                        (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final url = product.imageUrls[index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: const EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: InteractiveViewer(
                                      panEnabled: true,
                                      minScale: 1,
                                      maxScale: 4,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          url,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (_, __, ___) => const Icon(
                                                Icons.broken_image,
                                                size: 100,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          );
                        },
                        child: Image.network(
                          url,
                          fit: BoxFit.scaleDown,
                          width: double.infinity,
                          errorBuilder:
                              (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image, size: 100),
                              ),
                        ),
                      );
                    },
                  ),
                  // Page Indicator
                  if (product.imageUrls.length > 1)
                    Positioned(
                      bottom: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          product.imageUrls.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 16 : 8,
                            decoration: BoxDecoration(
                              color:
                                  _currentPage == index
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
          ),
          const SizedBox(height: 20),

          // Product Name
          Text(
            product.name,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Price
          Text(
            "₹${product.price}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          if (product.description != null)
            Text(
              product.description!,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          const SizedBox(height: 12),

          // Stock
          Text(
            "Available: ${product.quantity} ${product.unit.replaceFirst('per ', '')}",

            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Add to Cart Button
          ElevatedButton.icon(
            onPressed: () {
              // Add to cart logic here
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text("Add to Cart"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9900),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
