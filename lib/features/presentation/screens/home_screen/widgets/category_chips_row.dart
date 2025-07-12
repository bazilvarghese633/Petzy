import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/presentation/bloc/categories_bloc.dart';
import 'package:shimmer/shimmer.dart';

class CategoryChipsRow extends StatelessWidget {
  final void Function(String) onCategorySelected;

  const CategoryChipsRow({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          // 🔄 Shimmer loading state
          return SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 40,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else if (state is CategoriesLoaded) {
          return Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // 🔘 Filter Button
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFFF9900),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.tune, color: Color(0xFFFF9900)),
                      onPressed: () {
                        // Add filter logic later
                      },
                    ),
                  ),
                ),

                // 🔸 Category Chips
                ...['All', ...state.all].map((category) {
                  final isSelected = state.selected == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => onCategorySelected(category),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFFFF9900)
                                  : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        } else if (state is CategoriesError) {
          return Center(child: Text(state.message));
        } else {
          return const SizedBox(height: 60);
        }
      },
    );
  }
}
