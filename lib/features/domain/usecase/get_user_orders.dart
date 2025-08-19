import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/domain/repository/order_repository.dart';

class GetUserOrdersUseCase {
  final OrderRepository repository;

  GetUserOrdersUseCase(this.repository);

  Future<List<OrderEntity>> call() async {
    return await repository.getUserOrders();
  }
}
