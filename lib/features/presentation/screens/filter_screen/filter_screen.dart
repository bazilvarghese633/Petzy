import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';
import 'package:petzy/features/presentation/bloc/categories_bloc.dart';
import 'package:petzy/features/presentation/bloc/cubit/favorites_cubit.dart';
import 'package:petzy/features/presentation/bloc/cubit/price_slider_cubit.dart';
import 'package:petzy/features/presentation/bloc/filter_bloc.dart';
import 'package:petzy/features/presentation/bloc/filter_event.dart';
import 'package:petzy/features/presentation/bloc/filter_state.dart';
import 'package:petzy/features/presentation/bloc/product_bloc.dart';
import 'package:petzy/features/presentation/screens/filter_result_screen/filtered_screen.dart';
import 'package:petzy/features/presentation/screens/filter_screen/category_selection_screen.dart';
import 'package:petzy/features/presentation/screens/filter_screen/widgets/price_slider.dart';
import 'package:petzy/features/presentation/screens/filter_screen/widgets/sort_bottom_sheet.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filterBloc = context.read<FilterBloc>();

    return BlocListener<FilterBloc, FilterState>(
      listenWhen:
          (prev, curr) =>
              prev.minPrice != curr.minPrice || prev.maxPrice != curr.maxPrice,
      listener: (context, state) {
        context.read<PriceSliderCubit>().updateRange(
          state.minPrice,
          state.maxPrice,
        );
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: const Text(
            'Filters',
            style: TextStyle(color: brownColr, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: whiteColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: brownColr),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: ElevatedButton(
                onPressed: () {
                  filterBloc.add(const ResetFilters());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Reset",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<FilterBloc, FilterState>(
          builder: (context, state) {
            if (state.status == FilterStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'An error occurred',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => filterBloc.add(const ResetFilters()),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCategoryTile(context, state.categories),
                const SizedBox(height: 16),
                Card(
                  color: whiteColor,
                  child: ListTile(
                    title: const Text(
                      "Sort by",
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      state.sortOption,
                      style: const TextStyle(
                        fontSize: 16,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder:
                            (_) => BlocProvider.value(
                              value: filterBloc,
                              child: SortBottomSheet(
                                selectedOption: state.sortOption,
                              ),
                            ),
                      );
                    },
                  ),
                ),
                sizedBoxH12,
                PriceSlider(absoluteMax: state.absoluteMaxPrice),
                sizedBoxH20,
                if (state.status == FilterStatus.loading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<FilterBloc, FilterState>(
            builder: (context, state) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed:
                    state.status == FilterStatus.loading
                        ? null
                        : () => _applyFiltersAndNavigate(context),
                child:
                    state.status == FilterStatus.loading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              whiteColor,
                            ),
                          ),
                        )
                        : const Text(
                          "Apply",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _applyFiltersAndNavigate(BuildContext context) {
    final productBloc = context.read<ProductBloc>();
    final favoritesCubit = context.read<FavoritesCubit>();
    final favoriteIds = favoritesCubit.state.map((e) => e.productId).toList();
    final filterBloc = context.read<FilterBloc>();

    filterBloc.add(
      ApplyFilters(
        allProducts: productBloc.allProducts,
        favoriteProductIds: favoriteIds,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: filterBloc,
              child: const FilteredProductListScreen(),
            ),
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    List<String> selectedCategories,
  ) {
    final filterBloc = context.read<FilterBloc>();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: whiteColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openCategorySelection(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Category",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: secondaryColor,
                  ),
                ],
              ),
              sizedBoxH12,
              if (selectedCategories.isEmpty)
                const Text(
                  "No categories selected",
                  style: TextStyle(fontSize: 13, color: greyColor),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      selectedCategories.map((category) {
                        return InputChip(
                          label: Text(category),
                          backgroundColor: primaryColor,
                          labelStyle: const TextStyle(
                            color: whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            final updated = List<String>.from(
                              selectedCategories,
                            )..remove(category);
                            filterBloc.add(
                              UpdateFilterCriteria(categories: updated),
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: primaryColor),
                          ),
                        );
                      }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCategorySelection(BuildContext context) {
    final categoryBloc = context.read<CategoriesBloc>();
    final selected = context.read<FilterBloc>().state.categories;

    showDialog(
      context: context,
      builder:
          (_) => BlocProvider.value(
            value: categoryBloc,
            child: CategorySelectionDialog(
              initiallySelected: selected,
              onApply: (newSelected) {
                context.read<FilterBloc>().add(
                  UpdateFilterCriteria(categories: newSelected),
                );
              },
            ),
          ),
    );
  }
}
