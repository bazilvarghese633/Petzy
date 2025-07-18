// lib/features/domain/usecase/cart/get_cart_items.dart
import 'package:petzy/features/domain/entity/cart_item.dart';
import 'package:petzy/features/domain/repository/cart_repository.dart';

class GetCartItemsUseCase {
  final CartRepository repository;
  GetCartItemsUseCase(this.repository);

  Stream<List<CartItem>> call() => repository.getCartItems();
}
