import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/domain/entity/cart_item.dart';

class CartRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CartRemoteDataSource({required this.firestore, required this.auth});

  String get uid => auth.currentUser?.uid ?? 'unknown_user';

  Future<void> addToCart(CartItem item) async {
    final doc = firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(item.id);

    final snapshot = await doc.get();

    if (snapshot.exists) {
      final currentQty = snapshot.data()?['quantity'] ?? 1;
      await doc.update({'quantity': currentQty + 1});
    } else {
      await doc.set({
        'name': item.name,
        'imageUrl': item.imageUrl,
        'price': item.price,
        'quantity': item.quantity,
      });
    }
  }

  Future<void> updateCartItemQuantity(String productId, int quantity) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(productId)
        .update({'quantity': quantity});
  }

  Stream<List<CartItem>> getCartItems() {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return CartItem(
              id: doc.id,
              name: data['name'],
              imageUrl: data['imageUrl'],
              price: (data['price'] as num).toDouble(),
              quantity: data['quantity'],
            );
          }).toList();
        });
  }
}
