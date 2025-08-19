import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/domain/usecase/clear_cart.dart';
import 'package:petzy/features/domain/usecase/create_order.dart';
import 'package:petzy/features/domain/usecase/get_profile.dart';
import 'package:petzy/features/domain/usecase/reduce_product_stock.dart';
import 'package:petzy/features/domain/usecase/update_order_status.dart';
import 'package:petzy/features/presentation/bloc/cart_bloc.dart';
import 'package:petzy/features/presentation/bloc/cart_event.dart';
import 'package:petzy/features/presentation/bloc/cart_state.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => [];
}

class StartCheckout extends CheckoutEvent {
  const StartCheckout();
}

class PaymentSuccessMulti extends CheckoutEvent {
  final String paymentId;
  const PaymentSuccessMulti(this.paymentId);
  @override
  List<Object?> get props => [paymentId];
}

class PaymentFailedMulti extends CheckoutEvent {
  final String message;
  const PaymentFailedMulti(this.message);
  @override
  List<Object?> get props => [message];
}

abstract class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutProcessing extends CheckoutState {}

class CheckoutPaid extends CheckoutState {
  final List<String> orderIds;
  const CheckoutPaid(this.orderIds);
  @override
  List<Object?> get props => [orderIds];
}

class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError(this.message);
  @override
  List<Object?> get props => [message];
}

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CartBloc cartBloc;
  final CreateOrderUseCase createOrderUseCase;
  final ReduceProductStockUseCase reduceProductStockUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final ClearCartUseCase clearCartUseCase;
  final GetProfileUseCase getProfileUseCase;
  final Razorpay razorpay;
  final FirebaseAuth firebaseAuth;

  List<String> createdOrderIds = [];

  CheckoutBloc({
    required this.cartBloc,
    required this.createOrderUseCase,
    required this.reduceProductStockUseCase,
    required this.updateOrderStatusUseCase,
    required this.clearCartUseCase,
    required this.getProfileUseCase,
    required this.razorpay,
    required this.firebaseAuth,
  }) : super(CheckoutInitial()) {
    on<StartCheckout>(_onStartCheckout);
    on<PaymentSuccessMulti>(_onPaymentSuccessMulti);
    on<PaymentFailedMulti>(_onPaymentFailedMulti);
  }

  Future<void> _onStartCheckout(
    StartCheckout event,
    Emitter<CheckoutState> emit,
  ) async {
    if (cartBloc.state is! CartLoaded) return;

    final cartState = cartBloc.state as CartLoaded;
    if (cartState.items.isEmpty) return;

    emit(CheckoutProcessing());
    createdOrderIds.clear();

    try {
      final grandTotal = cartState.items.fold<double>(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );

      for (final cartItem in cartState.items) {
        final orderId =
            DateTime.now().millisecondsSinceEpoch.toString() +
            '_${cartState.items.indexOf(cartItem)}';
        createdOrderIds.add(orderId);

        final product = ProductEntity(
          id: cartItem.id,
          name: cartItem.name,
          imageUrls: [cartItem.imageUrl],
          price: cartItem.price.toInt(),
          category: 'General',
          quantity: 0,
          unit: 'pcs',
        );

        final order = OrderEntity(
          id: orderId,
          product: product,
          quantity: cartItem.quantity,
          totalAmount: cartItem.price * cartItem.quantity,
          status: 'pending',
          createdAt: DateTime.now(),
        );

        await createOrderUseCase(order);
      }

      final user = firebaseAuth.currentUser;
      String contact = '9999999999';
      String email = 'user@example.com';
      String name = 'Guest User';

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
        } catch (e) {
          print('Error fetching profile: $e');
        }
      }

      // Open Razorpay
      final options = {
        'key': 'rzp_test_zGUWcHp8eqJukI',
        'amount': (grandTotal * 100).toInt(),
        'currency': 'INR',
        'name': 'Petzy',
        'description': 'Cart Checkout - ${cartState.items.length} items',
        'prefill': {'contact': contact, 'email': email, 'name': name},
        'theme': {'color': '#EF8A45'},
      };

      razorpay.open(options);
    } catch (e) {
      emit(CheckoutError('Failed to start checkout: $e'));
    }
  }

  Future<void> _onPaymentSuccessMulti(
    PaymentSuccessMulti event,
    Emitter<CheckoutState> emit,
  ) async {
    try {
      final cartState = cartBloc.state as CartLoaded;

      for (int i = 0; i < cartState.items.length; i++) {
        final cartItem = cartState.items[i];
        final orderId = createdOrderIds[i];

        await updateOrderStatusUseCase(orderId, 'paid', event.paymentId);

        await reduceProductStockUseCase(cartItem.id, cartItem.quantity);
      }

      await clearCartUseCase();

      cartBloc.add(LoadCart());

      emit(CheckoutPaid(createdOrderIds));
    } catch (e) {
      emit(
        CheckoutError('Payment successful but failed to update records: $e'),
      );
    }
  }

  Future<void> _onPaymentFailedMulti(
    PaymentFailedMulti event,
    Emitter<CheckoutState> emit,
  ) async {
    for (final orderId in createdOrderIds) {
      try {
        await updateOrderStatusUseCase(orderId, 'failed', null);
      } catch (e) {
        print('Error updating failed order $orderId: $e');
      }
    }

    emit(CheckoutError(event.message));
  }

  @override
  Future<void> close() {
    createdOrderIds.clear();
    return super.close();
  }
}
