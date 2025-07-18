import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/cart_item.dart';
import 'package:petzy/features/presentation/bloc/cart_bloc.dart';
import 'package:petzy/features/presentation/bloc/cart_event.dart';
import 'package:petzy/features/presentation/widgets/cutom_dailog.dart';

class ProductActionButtons extends StatelessWidget {
  final dynamic product; // Replace `dynamic` with your actual product type

  const ProductActionButtons({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              final cartItem = CartItem(
                id: product.id,
                name: product.name,
                price: product.price.toDouble(),
                quantity: 1,
                imageUrl: product.imageUrls.first,
              );

              context.read<CartBloc>().add(AddCartItem(cartItem));

              CustomDialog.show(
                context: context,
                title: "Added to Cart",
                message: "This product has been added to your cart.",
                confirmText: "OK",
                onConfirm: () => Navigator.of(context).pop(),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.orange),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Add to Cart",
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement Buy Now logic if needed
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Buy Now", style: TextStyle(color: whiteColor)),
          ),
        ),
      ],
    );
  }
}
