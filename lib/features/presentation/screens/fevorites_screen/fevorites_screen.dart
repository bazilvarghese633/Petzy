import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/fevorite.dart';
import 'package:petzy/features/domain/repository/product_repository.dart';
import 'package:petzy/features/presentation/bloc/cubit/favorites_cubit.dart';
import 'package:petzy/features/presentation/bloc/product_details.dart';
import 'package:petzy/features/presentation/screens/product_details/product_details_screen.dart'; // Replace with your actual detail page

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productRepo = RepositoryProvider.of<ProductRepository>(context);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: TextStyle(
            color: brownColr,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: whiteColor),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: redColor),
            onPressed: () {},
          ),
        ],
      ),

      body: BlocBuilder<FavoritesCubit, List<Favorite>>(
        builder: (context, favorites) {
          if (favorites.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              _buildHeader(favorites.length),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final fav = favorites[index];
                    return GestureDetector(
                      onTap: () async {
                        final product = await productRepo.fetchProductById(
                          fav.productId,
                        );
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Product not found')),
                          );
                        }
                      },

                      child: _buildFavoriteTile(context, fav),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: grey100,
        border: Border(bottom: BorderSide(color: grey200, width: 1)),
      ),
      child: Text(
        '$count favorite${count == 1 ? '' : 's'}',
        style: TextStyle(
          fontSize: 16,
          color: secondaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFavoriteTile(BuildContext context, Favorite fav) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: grey300.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: grey100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  fav.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: grey100,
                        child: Icon(
                          Icons.pets_rounded,
                          size: 32,
                          color: greyColor,
                        ),
                      ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fav.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: secondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "₹${fav.price}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Delete
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: redColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showRemoveDialog(context, fav),
                  borderRadius: BorderRadius.circular(20),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: redColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, Favorite fav) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Remove from Favorites',
            style: TextStyle(
              color: secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to remove "${fav.name}" from your favorites?',
            style: TextStyle(color: grey600, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: greyColor)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<FavoritesCubit>().toggleFavorite(fav);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: redColor,
                foregroundColor: whiteColor,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 22,
              color: secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Start adding products to your favorites to see them here.',
              style: TextStyle(fontSize: 16, color: grey600, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "Continue Shopping",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
