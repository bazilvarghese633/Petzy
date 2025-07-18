import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/presentation/bloc/categories_bloc.dart';
import 'package:petzy/features/presentation/bloc/cubit/category_selection_cubit.dart';

class CategorySelectionDialog extends StatelessWidget {
  final List<String> initiallySelected;
  final void Function(List<String>) onApply;

  const CategorySelectionDialog({
    super.key,
    required this.initiallySelected,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategorySelectionCubit(initiallySelected),
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        title: const Text(
          "Select Categories",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.brown,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 420,
          child: Column(
            children: [
              _buildSearchField(context),
              const SizedBox(height: 12),
              _buildCategoryList(),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          BlocBuilder<CategorySelectionCubit, CategorySelectionState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: () {
                  onApply(state.selected);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Apply"),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return BlocBuilder<CategorySelectionCubit, CategorySelectionState>(
      builder: (context, state) {
        return TextField(
          decoration: InputDecoration(
            hintText: "Search category",
            prefixIcon: const Icon(Icons.search),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (value) {
            context.read<CategorySelectionCubit>().updateSearchText(value);
          },
        );
      },
    );
  }

  Widget _buildCategoryList() {
    return Expanded(
      child: BlocBuilder<CategoriesBloc, CategoryState>(
        builder: (context, catState) {
          if (catState is CategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (catState is CategoriesLoaded) {
            return BlocBuilder<CategorySelectionCubit, CategorySelectionState>(
              builder: (context, state) {
                final filtered =
                    catState.all
                        .where(
                          (cat) => cat.toLowerCase().contains(
                            state.searchText.toLowerCase(),
                          ),
                        )
                        .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No matching categories."));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cat = filtered[index];
                    final isSelected = state.selected.contains(cat);

                    return CheckboxListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor:
                          isSelected
                              ? Colors.orange.withOpacity(0.1)
                              : Colors.transparent,
                      title: Text(
                        cat,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.deepOrange : Colors.black,
                        ),
                      ),
                      value: isSelected,
                      activeColor: Colors.orange,
                      onChanged: (_) {
                        context.read<CategorySelectionCubit>().toggleCategory(
                          cat,
                        );
                      },
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text("Failed to load categories"));
        },
      ),
    );
  }
}
