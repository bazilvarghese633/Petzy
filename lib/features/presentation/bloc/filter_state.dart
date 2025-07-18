import 'package:equatable/equatable.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';

/// Represents the current status of the filter screen
enum FilterStatus { initial, loading, loaded, error }

/// Holds all state values used in the filtering system
class FilterState extends Equatable {
  final double absoluteMaxPrice; // Max price of all products
  final double minPrice; // Current min filter value
  final double maxPrice; // Current max filter value
  final String sortOption; // e.g., Price Low to High
  final List<String> categories; // Selected categories
  final List<ProductEntity> filteredProducts; // Products after filtering
  final FilterStatus status; // UI loading/error state
  final String? errorMessage; // Optional error text

  const FilterState({
    required this.absoluteMaxPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.sortOption,
    required this.categories,
    required this.filteredProducts,
    required this.status,
    this.errorMessage,
  });

  /// Factory for initial default state
  factory FilterState.initial({required double absoluteMaxPrice}) {
    return FilterState(
      absoluteMaxPrice: absoluteMaxPrice,
      minPrice: 0,
      maxPrice: absoluteMaxPrice,
      sortOption: 'Default',
      categories: const [],
      filteredProducts: const [],
      status: FilterStatus.initial,
    );
  }

  /// Returns a new FilterState with some values changed
  FilterState copyWith({
    double? absoluteMaxPrice,
    double? minPrice,
    double? maxPrice,
    String? sortOption,
    List<String>? categories,
    List<ProductEntity>? filteredProducts,
    FilterStatus? status,
    String? errorMessage,
  }) {
    return FilterState(
      absoluteMaxPrice: absoluteMaxPrice ?? this.absoluteMaxPrice,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortOption: sortOption ?? this.sortOption,
      categories: categories ?? this.categories,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    absoluteMaxPrice,
    minPrice,
    maxPrice,
    sortOption,
    categories,
    filteredProducts,
    status,
    errorMessage,
  ];
}
