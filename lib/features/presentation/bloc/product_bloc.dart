import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/domain/usecase/fetch_products_usecase.dart';

import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final FetchProductsUseCase fetchProductsUseCase;

  List<ProductEntity> _allProducts = [];

  ProductBloc(this.fetchProductsUseCase) : super(ProductInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await fetchProductsUseCase();
        _allProducts = products;
        emit(ProductLoaded(products, products));
      } catch (e) {
        emit(ProductError('Failed to load products'));
      }
    });
    on<SearchProducts>((event, emit) {
      final query = event.query.toLowerCase();
      final filtered =
          _allProducts.where((p) {
            return p.name.toLowerCase().contains(query) ||
                p.category.toLowerCase().contains(query);
          }).toList();
      emit(ProductLoaded(_allProducts, filtered));
    });

    on<FilterByCategory>((event, emit) {
      final filtered =
          event.category == 'All'
              ? _allProducts
              : _allProducts
                  .where(
                    (p) =>
                        p.category.toLowerCase() ==
                        event.category.toLowerCase(),
                  )
                  .toList();
      emit(ProductLoaded(_allProducts, filtered));
    });
  }
}
