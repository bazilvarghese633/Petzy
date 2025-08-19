import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';
import 'package:petzy/features/presentation/bloc/categories_bloc.dart';
import 'package:petzy/features/presentation/bloc/cubit/price_slider_cubit.dart';
import 'package:petzy/features/presentation/bloc/filter_bloc.dart';
import 'package:petzy/features/presentation/bloc/filter_event.dart';
import 'package:petzy/features/presentation/bloc/product_bloc.dart';
import 'package:petzy/features/presentation/screens/filter_screen/filter_screen.dart';
import 'package:shimmer/shimmer.dart';

class CategoryChipsRow extends StatelessWidget {
  final void Function(String) onCategorySelected;

  const CategoryChipsRow({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (_, __) => sizedBoxW8,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: grey300,
                    highlightColor: grey100,
                    child: Container(
                      height: 40,
                      width: 80,
                      decoration: BoxDecoration(
                        color: whiteColor,
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
                      color: whiteColor,
                      border: Border.all(color: primaryColor, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: greyWithOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.tune, color: primaryColor),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              final productBloc = context.read<ProductBloc>();
                              final maxPrice = productBloc.maxPrice;

                              final filterBloc = FilterBloc(
                                absoluteMaxPrice: maxPrice,
                              );
                              filterBloc.add(SetInitialFilters(maxPrice));

                              return MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: filterBloc),
                                  BlocProvider(
                                    create:
                                        (_) => PriceSliderCubit(
                                          filterBloc.state.minPrice,
                                          filterBloc.state.maxPrice,
                                        ),
                                  ),
                                ],
                                child: const FilterScreen(),
                              );
                            },
                          ),
                        );
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
                          color: isSelected ? primaryColor : grey300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? whiteColor : secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                  // ignore: unnecessary_to_list_in_spreads
                }).toList(),
              ],
            ),
          );
        } else if (state is CategoriesError) {
          return Center(child: Text(state.message));
        } else {
          return SizedBoxH60;
        }
      },
    );
  }
}
