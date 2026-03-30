import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzy/features/domain/entity/fevorite.dart';

class FavoriteModel extends Favorite {
  FavoriteModel({
    required super.productId,
    required super.name,
    required super.imageUrl,
    required super.price,
  });

  /// Convert entity → Firestore-ready map
  Map<String, dynamic> toMap() => {
    'productId': productId,
    'name': name,
    'imageUrl': imageUrl,
    'price': price,
  };

  /// Build model from a raw Firestore map
  factory FavoriteModel.fromMap(Map<String, dynamic> data) {
    return FavoriteModel(
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] as num).toDouble(),
    );
  }

  /// Build model directly from a Firestore DocumentSnapshot
  factory FavoriteModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteModel.fromMap(data);
  }

  /// Convert a plain Favorite entity → FavoriteModel
  factory FavoriteModel.fromEntity(Favorite entity) {
    return FavoriteModel(
      productId: entity.productId,
      name: entity.name,
      imageUrl: entity.imageUrl,
      price: entity.price,
    );
  }
}
