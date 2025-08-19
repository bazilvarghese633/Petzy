import 'package:equatable/equatable.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';

abstract class BuyNowEvent extends Equatable {
  const BuyNowEvent();

  @override
  List<Object?> get props => [];
}

class InitializeBuyNow extends BuyNowEvent {
  final ProductEntity product;
  final int quantity;

  const InitializeBuyNow(this.product, this.quantity);

  @override
  List<Object?> get props => [product, quantity];
}

class UpdateQuantity extends BuyNowEvent {
  final int quantity;

  const UpdateQuantity(this.quantity);

  @override
  List<Object?> get props => [quantity];
}

class ProcessPayment extends BuyNowEvent {
  const ProcessPayment();
}

class PaymentSuccess extends BuyNowEvent {
  final String paymentId;
  final String orderId;

  const PaymentSuccess(this.paymentId, this.orderId);

  @override
  List<Object?> get props => [paymentId, orderId];
}

class PaymentFailed extends BuyNowEvent {
  final String error;

  const PaymentFailed(this.error);

  @override
  List<Object?> get props => [error];
}
