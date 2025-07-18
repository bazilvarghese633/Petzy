import 'package:petzy/features/domain/entity/cart_item.dart';

abstract class CartEvent {}

class LoadCart extends CartEvent {}

class AddCartItem extends CartEvent {
  final CartItem item;
  AddCartItem(this.item);
}

class UpdateCartItemQuantity extends CartEvent {
  final String productId;
  final int quantity;
  UpdateCartItemQuantity(this.productId, this.quantity);
}

class CartUpdated extends CartEvent {
  final List<CartItem> items;
  CartUpdated(this.items);
}

class RemoveCartItem extends CartEvent {
  final String productId;
  RemoveCartItem(this.productId);
}
