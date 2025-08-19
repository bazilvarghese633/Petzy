import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/repository/product_repository.dart';
import 'package:petzy/features/presentation/bloc/cart_bloc.dart';
import 'package:petzy/features/presentation/bloc/cart_event.dart';
import 'package:petzy/features/presentation/screens/cart_screen/widgets/quantity_controls.dart';
import 'package:petzy/features/presentation/screens/product_details/product_details_screen.dart';
import 'package:petzy/features/presentation/bloc/product_details.dart';
import 'package:petzy/features/presentation/widgets/dailogbox/cutom_dailog.dart';

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

  Future<int?> _getProductStock(BuildContext context) async {
    final productRepo = RepositoryProvider.of<ProductRepository>(context);
    final product = await productRepo.fetchProductById(item.id);
    return product?.quantity;
  }

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
            Expanded(
              child: Text(
                '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FutureBuilder<int?>(
              future: _getProductStock(context),
              builder: (context, snapshot) {
                return QuantityControls(
                  item: item,
                  maxStock:
                      snapshot
                          .data, // Will be null initially, then update with actual stock
                );
              },
            ),
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
      onPressed: () => _showDeleteConfirmation(context),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    CustomDialog.show(
      context: context,
      title: 'Remove from Cart',
      message: 'Are you sure you want to delete this product from cart?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
      onConfirm: () {
        Navigator.of(context).pop();
        context.read<CartBloc>().add(RemoveCartItem(itemId));
      },
    );
  }
}
