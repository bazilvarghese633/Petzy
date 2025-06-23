import 'package:petzy/features/domain/entity/product_entity.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductEntity> products;
  final List<ProductEntity> filteredProducts;

  ProductLoaded(this.products, this.filteredProducts);
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
