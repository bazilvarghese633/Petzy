import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/presentation/screens/log_in_screen/log_in_screen.dart';
import 'package:petzy/features/presentation/screens/search_screen/product_search.dart';
import 'package:petzy/features/presentation/screens/welcome_screen/welcome_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user;
  final FirebaseAuth auth;

  const HomeAppBar({super.key, required this.user, required this.auth});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Home'),
      backgroundColor: Colors.white,
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
          icon: const Icon(Icons.shopping_cart),
          onPressed: () {
            if (user == null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            } else {
              // Navigate to cart
            }
          },
        ),
        IconButton(
          icon: Icon(user != null ? Icons.logout : Icons.login),
          onPressed: () {
            if (user != null) {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await auth.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WelcomePage(),
                              ),
                            );
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
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
