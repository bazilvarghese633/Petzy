// lib/features/domain/usecase/cart/add_to_cart.dart

import 'package:petzy/features/domain/entity/cart_item.dart';
import 'package:petzy/features/domain/repository/cart_repository.dart';

class AddToCartUseCase {
  final CartRepository repository;
  AddToCartUseCase(this.repository);

  Future<void> call(CartItem item) => repository.addToCart(item);
}
