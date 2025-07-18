import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';
import 'package:petzy/features/presentation/bloc/cubit/favorites_cubit.dart';
import 'package:petzy/features/presentation/bloc/cubit/price_slider_cubit.dart';
import 'package:petzy/features/presentation/bloc/filter_bloc.dart';
import 'package:petzy/features/presentation/bloc/filter_event.dart';
import 'package:petzy/features/presentation/bloc/product_bloc.dart';

class PriceSlider extends StatelessWidget {
  final double absoluteMax;

  const PriceSlider({super.key, required this.absoluteMax});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PriceSliderCubit, PriceSliderState>(
      builder: (context, sliderState) {
        return Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.attach_money,
                        color: whiteColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Price Range",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
                sizedBoxH20,

                // Selected Price Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPriceBox(
                      "₹${sliderState.minPrice.toInt()}",
                      isMin: true,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "to",
                        style: TextStyle(
                          fontSize: 12,
                          color: grey600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _buildPriceBox(
                      "₹${sliderState.maxPrice.toInt()}",
                      isMin: false,
                    ),
                  ],
                ),

                sizedBoxH24,

                // RangeSlider
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: Colors.orange.shade100,
                      thumbColor: whiteColor,
                      trackHeight: 6,
                      overlayColor: Colors.orange.withOpacity(0.2),
                      valueIndicatorColor: Colors.orange,
                      valueIndicatorTextStyle: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    child: RangeSlider(
                      values: RangeValues(
                        sliderState.minPrice,
                        sliderState.maxPrice,
                      ),
                      min: 0,
                      max: absoluteMax,
                      divisions: absoluteMax > 0 ? absoluteMax.toInt() : 1,
                      labels: RangeLabels(
                        '₹${sliderState.minPrice.toInt()}',
                        '₹${sliderState.maxPrice.toInt()}',
                      ),
                      onChanged: (newValues) {
                        context.read<PriceSliderCubit>().updateRange(
                          newValues.start,
                          newValues.end,
                        );

                        final filterBloc = context.read<FilterBloc>();
                        filterBloc.add(
                          UpdateFilterCriteria(
                            minPrice: newValues.start,
                            maxPrice: newValues.end,
                          ),
                        );

                        Future.delayed(const Duration(milliseconds: 300), () {
                          final productBloc = context.read<ProductBloc>();
                          final favoritesCubit = context.read<FavoritesCubit>();
                          final favoriteIds =
                              favoritesCubit.state
                                  .map((e) => e.productId)
                                  .toList();

                          filterBloc.add(
                            ApplyFilters(
                              allProducts: productBloc.allProducts,
                              favoriteProductIds: favoriteIds,
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Min-Max Labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRangeLabel('₹0'),
                      _buildRangeLabel('₹${absoluteMax.toInt()}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceBox(String text, {required bool isMin}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, Colors.pink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isMin ? "Min" : "Max",
            style: TextStyle(
              fontSize: 10,
              color: secondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: whiteColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
