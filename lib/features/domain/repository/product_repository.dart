import 'package:petzy/features/domain/entity/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> fetchProducts();
  Future<List<String>> fetchCategories();
  Future<ProductEntity?> fetchProductById(String productId);
  Future<void> increaseProductStock(String productId, int quantity);
  Future<void> decreaseProductStock(String productId, int quantity);
  Future<void> reduceProductStock(String productId, int quantityPurchased);
}
