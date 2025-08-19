import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/screens/cart_screen/cart_screen.dart';
import 'package:petzy/features/presentation/screens/fevorites_screen/fevorites_screen.dart';
import 'package:petzy/features/presentation/screens/log_in_screen/log_in_screen.dart';
import 'package:petzy/features/presentation/screens/search_screen/product_search.dart';
import 'package:petzy/features/presentation/screens/welcome_screen/welcome_screen.dart';
import 'package:petzy/features/presentation/widgets/dailogbox/cutom_dailog.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user;
  final FirebaseAuth auth;

  const HomeAppBar({super.key, required this.user, required this.auth});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Home'),
      backgroundColor: whiteColor,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            final user = FirebaseAuth.instance.currentUser;

            if (user == null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FavoritesPage()),
              );
            }
          },
        ),

        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () {
            final user = FirebaseAuth.instance.currentUser;

            if (user == null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartScreen()),
              );
            }
          },
        ),
        IconButton(
          icon: Icon(user != null ? Icons.logout : Icons.login),
          onPressed: () {
            if (user != null) {
              CustomDialog.show(
                context: context,
                title: 'Confirm Logout',
                message: 'Are you sure you want to sign out?',
                confirmText: 'Logout',
                cancelText: 'Cancel',
                isDestructive: true,
                onConfirm: () async {
                  Navigator.of(context).pop();
                  await auth.signOut();
                  Navigator.pushReplacement(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomePage()),
                  );
                },
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
