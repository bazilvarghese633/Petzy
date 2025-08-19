import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/presentation/bloc/categories_bloc.dart';
import 'package:petzy/features/presentation/bloc/cubit/favorites_cubit.dart';
import 'package:petzy/features/presentation/bloc/filter_bloc.dart';
import 'package:petzy/features/presentation/bloc/filter_event.dart';
import 'package:petzy/features/presentation/bloc/product_bloc.dart';
import 'package:petzy/features/presentation/bloc/product_event.dart';
import 'package:petzy/features/presentation/bloc/product_state.dart';
import 'package:petzy/features/presentation/bloc/cubit/category_search_cubit.dart';
import 'package:petzy/features/presentation/screens/filter_result_screen/filtered_screen.dart';
import 'package:petzy/features/presentation/screens/home_screen/widgets/custom_navbar.dart';
import 'package:shimmer/shimmer.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategorySearchCubit(),
      child: const CategoryScreenContent(),
    );
  }
}

class CategoryScreenContent extends StatelessWidget {
  const CategoryScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final _searchController = TextEditingController();
    const int _currentIndex = 2;

    context.read<CategoriesBloc>().add(LoadCategories());
    context.read<ProductBloc>().add(LoadProducts());

    _searchController.addListener(() {
      context.read<CategorySearchCubit>().updateQuery(_searchController.text);
    });

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold, color: secondaryColor),
        ),
        backgroundColor: whiteColor,
        centerTitle: true,

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {},
      ),
      body: Column(
        children: [
          _buildSearchField(context, _searchController),
          Expanded(child: _buildCategoryGrid(context)),
        ],
      ),
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        elevation: 3,
        shadowColor: greyColor.withOpacity(0.26),
        borderRadius: BorderRadius.circular(12),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Search categories...',
            hintStyle: const TextStyle(color: secondaryColor),
            prefixIcon: const Icon(Icons.search, color: primaryColor),
            suffixIcon:
                controller.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear, color: primaryColor),
                      onPressed: () {
                        controller.clear();
                        context.read<CategorySearchCubit>().clearQuery();
                      },
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: whiteColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoryState>(
      builder: (context, catState) {
        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, prodState) {
            return BlocBuilder<CategorySearchCubit, String>(
              builder: (context, searchQuery) {
                if (catState is CategoriesLoading ||
                    prodState is ProductLoading) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      itemCount: 6,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3 / 4,
                          ),
                      itemBuilder: (_, __) => _buildShimmerTile(),
                    ),
                  );
                }

                if (catState is CategoriesLoaded &&
                    prodState is ProductLoaded) {
                  final allCategories =
                      catState.all
                          .where(
                            (cat) => cat.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            ),
                          )
                          .toList();

                  final products = prodState.products;

                  if (allCategories.isEmpty) {
                    return const Center(
                      child: Text(
                        'No categories found.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: secondaryColor,
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: GridView.builder(
                      itemCount: allCategories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3 / 4,
                          ),
                      itemBuilder: (context, index) {
                        final category = allCategories[index];
                        final product = products.firstWhere(
                          (p) =>
                              p.category.toLowerCase() ==
                              category.toLowerCase(),
                          orElse:
                              () => ProductEntity(
                                id: '',
                                name: '',
                                category: '',
                                price: 0,
                                imageUrls: [],
                                quantity: 0,
                                unit: '',
                              ),
                        );

                        return _buildCategoryTile(
                          context,
                          category,
                          product.imageUrls.isNotEmpty
                              ? product.imageUrls.first
                              : '',
                        );
                      },
                    ),
                  );
                }

                return const Center(
                  child: Text(
                    'Something went wrong.',
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerTile() {
    return Shimmer.fromColors(
      baseColor: grey300,
      highlightColor: grey100,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: whiteColor,
        ),
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    String category,
    String imageUrl,
  ) {
    return GestureDetector(
      onTap: () {
        final productState = context.read<ProductBloc>().state;
        final favorites =
            context
                .read<FavoritesCubit>()
                .state
                .map((e) => e.productId)
                .toList();

        if (productState is ProductLoaded) {
          context.read<FilterBloc>().add(
            UpdateFilterCriteria(
              categories: [category], // already passed as param
              sortOption: 'Favorites First',
            ),
          );

          context.read<FilterBloc>().add(
            ApplyFilters(
              allProducts: productState.products,
              favoriteProductIds: favorites,
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FilteredProductListScreen(),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: whiteColor,
          boxShadow: [
            BoxShadow(
              color: greyColor.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child:
                    imageUrl.isNotEmpty
                        ? Hero(
                          tag: category,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: greyColor,
                                  ),
                                ),
                          ),
                        )
                        : Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: greyColor,
                          ),
                        ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: primaryColor.withOpacity(0.85),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
