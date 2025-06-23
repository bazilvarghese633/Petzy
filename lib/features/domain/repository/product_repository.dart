import 'package:petzy/features/domain/entity/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> fetchProducts();
  Future<List<String>> fetchCategories();
}
