import 'package:flutter/material.dart';

class ProductAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onCartPressed;

  const ProductAppBar({Key? key, this.onCartPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: BackButton(color: Colors.brown.shade800),
      centerTitle: true,
      title: const Text(
        'Product Details',
        style: TextStyle(color: Colors.brown),
      ),
      actions: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.deepOrange,
              ),
              onPressed: onCartPressed ?? () {},
            ),
            const Positioned(
              right: 6,
              top: 6,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.deepOrange,
                child: Text(
                  "5",
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
