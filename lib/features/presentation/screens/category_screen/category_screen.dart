import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/presentation/bloc/categories_bloc.dart';
import 'package:petzy/features/presentation/bloc/product_bloc.dart';
import 'package:petzy/features/presentation/bloc/product_event.dart';
import 'package:petzy/features/presentation/bloc/product_state.dart';
import 'package:petzy/features/presentation/bloc/cubit/category_search_cubit.dart';
import 'package:petzy/features/presentation/screens/home_screen/widgets/custom_navbar.dart';

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
    final int _currentIndex = 2;

    context.read<CategoriesBloc>().add(LoadCategories());
    context.read<ProductBloc>().add(LoadProducts());

    _searchController.addListener(() {
      context.read<CategorySearchCubit>().updateQuery(_searchController.text);
    });

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: whiteColor,
        foregroundColor: brownColr,
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
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search categories...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      context.read<CategorySearchCubit>().clearQuery();
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  return const Center(child: CircularProgressIndicator());
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
                    return const Center(child: Text('No categories found.'));
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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

                        return _buildCategoryTile(context, category, product);
                      },
                    ),
                  );
                }

                return const Center(child: Text('Something went wrong.'));
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    String category,
    ProductEntity product,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<CategoriesBloc>().add(SelectCategory(category));
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  product.imageUrls.isNotEmpty
                      ? Image.network(
                        product.imageUrls.first,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                const Center(child: Icon(Icons.broken_image)),
                      )
                      : const Center(child: Icon(Icons.image_not_supported)),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
