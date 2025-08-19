import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/domain/usecase/create_order.dart';
import 'package:petzy/features/domain/usecase/reduce_product_stock.dart';
import 'package:petzy/features/domain/usecase/update_order_status.dart';
import 'package:petzy/features/domain/usecase/get_profile.dart';

import 'buy_now_event.dart';
import 'buy_now_state.dart';

class BuyNowBloc extends Bloc<BuyNowEvent, BuyNowState> {
  final CreateOrderUseCase createOrderUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final ReduceProductStockUseCase reduceProductStockUseCase;
  final GetProfileUseCase getProfileUseCase;
  final Razorpay razorpay;
  final FirebaseAuth firebaseAuth;

  String? currentOrderId;
  OrderEntity? currentOrder;

  BuyNowBloc({
    required this.createOrderUseCase,
    required this.updateOrderStatusUseCase,
    required this.reduceProductStockUseCase,
    required this.getProfileUseCase,
    required this.razorpay,
    required this.firebaseAuth,
  }) : super(BuyNowInitial()) {
    on<InitializeBuyNow>(_onInitializeBuyNow);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ProcessPayment>(_onProcessPayment);
    on<PaymentSuccess>(_onPaymentSuccess);
    on<PaymentFailed>(_onPaymentFailed);
    on<RetryPayment>(_onRetryPayment);
  }

  void _onInitializeBuyNow(InitializeBuyNow event, Emitter<BuyNowState> emit) {
    final total = (event.product.price * event.quantity).toDouble();
    emit(
      BuyNowLoaded(
        product: event.product,
        quantity: event.quantity,
        totalAmount: total,
      ),
    );
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<BuyNowState> emit) {
    if (state is! BuyNowLoaded) return;
    final s = state as BuyNowLoaded;
    emit(
      s.copyWith(
        quantity: event.quantity,
        totalAmount: (s.product.price * event.quantity).toDouble(),
      ),
    );
  }

  Future<void> _onProcessPayment(
    ProcessPayment event,
    Emitter<BuyNowState> emit,
  ) async {
    if (state is! BuyNowLoaded) return;
    final s = state as BuyNowLoaded;
    emit(BuyNowProcessing());

    try {
      currentOrderId = DateTime.now().millisecondsSinceEpoch.toString();
      currentOrder = OrderEntity(
        id: currentOrderId!,
        product: s.product,
        quantity: s.quantity,
        totalAmount: s.totalAmount,
        status: 'pending',
        createdAt: DateTime.now(),
      );
      await createOrderUseCase(currentOrder!);

      // user meta
      final user = firebaseAuth.currentUser;
      var contact = '9999999999';
      var email = 'user@example.com';
      var name = 'Guest User';

      if (user != null) {
        email = user.email ?? email;
        name = user.displayName ?? name;
        try {
          final profile = await getProfileUseCase(user.uid);
          if (profile != null) {
            if (profile.phone?.isNotEmpty == true) contact = profile.phone!;
            if (profile.email?.isNotEmpty == true) email = profile.email!;
            if (profile.name?.isNotEmpty == true) name = profile.name!;
          }
        } catch (_) {}
      }

      // Razorpay options
      final options = {
        'key': 'rzp_test_zGUWcHp8eqJukI',
        'amount': (s.totalAmount * 100).toInt(),
        'currency': 'INR',
        'name': 'Petzy',
        'description': 'Purchase of ${s.product.name}',
        'prefill': {'contact': contact, 'email': email, 'name': name},
        'theme': {'color': '#EF8A45'},
      };

      razorpay.open(options);
    } catch (e) {
      emit(BuyNowError('Failed to start payment: $e'));
    }
  }

  Future<void> _onPaymentSuccess(
    PaymentSuccess event,
    Emitter<BuyNowState> emit,
  ) async {
    try {
      await updateOrderStatusUseCase(event.orderId, 'paid', event.paymentId);

      // reduce stock
      if (currentOrder != null) {
        await reduceProductStockUseCase(
          currentOrder!.product.id,
          currentOrder!.quantity,
        );
      }

      emit(BuyNowPaymentSuccess(event.paymentId, event.orderId));
    } catch (e) {
      emit(BuyNowError('Payment saved, but order update failed: $e'));
    }
  }

  Future<void> _onPaymentFailed(
    PaymentFailed event,
    Emitter<BuyNowState> emit,
  ) async {
    if (currentOrderId != null) {
      final isCancelled = event.error.toLowerCase().contains('cancelled');
      final status = isCancelled ? 'cancelled' : 'failed';
      try {
        await updateOrderStatusUseCase(currentOrderId!, status, null);
      } catch (_) {}
    }
    emit(BuyNowError(event.error));
  }

  void _onRetryPayment(RetryPayment event, Emitter<BuyNowState> emit) {
    if (currentOrder == null) return; // safety

    updateOrderStatusUseCase(currentOrderId!, 'retrying', null);

    emit(
      BuyNowLoaded(
        product: currentOrder!.product,
        quantity: currentOrder!.quantity,
        totalAmount: currentOrder!.totalAmount,
      ),
    );

    add(const ProcessPayment());
  }

  @override
  Future<void> close() {
    currentOrderId = null;
    currentOrder = null;
    return super.close();
  }
}
