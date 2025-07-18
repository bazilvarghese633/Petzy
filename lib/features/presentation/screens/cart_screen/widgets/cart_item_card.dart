import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/repository/product_repository.dart';
import 'package:petzy/features/presentation/bloc/cart_bloc.dart';
import 'package:petzy/features/presentation/bloc/cart_event.dart';
import 'package:petzy/features/presentation/screens/cart_screen/widgets/quantity_controls.dart';
import 'package:petzy/features/presentation/screens/product_details/product_details_screen.dart';
import 'package:petzy/features/presentation/bloc/product_details.dart';

class CartItemCard extends StatelessWidget {
  final dynamic item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final productRepo = RepositoryProvider.of<ProductRepository>(context);
        final product = await productRepo.fetchProductById(item.id);

        if (product != null) {
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
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Product not found')));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: grey300.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ProductImage(imageUrl: item.imageUrl),
            const SizedBox(width: 12),
            Expanded(child: ProductDetails(item: item)),
            DeleteButton(itemId: item.id),
          ],
        ),
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  final String imageUrl;

  const ProductImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: grey200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60,
              height: 60,
              color: grey200,
              child: Icon(Icons.image_not_supported, color: grey600, size: 24),
            );
          },
        ),
      ),
    );
  }
}

class ProductDetails extends StatelessWidget {
  final dynamic item;

  const ProductDetails({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: secondaryColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹${(item.price * item.quantity).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
            QuantityControls(item: item),
          ],
        ),
      ],
    );
  }
}

class DeleteButton extends StatelessWidget {
  final String itemId;

  const DeleteButton({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete_outline, color: redColor, size: 20),
      onPressed: () {
        context.read<CartBloc>().add(RemoveCartItem(itemId));
      },
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
