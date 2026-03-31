import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.name,
    super.description,
    required super.category,
    required super.price,
    required super.quantity,
    required super.unit,
    required super.imageUrls,
    super.averageRating = 0.0,
    super.totalReviews = 0,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'category': category,
    'price': price,
    'quantity': quantity,
    'unit': unit,
    'images': imageUrls,
    'averageRating': averageRating,
    'totalReviews': totalReviews,
  };

  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      category: data['category'] ?? '',
      price: (data['price'] as num).toInt(),
      quantity: (data['quantity'] as num).toInt(),
      unit: data['unit'] ?? '',
      imageUrls: List<String>.from(data['images'] ?? []),
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      totalReviews: (data['totalReviews'] ?? 0).toInt(),
    );
  }

  factory ProductModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromMap(doc.id, data);
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      category: entity.category,
      price: entity.price,
      quantity: entity.quantity,
      unit: entity.unit,
      imageUrls: entity.imageUrls,
      averageRating: entity.averageRating,
      totalReviews: entity.totalReviews,
    );
  }
}
