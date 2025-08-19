import 'package:petzy/features/domain/repository/order_repository.dart';
import 'package:petzy/features/domain/repository/wallet_repository.dart';

class CancelOrderUseCase {
  final OrderRepository orderRepository;
  final WalletRepository walletRepository;

  CancelOrderUseCase({
    required this.orderRepository,
    required this.walletRepository,
  });

  Future<void> call(String orderId, String userId, double refundAmount) async {
    try {
      await orderRepository.updateOrderStatus(orderId, 'cancelled', null);

      await walletRepository.addMoney(
        userId,
        refundAmount,
        'Refund for cancelled order',
        orderId: orderId,
      );
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }
}
