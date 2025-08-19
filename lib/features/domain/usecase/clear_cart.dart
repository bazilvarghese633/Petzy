import 'package:petzy/features/domain/repository/cart_repository.dart';

class ClearCartUseCase {
  final CartRepository repository;

  ClearCartUseCase(this.repository);

  Future<void> call() async {
    return await repository.clearCart();
  }
}
