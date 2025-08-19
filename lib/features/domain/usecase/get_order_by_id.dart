import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/domain/repository/order_repository.dart';

class GetOrderByIdUseCase {
  final OrderRepository repository;

  GetOrderByIdUseCase(this.repository);

  Future<OrderEntity?> call(String orderId) async {
    return await repository.getOrderById(orderId);
  }
}
