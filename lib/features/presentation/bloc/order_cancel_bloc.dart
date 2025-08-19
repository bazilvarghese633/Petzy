import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/domain/repository/order_repository.dart';
import 'package:petzy/features/domain/repository/wallet_repository.dart';
import 'package:petzy/features/domain/repository/product_repository.dart'; // 🔥 ADD THIS

// Events
abstract class OrderCancelEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CancelOrderRequested extends OrderCancelEvent {
  final String orderId;
  final double refundAmount;

  CancelOrderRequested({required this.orderId, required this.refundAmount});

  @override
  List<Object?> get props => [orderId, refundAmount];
}

// States
abstract class OrderCancelState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderCancelInitial extends OrderCancelState {}

class OrderCancelLoading extends OrderCancelState {}

class OrderCancelSuccess extends OrderCancelState {
  final String message;

  OrderCancelSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderCancelError extends OrderCancelState {
  final String message;

  OrderCancelError(this.message);

  @override
  List<Object?> get props => [message];
}

// 🔥 UPDATED: BLoC with ProductRepository for stock restoration
class OrderCancelBloc extends Bloc<OrderCancelEvent, OrderCancelState> {
  final OrderRepository orderRepository;
  final WalletRepository walletRepository;
  final ProductRepository productRepository; // 🔥 ADD THIS
  final FirebaseAuth firebaseAuth;

  OrderCancelBloc({
    required this.orderRepository,
    required this.walletRepository,
    required this.productRepository, // 🔥 ADD THIS
    required this.firebaseAuth,
  }) : super(OrderCancelInitial()) {
    on<CancelOrderRequested>(_onCancelOrderRequested);
  }

  Future<void> _onCancelOrderRequested(
    CancelOrderRequested event,
    Emitter<OrderCancelState> emit,
  ) async {
    emit(OrderCancelLoading());

    try {
      print('🔥 BLoC: Starting cancel order for: ${event.orderId}');

      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      print('🔥 BLoC: User ID: $userId');

      print('🔥 BLoC: Fetching order details...');
      final order = await orderRepository.getOrderById(event.orderId);
      if (order == null) {
        throw Exception('Order not found');
      }
      print(
        '✅ BLoC: Order details fetched - Product: ${order.product.id}, Quantity: ${order.quantity}',
      );

      print('🔥 BLoC: Updating order status to cancelled...');
      await orderRepository.updateOrderStatus(event.orderId, 'cancelled', null);
      print('✅ BLoC: Order status updated successfully');

      print('🔥 BLoC: Restoring product stock...');
      await productRepository.increaseProductStock(
        order.product.id,
        order.quantity,
      );
      print('✅ BLoC: Product stock restored (+${order.quantity} units)');

      print('🔥 BLoC: Processing wallet refund...');
      await walletRepository.addMoney(
        userId,
        event.refundAmount,
        'Refund for cancelled order #${event.orderId.substring(event.orderId.length - 6)}',
        orderId: event.orderId,
      );
      print('✅ BLoC: Wallet refund processed successfully');

      emit(
        OrderCancelSuccess(
          'Order cancelled successfully! Stock restored and refund added to wallet.',
        ),
      );
      print('✅ BLoC: Cancel order process completed with stock restoration');
    } catch (e) {
      print('❌ BLoC: Cancel order failed: $e');
      emit(OrderCancelError('Failed to cancel order: ${e.toString()}'));
    }
  }
}
