import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/data/model/product_model.dart';

class OrderModel extends OrderEntity {
  OrderModel({
    required super.id,
    required super.product,
    required super.quantity,
    required super.totalAmount,
    required super.status,
    required super.createdAt,
    super.razorpayPaymentId,
    super.razorpayOrderId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'productId': product.id,
    'productName': product.name,
    'productImage': product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
    'productCategory': product.category,
    'unitPrice': product.price,
    'quantity': quantity,
    'totalAmount': totalAmount,
    'status': status,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    if (razorpayPaymentId != null) 'razorpayPaymentId': razorpayPaymentId,
    if (razorpayOrderId != null) 'razorpayOrderId': razorpayOrderId,
  };

  factory OrderModel.fromMap(Map<String, dynamic> data) {
    return OrderModel(
      id: data['id'] ?? '',
      product: ProductModel(
        id: data['productId'] ?? '',
        name: data['productName'] ?? '',
        category: data['productCategory'] ?? '',
        price: (data['unitPrice'] as num).toInt(),
        imageUrls: [data['productImage'] ?? ''],
        quantity: 0, // stock quantity — not relevant in order context
        unit: '',
      ),
      quantity: (data['quantity'] as num).toInt(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      status: data['status'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      razorpayPaymentId: data['razorpayPaymentId'],
      razorpayOrderId: data['razorpayOrderId'],
    );
  }

  factory OrderModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromMap(data);
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      product: ProductModel.fromEntity(entity.product),
      quantity: entity.quantity,
      totalAmount: entity.totalAmount,
      status: entity.status,
      createdAt: entity.createdAt,
      razorpayPaymentId: entity.razorpayPaymentId,
      razorpayOrderId: entity.razorpayOrderId,
    );
  }
}
