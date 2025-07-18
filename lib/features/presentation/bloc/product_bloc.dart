import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/domain/usecase/fetch_products_usecase.dart';

import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final FetchProductsUseCase fetchProductsUseCase;

  List<ProductEntity> _allProducts = [];
  List<ProductEntity> get allProducts => _allProducts;

  double _maxPrice = 250;
  double get maxPrice => _maxPrice;

  ProductBloc(this.fetchProductsUseCase) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<FilterByCategory>(_onFilterByCategory);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await fetchProductsUseCase();
      _allProducts = products;
      _maxPrice = _getMaxPrice(products);
      emit(ProductLoaded(products, products));
    } catch (e) {
      emit(ProductError('Failed to load products: ${e.toString()}'));
    }
  }

  void _onSearchProducts(SearchProducts event, Emitter<ProductState> emit) {
    final query = event.query.toLowerCase().trim();

    if (query.isEmpty) {
      emit(ProductLoaded(_allProducts, _allProducts));
      return;
    }

    final filtered =
        _allProducts.where((p) {
          return p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query);
        }).toList();

    emit(ProductLoaded(_allProducts, filtered));
  }

  void _onFilterByCategory(FilterByCategory event, Emitter<ProductState> emit) {
    final categoryFilter = event.category.toLowerCase().trim();

    final filtered =
        categoryFilter == 'all'
            ? _allProducts
            : _allProducts.where((p) {
              return p.category.toLowerCase() == categoryFilter;
            }).toList();

    emit(ProductLoaded(_allProducts, filtered));
  }

  double _getMaxPrice(List<ProductEntity> products) {
    if (products.isEmpty) return 250.0;
    return products
        .map((p) => p.price.toDouble())
        .reduce((a, b) => a > b ? a : b);
  }
}
