import 'package:petzy/features/domain/repository/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  Future<void> call(String orderId, String status, String? paymentId) async {
    return await repository.updateOrderStatus(orderId, status, paymentId);
  }
}
