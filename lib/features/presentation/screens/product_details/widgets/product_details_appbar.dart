import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/fevorite.dart';
import 'package:petzy/features/presentation/bloc/cart_state.dart';
import 'package:petzy/features/presentation/bloc/cubit/favorites_cubit.dart';
import 'package:petzy/features/presentation/bloc/cart_bloc.dart';
import 'package:petzy/features/presentation/screens/cart_screen/cart_screen.dart';

class ProductAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onCartPressed;
  final dynamic product; // Replace with your actual Product model

  const ProductAppBar({super.key, required this.product, this.onCartPressed});

  @override
  Widget build(BuildContext context) {
    final isFavorited = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.isFavorited(product.id),
    );

    final favorite = Favorite(
      productId: product.id,
      name: product.name,
      imageUrl: product.imageUrls.first,
      price: product.price.toDouble(),
    );

    return AppBar(
      backgroundColor: whiteColor,
      elevation: 1,
      leading: BackButton(color: brownColr),
      centerTitle: true,
      title: const Text('Product Details', style: TextStyle(color: brownColr)),
      actions: [
        IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? redColor : brownColr,
          ),
          onPressed: () {
            context.read<FavoritesCubit>().toggleFavorite(favorite);
          },
        ),
        BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            int count = 0;
            if (state is CartLoaded) {
              count =
                  state.totalItems; // or use state.items.length for item types
            }

            return Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: brownColr,
                  ),
                  onPressed:
                      onCartPressed ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                ),
                if (count > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: primaryColor,
                      child: Text(
                        "$count",
                        style: const TextStyle(fontSize: 10, color: whiteColor),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
