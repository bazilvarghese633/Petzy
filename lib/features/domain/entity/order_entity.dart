import 'package:petzy/features/domain/entity/product_entity.dart';

class OrderEntity {
  final String id;
  final ProductEntity product;
  final int quantity;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;

  OrderEntity({
    required this.id,
    required this.product,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.razorpayPaymentId,
    this.razorpayOrderId,
  });

  OrderEntity copyWith({
    String? id,
    ProductEntity? product,
    int? quantity,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
    String? razorpayPaymentId,
    String? razorpayOrderId,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
    );
  }
}
