import 'package:petzy/features/domain/repository/product_repository.dart';

class ReduceProductStockUseCase {
  final ProductRepository repository;

  ReduceProductStockUseCase(this.repository);

  Future<void> call(String productId, int quantityPurchased) async {
    return await repository.reduceProductStock(productId, quantityPurchased);
  }
}
