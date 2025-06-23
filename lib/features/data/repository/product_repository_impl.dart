import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/domain/repository/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore firestore;

  ProductRepositoryImpl(this.firestore);

  @override
  Future<List<ProductEntity>> fetchProducts() async {
    final snapshot = await firestore.collection('products').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ProductEntity(
        id: doc.id,
        name: data['name'],
        description: data['description'],
        category: data['category'],
        price: data['price'],
        quantity: data['quantity'],
        unit: data['unit'],
        imageUrls: List<String>.from(data['images'] ?? []),
      );
    }).toList();
  }

  @override
  Future<List<String>> fetchCategories() async {
    final snapshot = await firestore.collection('categories').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }
}
