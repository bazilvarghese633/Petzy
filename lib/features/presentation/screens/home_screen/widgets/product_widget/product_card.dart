import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/cart_item.dart';
import 'package:petzy/features/domain/entity/fevorite.dart';
import 'package:petzy/features/presentation/bloc/cart_bloc.dart';
import 'package:petzy/features/presentation/bloc/cart_event.dart';
import 'package:petzy/features/presentation/bloc/cart_state.dart';
import 'package:petzy/features/presentation/bloc/cubit/favorites_cubit.dart';
import 'package:petzy/features/presentation/bloc/product_details.dart';
import 'package:petzy/features/presentation/screens/product_details/product_details_screen.dart';
import 'package:petzy/features/presentation/widgets/dailogbox/cutom_dailog.dart';
import 'package:shimmer/shimmer.dart';

class ProductGridCard extends StatelessWidget {
  final dynamic product;
  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
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
        color: whiteColor,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context),
            const SizedBox(height: 6),
            _buildNameAndDescription(),
            const Spacer(),
            _buildUnitAndPrice(),
            _buildAddToCartButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
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
                baseColor: grey300,
                highlightColor: grey100,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: whiteColor,
                ),
              );
            },
            errorBuilder:
                (_, __, ___) => Container(
                  height: 120,
                  width: double.infinity,
                  color: grey300,
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
            child: Row(
              children: [
                const Icon(Icons.star, size: 14, color: primaryColor),
                const SizedBox(width: 2),
                Text(
                  "${(product.averageRating ?? 0.0).toStringAsFixed(1)}", // 👈 CHANGED: Use actual rating or 0.0
                  style: const TextStyle(fontSize: 12, color: whiteColor),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: BlocBuilder<FavoritesCubit, List<Favorite>>(
            builder: (context, favorites) {
              final isFav = favorites.any((f) => f.productId == product.id);

              return GestureDetector(
                onTap: () {
                  final fav = Favorite(
                    productId: product.id,
                    name: product.name,
                    imageUrl: product.imageUrls.first,
                    price: product.price.toDouble(),
                  );
                  context.read<FavoritesCubit>().toggleFavorite(fav);
                },
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? redColor : whiteColor,
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
              color: secondaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            product.description ?? '',
            style: const TextStyle(fontSize: 12, color: greyColor),
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
              color: grey200,
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
              color: secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    final int stockQuantity = product.quantity ?? 0;
    final bool isOutOfStock = stockQuantity <= 0;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: 40,
      decoration: BoxDecoration(
        color: isOutOfStock ? greyColor.withOpacity(0.6) : colorProduct,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          onTap:
              isOutOfStock
                  ? () {
                    CustomDialog.show(
                      context: context,
                      title: "Out of Stock",
                      message: "This product is currently out of stock.",
                      confirmText: "OK",
                    );
                  }
                  : () async {
                    // NEW: Check current cart before adding
                    final cartBloc = context.read<CartBloc>();
                    final currentState = cartBloc.state;

                    if (currentState is CartLoaded) {
                      // Find if product already exists in cart
                      final existingItem =
                          currentState.items
                              .where((item) => item.id == product.id)
                              .firstOrNull;

                      final currentCartQuantity = existingItem?.quantity ?? 0;

                      // NEW: Check if adding one more would exceed stock
                      if (currentCartQuantity >= stockQuantity) {
                        CustomDialog.show(
                          context: context,
                          title: "Maximum Quantity Reached",
                          message:
                              "You already have the maximum quantity ($stockQuantity) in your cart.",
                          confirmText: "OK",
                        );
                        return; // Don't add to cart
                      }
                    }

                    // Original code - only runs if under stock limit
                    final cartItem = CartItem(
                      id: product.id,
                      name: product.name,
                      price: product.price.toDouble(),
                      quantity: 1,
                      imageUrl: product.imageUrls.first,
                    );

                    cartBloc.add(AddCartItem(cartItem));

                    CustomDialog.show(
                      context: context,
                      title: "Added to Cart",
                      message: "This product has been added to your cart.",
                      confirmText: "OK",
                      onConfirm: () => Navigator.of(context).pop(),
                    );
                  },
          child: Center(
            child:
                isOutOfStock
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.block, color: whiteColor, size: 16),
                        SizedBox(width: 4),
                        Text(
                          "Out of Stock",
                          style: TextStyle(
                            color: whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                    : Icon(Icons.shopping_cart, color: whiteColor),
          ),
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
