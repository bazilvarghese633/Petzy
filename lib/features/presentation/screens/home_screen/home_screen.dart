import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/core/colors.dart';

import 'package:petzy/features/presentation/bloc/product_bloc.dart';
import 'package:petzy/features/presentation/bloc/product_event.dart';
import 'package:petzy/features/presentation/bloc/product_state.dart';
import 'package:petzy/features/presentation/bloc/categories_bloc.dart';
import 'package:petzy/features/presentation/screens/log_in_screen/log_in_screen.dart';
import 'package:petzy/features/presentation/screens/product_details/product_details_screen.dart';
import 'package:petzy/features/presentation/screens/product_details/product_search.dart';
import 'package:petzy/features/presentation/screens/profile_screen/profile_screen.dart';
import 'package:petzy/features/presentation/screens/welcome_screen/welcome_screen.dart';

import 'package:petzy/features/domain/entity/product_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProducts());
    context.read<CategoriesBloc>().add(LoadCategories());
  }

  void _onCategorySelected(String category) {
    context.read<CategoriesBloc>().add(SelectCategory(category));
    context.read<ProductBloc>().add(FilterByCategory(category));
  }

  void _onSearch(String query) {
    context.read<ProductBloc>().add(SearchProducts(query));
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                        content: const Text(
                          'Are you sure you want to sign out?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _auth.signOut();
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
      ),
      body: Column(
        children: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        ),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child:
                          user.photoURL != null
                              ? ClipOval(
                                child: Image.network(
                                  user.photoURL!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back!',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        user.displayName ?? user.email ?? 'User',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Dynamic Category Chips
          BlocBuilder<CategoriesBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoriesLoading) {
                return const SizedBox(
                  height: 60,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is CategoriesLoaded) {
                return Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        ['All', ...state.all].map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category),
                              backgroundColor: whiteColor,
                              selected: state.selected == category,
                              side: BorderSide(
                                color: primaryColor, // Border color from theme
                                width: 1.5,
                              ),
                              selectedColor: const Color(0xFFFF9900),
                              onSelected: (_) => _onCategorySelected(category),
                            ),
                          );
                        }).toList(),
                  ),
                );
              } else if (state is CategoriesError) {
                return Center(child: Text(state.message));
              } else {
                return const SizedBox(height: 60);
              }
            },
          ),

          const SizedBox(height: 10),

          // Product Grid
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductLoaded) {
                  final products = state.filteredProducts;

                  if (products.isEmpty) {
                    return const Center(child: Text('No products found.'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ProductDetailPage(product: product),
                            ),
                          );
                        },
                        child: Card(
                          color: whiteColor,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product.imageUrls.isNotEmpty
                                          ? product.imageUrls.first
                                          : '',
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) =>
                                              const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  product.description ?? '',
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "₹${product.price.toString()}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is ProductError) {
                  return Center(child: Text(state.message));
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // REQUIRED for color to work
        backgroundColor: Colors.white,
        currentIndex: 0,
        selectedItemColor: const Color(0xFFFF9900),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shops'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 3 && user == null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
          // Handle other nav items if needed
        },
      ),
    );
  }
}
