import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/presentation/bloc/product_details.dart';
import 'package:petzy/features/presentation/screens/product_details/product_details_screen.dart';
import 'package:shimmer/shimmer.dart';

class ProductGridCard extends StatelessWidget {
  final dynamic product;
  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isFav = ValueNotifier(false);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => BlocProvider(
                  create: (_) => ProductDetailBloc(),
                  child: ProductDetailPage(product: product),
                ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(isFav),
            const SizedBox(height: 6),
            _buildNameAndDescription(),
            const Spacer(),
            _buildUnitAndPrice(),
            _buildAddToCartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(ValueNotifier<bool> isFav) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: Image.network(
            product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.white,
                ),
              );
            },
            errorBuilder:
                (_, __, ___) => Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.star, size: 14, color: Colors.orange),
                SizedBox(width: 2),
                Text(
                  "4.5",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: ValueListenableBuilder<bool>(
            valueListenable: isFav,
            builder: (context, value, _) {
              return GestureDetector(
                onTap: () => isFav.value = !value,
                child: Icon(
                  value ? Icons.favorite : Icons.favorite_border,
                  color: value ? Colors.red : Colors.white,
                  size: 20,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNameAndDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF4E2C2C),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            product.description ?? '',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUnitAndPrice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatUnit(product.unit),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Text(
            "₹${product.price}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF4E2C2C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFFF9900),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Center(
        child: IconButton(
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          onPressed: () {},
        ),
      ),
    );
  }

  String _formatUnit(String unit) {
    if (unit.toLowerCase().startsWith('per ')) {
      return '1 ${unit.substring(4)}';
    }
    return '1 $unit';
  }
}
