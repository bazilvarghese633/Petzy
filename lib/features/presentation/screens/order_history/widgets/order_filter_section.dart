import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';

class OrderFilterSection extends StatelessWidget {
  final String selectedFilter;
  final List<String> filterOptions;
  final Function(String) onFilterChanged;

  const OrderFilterSection({
    super.key,
    required this.selectedFilter,
    required this.filterOptions,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Filter: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: secondaryColor,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    filterOptions.map((filter) {
                      final isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              onFilterChanged(filter);
                            }
                          },
                          selectedColor: primaryColor.withOpacity(0.2),
                          checkmarkColor: primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? primaryColor : grey600,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? primaryColor
                                    : Colors.grey.shade300,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
