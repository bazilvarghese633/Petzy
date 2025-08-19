import 'package:equatable/equatable.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/presentation/bloc/buy_now_event.dart';

abstract class BuyNowState extends Equatable {
  const BuyNowState();

  @override
  List<Object?> get props => [];
}

class BuyNowInitial extends BuyNowState {}

class BuyNowLoaded extends BuyNowState {
  final ProductEntity product;
  final int quantity;
  final double totalAmount;

  const BuyNowLoaded({
    required this.product,
    required this.quantity,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [product, quantity, totalAmount];

  BuyNowLoaded copyWith({
    ProductEntity? product,
    int? quantity,
    double? totalAmount,
  }) {
    return BuyNowLoaded(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

class RetryPayment extends BuyNowEvent {
  const RetryPayment();
}

class BuyNowProcessing extends BuyNowState {}

class BuyNowPaymentSuccess extends BuyNowState {
  final String paymentId;
  final String orderId;

  const BuyNowPaymentSuccess(this.paymentId, this.orderId);

  @override
  List<Object?> get props => [paymentId, orderId];
}

class BuyNowError extends BuyNowState {
  final String message;

  const BuyNowError(this.message);

  @override
  List<Object?> get props => [message];
}
