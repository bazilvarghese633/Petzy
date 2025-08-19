import 'package:petzy/features/domain/entity/order_entity.dart';

abstract class OrderRepository {
  Future<String> createOrder(OrderEntity order);
  Future<void> updateOrderStatus(
    String orderId,
    String status,
    String? paymentId,
  );
  Future<List<OrderEntity>> getUserOrders();
  Future<OrderEntity?> getOrderById(String orderId);
  Stream<List<OrderEntity>> watchUserOrders();
  Future<void> cancelOrder(String orderId, String userId);
  Future<void> processRefund(String orderId, String userId, double amount);
}
