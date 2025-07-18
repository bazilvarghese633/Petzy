import 'package:petzy/features/domain/entity/cart_item.dart';

abstract class CartRepository {
  Future<void> addToCart(CartItem item);
  Future<void> updateCartItemQuantity(String productId, int quantity);
  Stream<List<CartItem>> getCartItems();
}
