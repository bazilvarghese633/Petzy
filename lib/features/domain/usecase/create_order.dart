import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/domain/repository/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<String> call(OrderEntity order) async {
    return await repository.createOrder(order);
  }
}
