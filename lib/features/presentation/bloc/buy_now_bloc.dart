import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/domain/usecase/create_order.dart';
import 'package:petzy/features/domain/usecase/reduce_product_stock.dart';
import 'package:petzy/features/domain/usecase/update_order_status.dart';
import 'package:petzy/features/domain/usecase/get_profile.dart';
import 'package:petzy/features/domain/usecase/deduct_money_usecase.dart';
import 'package:petzy/features/domain/usecase/get_wallet.dart';

import 'buy_now_event.dart';
import 'buy_now_state.dart';

class BuyNowBloc extends Bloc<BuyNowEvent, BuyNowState> {
  final CreateOrderUseCase createOrderUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final ReduceProductStockUseCase reduceProductStockUseCase;
  final GetProfileUseCase getProfileUseCase;
  final DeductMoneyUseCase deductMoneyUseCase;
  final GetWalletUseCase getWalletUseCase;
  final Razorpay razorpay;
  final FirebaseAuth firebaseAuth;

  String? currentOrderId;
  OrderEntity? currentOrder;

  BuyNowBloc({
    required this.createOrderUseCase,
    required this.updateOrderStatusUseCase,
    required this.reduceProductStockUseCase,
    required this.getProfileUseCase,
    required this.deductMoneyUseCase,
    required this.getWalletUseCase,
    required this.razorpay,
    required this.firebaseAuth,
  }) : super(BuyNowInitial()) {
    on<InitializeBuyNow>(_onInitializeBuyNow);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ProcessPayment>(_onProcessPayment);
    on<ChangePaymentMethod>(_onChangePaymentMethod);
    on<LoadWalletBalance>(_onLoadWalletBalance);
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
    add(const LoadWalletBalance());
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

  Future<void> _onChangePaymentMethod(
    ChangePaymentMethod event,
    Emitter<BuyNowState> emit,
  ) async {
    if (state is BuyNowLoaded) {
      emit((state as BuyNowLoaded).copyWith(paymentMethod: event.paymentMethod));
      if (event.paymentMethod == 'wallet') {
        add(const LoadWalletBalance());
      }
    }
  }

  Future<void> _onLoadWalletBalance(
    LoadWalletBalance event,
    Emitter<BuyNowState> emit,
  ) async {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    if (state is BuyNowLoaded) {
      final s = state as BuyNowLoaded;
      emit(BuyNowLoadingWallet(
        paymentMethod: s.paymentMethod,
        walletBalance: s.walletBalance,
      ));
      
      try {
        final wallet = await getWalletUseCase(userId);
        if (state is BuyNowLoadingWallet) {
          emit(s.copyWith(walletBalance: wallet?.balance ?? 0.0));
        }
      } catch (e) {
        if (state is BuyNowLoadingWallet) {
          emit(s);
        }
      }
    }
  }

  Future<void> _onProcessPayment(
    ProcessPayment event,
    Emitter<BuyNowState> emit,
  ) async {
    if (state is! BuyNowLoaded) return;
    final s = state as BuyNowLoaded;
    
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(BuyNowError('User not authenticated', paymentMethod: s.paymentMethod, walletBalance: s.walletBalance));
      return;
    }

    emit(BuyNowProcessing(paymentMethod: s.paymentMethod, walletBalance: s.walletBalance));

    try {
      // Check wallet balance
      if (s.paymentMethod == 'wallet') {
        final wallet = await getWalletUseCase(userId);
        if (wallet == null || wallet.balance < s.totalAmount) {
          emit(BuyNowError(
            'Insufficient wallet balance',
            isInsufficientBalance: true,
            paymentMethod: s.paymentMethod,
            walletBalance: wallet?.balance ?? 0.0,
          ));
          return;
        }
      }

      currentOrderId = DateTime.now().millisecondsSinceEpoch.toString();
      currentOrder = OrderEntity(
        id: currentOrderId!,
        product: s.product,
        quantity: s.quantity,
        totalAmount: s.totalAmount,
        status: 'pending',
        paymentMethod: s.paymentMethod,
        createdAt: DateTime.now(),
      );
      await createOrderUseCase(currentOrder!);

      if (s.paymentMethod == 'wallet') {
        // Deduct
        await deductMoneyUseCase(
          userId: userId,
          amount: s.totalAmount,
          description: 'Quick Buy: ${s.product.name}',
          orderId: currentOrderId!,
        );
        await updateOrderStatusUseCase(currentOrderId!, 'paid', 'wallet_payment');
        await reduceProductStockUseCase(s.product.id, s.quantity);
        
        emit(BuyNowPaymentSuccess('wallet_payment', currentOrderId!, paymentMethod: s.paymentMethod, walletBalance: s.walletBalance));
      } else if (s.paymentMethod == 'cod') {
        // COD
        await updateOrderStatusUseCase(currentOrderId!, 'pending', 'cod_payment');
        await reduceProductStockUseCase(s.product.id, s.quantity);
        
        emit(BuyNowPaymentSuccess('cod_payment', currentOrderId!, paymentMethod: s.paymentMethod, walletBalance: s.walletBalance));
      } else {
        // Razorpay
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
      }
    } catch (e) {
      emit(BuyNowError('Failed to start payment: $e', paymentMethod: s.paymentMethod, walletBalance: s.walletBalance));
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

      emit(BuyNowPaymentSuccess(event.paymentId, event.orderId, paymentMethod: state.paymentMethod, walletBalance: state.walletBalance));
    } catch (e) {
      emit(BuyNowError('Payment saved, but order update failed: $e', paymentMethod: state.paymentMethod, walletBalance: state.walletBalance));
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
    emit(BuyNowError(event.error, paymentMethod: state.paymentMethod, walletBalance: state.walletBalance));
  }

  void _onRetryPayment(RetryPayment event, Emitter<BuyNowState> emit) {
    if (currentOrder == null) return; // safety

    updateOrderStatusUseCase(currentOrderId!, 'retrying', null);

    if (state is BuyNowLoaded) {
      final s = state as BuyNowLoaded;
      emit(
        s.copyWith(
          product: currentOrder!.product,
          quantity: currentOrder!.quantity,
          totalAmount: currentOrder!.totalAmount,
        ),
      );
    }

    add(const ProcessPayment());
  }

  @override
  Future<void> close() {
    currentOrderId = null;
    currentOrder = null;
    return super.close();
  }
}
