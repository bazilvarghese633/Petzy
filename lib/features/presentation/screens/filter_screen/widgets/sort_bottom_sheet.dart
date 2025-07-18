import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/bloc/cubit/favorites_cubit.dart';
import 'package:petzy/features/presentation/bloc/filter_bloc.dart';
import 'package:petzy/features/presentation/bloc/filter_event.dart';
import 'package:petzy/features/presentation/bloc/product_bloc.dart';

class SortBottomSheet extends StatelessWidget {
  final String selectedOption;

  const SortBottomSheet({super.key, required this.selectedOption});

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      'Default',
      'Price: Low to High',
      'Price: High to Low',
      'A-Z',
      'Z-A',
      'Favorites First',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 12,
          left: 16,
          right: 16,
          bottom: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: sortOptions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final option = sortOptions[index];
                  final isSelected = option == selectedOption;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? primaryColor : grey600,
                    ),
                    title: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? primaryColor : grey600,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () => _onOptionSelected(context, option),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onOptionSelected(BuildContext context, String option) {
    if (option == selectedOption) {
      Navigator.pop(context);
      return;
    }

    try {
      final filterBloc = context.read<FilterBloc>();
      final productBloc = context.read<ProductBloc>();
      final favoritesCubit = context.read<FavoritesCubit>();

      final favoriteIds = favoritesCubit.state.map((e) => e.productId).toList();

      filterBloc.add(UpdateFilterCriteria(sortOption: option));
      filterBloc.add(
        ApplyFilters(
          allProducts: productBloc.allProducts,
          favoriteProductIds: favoriteIds,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error applying sort: ${e.toString()}'),
          backgroundColor: redColor,
        ),
      );
      Navigator.pop(context);
    }
  }
}
