import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzy/features/domain/entity/cart_item.dart';

class CartItemModel extends CartItem {
  CartItemModel({
    required super.id,
    required super.name,
    required super.price,
    required super.quantity,
    required super.imageUrl,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
    'imageUrl': imageUrl,
  };

  static CartItemModel fromMap(Map<String, dynamic> data) => CartItemModel(
    id: data['id'],
    name: data['name'],
    price: data['price'].toDouble(),
    quantity: data['quantity'],
    imageUrl: data['imageUrl'],
  );

  static CartItemModel fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return fromMap(data);
  }

  static CartItemModel fromEntity(CartItem item) => CartItemModel(
    id: item.id,
    name: item.name,
    price: item.price,
    quantity: item.quantity,
    imageUrl: item.imageUrl,
  );
}
