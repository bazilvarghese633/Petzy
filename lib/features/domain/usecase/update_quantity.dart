// lib/features/domain/usecase/cart/update_cart_quantity.dart

import 'package:petzy/features/domain/repository/cart_repository.dart';

class UpdateCartQuantityUseCase {
  final CartRepository repository;
  UpdateCartQuantityUseCase(this.repository);

  Future<void> call(String productId, int quantity) {
    return repository.updateCartItemQuantity(productId, quantity);
  }
}
