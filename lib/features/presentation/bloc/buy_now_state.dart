import 'package:equatable/equatable.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/presentation/bloc/buy_now_event.dart';

abstract class BuyNowState extends Equatable {
  final String paymentMethod;
  final double walletBalance;

  const BuyNowState({
    this.paymentMethod = 'razorpay',
    this.walletBalance = 0.0,
  });

  @override
  List<Object?> get props => [paymentMethod, walletBalance];
}

class BuyNowInitial extends BuyNowState {}

class BuyNowLoadingWallet extends BuyNowState {
  const BuyNowLoadingWallet({
    super.paymentMethod,
    super.walletBalance,
  });
}

class BuyNowLoaded extends BuyNowState {
  final ProductEntity product;
  final int quantity;
  final double totalAmount;

  const BuyNowLoaded({
    required this.product,
    required this.quantity,
    required this.totalAmount,
    super.paymentMethod,
    super.walletBalance,
  });

  @override
  List<Object?> get props => [product, quantity, totalAmount, paymentMethod, walletBalance];

  BuyNowLoaded copyWith({
    ProductEntity? product,
    int? quantity,
    double? totalAmount,
    String? paymentMethod,
    double? walletBalance,
  }) {
    return BuyNowLoaded(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }
}

class RetryPayment extends BuyNowEvent {
  const RetryPayment();
}

class BuyNowProcessing extends BuyNowState {
  const BuyNowProcessing({
    super.paymentMethod,
    super.walletBalance,
  });
}

class BuyNowPaymentSuccess extends BuyNowState {
  final String paymentId;
  final String orderId;

  const BuyNowPaymentSuccess(
    this.paymentId,
    this.orderId, {
    super.paymentMethod,
    super.walletBalance,
  });

  @override
  List<Object?> get props => [paymentId, orderId, paymentMethod, walletBalance];
}

class BuyNowError extends BuyNowState {
  final String message;
  final bool isInsufficientBalance;

  const BuyNowError(
    this.message, {
    this.isInsufficientBalance = false,
    super.paymentMethod,
    super.walletBalance,
  });

  @override
  List<Object?> get props => [message, isInsufficientBalance, paymentMethod, walletBalance];
}
