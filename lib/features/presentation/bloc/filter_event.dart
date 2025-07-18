import 'package:equatable/equatable.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';

/// Base class for all filter events.
abstract class FilterEvent extends Equatable {
  const FilterEvent();

  @override
  List<Object?> get props => [];
}

/// Set initial max price from ProductBloc
class SetInitialFilters extends FilterEvent {
  final double maxPrice;

  const SetInitialFilters(this.maxPrice);

  @override
  List<Object?> get props => [maxPrice];
}

/// Update filter values without applying them yet.
class UpdateFilterCriteria extends FilterEvent {
  final double? minPrice;
  final double? maxPrice;
  final String? sortOption;
  final List<String>? categories;

  const UpdateFilterCriteria({
    this.minPrice,
    this.maxPrice,
    this.sortOption,
    this.categories,
  });

  @override
  List<Object?> get props => [minPrice, maxPrice, sortOption, categories];
}

/// Trigger actual filtering + sorting using current state values.
class ApplyFilters extends FilterEvent {
  final List<ProductEntity> allProducts;
  final List<String> favoriteProductIds;

  const ApplyFilters({
    required this.allProducts,
    required this.favoriteProductIds,
  });

  @override
  List<Object?> get props => [allProducts, favoriteProductIds];
}

/// Reset all filters to default.
class ResetFilters extends FilterEvent {
  const ResetFilters();
}
