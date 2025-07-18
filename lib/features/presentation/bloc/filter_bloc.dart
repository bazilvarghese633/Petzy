import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'filter_event.dart';
import 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  FilterBloc({required double absoluteMaxPrice})
    : super(FilterState.initial(absoluteMaxPrice: absoluteMaxPrice)) {
    on<SetInitialFilters>(_onSetInitialFilters);
    on<UpdateFilterCriteria>(_onUpdateFilterCriteria);
    on<ApplyFilters>(_onApplyFilters);
    on<ResetFilters>(_onResetFilters);
  }

  void _onSetInitialFilters(
    SetInitialFilters event,
    Emitter<FilterState> emit,
  ) {
    emit(
      state.copyWith(
        absoluteMaxPrice: event.maxPrice,
        minPrice: 0,
        maxPrice: event.maxPrice,
        sortOption: 'Default',
        categories: const [],
        filteredProducts: const [],
        status: FilterStatus.loaded,
        errorMessage: null,
      ),
    );
  }

  void _onUpdateFilterCriteria(
    UpdateFilterCriteria event,
    Emitter<FilterState> emit,
  ) {
    emit(
      state.copyWith(
        minPrice: event.minPrice ?? state.minPrice,
        maxPrice: event.maxPrice ?? state.maxPrice,
        sortOption: event.sortOption ?? state.sortOption,
        categories: event.categories ?? state.categories,
        // Optional: clear filteredProducts when criteria change
        filteredProducts: const [],
      ),
    );
  }

  void _onApplyFilters(ApplyFilters event, Emitter<FilterState> emit) async {
    try {
      emit(state.copyWith(status: FilterStatus.loading));

      final filtered = _filterProducts(
        event.allProducts,
        state.minPrice,
        state.maxPrice,
        state.categories,
      );

      final sorted = _sortProducts(
        filtered,
        state.sortOption,
        event.favoriteProductIds,
      );

      emit(
        state.copyWith(filteredProducts: sorted, status: FilterStatus.loaded),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FilterStatus.error,
          errorMessage: 'Failed to apply filters: ${e.toString()}',
        ),
      );
    }
  }

  void _onResetFilters(ResetFilters event, Emitter<FilterState> emit) {
    emit(
      state.copyWith(
        minPrice: 0,
        maxPrice: state.absoluteMaxPrice,
        sortOption: 'Default',
        categories: const [],
        filteredProducts: const [],
        status: FilterStatus.loaded,
        errorMessage: null,
      ),
    );
  }

  List<ProductEntity> _filterProducts(
    List<ProductEntity> products,
    double minPrice,
    double maxPrice,
    List<String> categories,
  ) {
    return products.where((product) {
      final price = product.price.toDouble();
      final matchesPrice = price >= minPrice && price <= maxPrice;

      final matchesCategory =
          categories.isEmpty ||
          categories.any(
            (c) => c.toLowerCase() == product.category.toLowerCase(),
          );

      return matchesPrice && matchesCategory;
    }).toList();
  }

  List<ProductEntity> _sortProducts(
    List<ProductEntity> products,
    String sortOption,
    List<String> favoriteIds,
  ) {
    final sorted = List<ProductEntity>.from(products);
    switch (sortOption) {
      case 'Price: Low to High':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'A-Z':
        sorted.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case 'Z-A':
        sorted.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case 'Favorites First':
        sorted.sort((a, b) {
          final aFav = favoriteIds.contains(a.id);
          final bFav = favoriteIds.contains(b.id);
          if (aFav && !bFav) return -1;
          if (!aFav && bFav) return 1;
          return 0;
        });
        break;
      case 'Default':
      default:
        break;
    }
    return sorted;
  }
}
