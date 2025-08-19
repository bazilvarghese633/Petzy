import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/domain/repository/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  OrderRepositoryImpl({required this.firestore, required this.auth});

  @override
  Future<String> createOrder(OrderEntity order) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final orderData = {
        'id': order.id,
        'productId': order.product.id,
        'productName': order.product.name,
        'productImage':
            order.product.imageUrls.isNotEmpty
                ? order.product.imageUrls.first
                : '',
        'productCategory': order.product.category,
        'quantity': order.quantity,
        'unitPrice': order.product.price,
        'totalAmount': order.totalAmount,
        'status': order.status,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(order.id)
          .set(orderData);

      return order.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    String status,
    String? paymentId,
  ) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (paymentId != null) {
        updateData['razorpayPaymentId'] = paymentId;
      }

      await firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getUserOrders() async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final snapshot =
          await firestore
              .collection('users')
              .doc(userId)
              .collection('orders')
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderEntity(
          id: data['id'],
          product: ProductEntity(
            id: data['productId'],
            name: data['productName'],
            category: data['productCategory'] ?? '',
            price: (data['unitPrice'] as num).toInt(),
            imageUrls: [data['productImage'] ?? ''],
            quantity: 0, // This is order quantity, not stock
            unit: '',
          ),
          quantity: data['quantity'],
          totalAmount: (data['totalAmount'] as num).toDouble(),
          status: data['status'],
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          razorpayPaymentId: data['razorpayPaymentId'],
          razorpayOrderId: data['razorpayOrderId'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user orders: $e');
    }
  }

  @override
  Future<OrderEntity?> getOrderById(String orderId) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final doc =
          await firestore
              .collection('users')
              .doc(userId)
              .collection('orders')
              .doc(orderId)
              .get();

      if (!doc.exists) return null;
      final data = doc.data()!;

      return OrderEntity(
        id: data['id'],
        product: ProductEntity(
          id: data['productId'],
          name: data['productName'],
          category: data['productCategory'] ?? '',
          price: (data['unitPrice'] as num).toInt(),
          imageUrls: [data['productImage'] ?? ''],
          quantity: 0,
          unit: '',
        ),
        quantity: data['quantity'],
        totalAmount: (data['totalAmount'] as num).toDouble(),
        status: data['status'],
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        razorpayPaymentId: data['razorpayPaymentId'],
        razorpayOrderId: data['razorpayOrderId'],
      );
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  @override
  Future<void> cancelOrder(String orderId, String userId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update({
            'status': 'cancelled',
            'updatedAt': FieldValue.serverTimestamp(),
            'cancelledAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  @override
  Future<void> processRefund(
    String orderId,
    String userId,
    double amount,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update({
            'refundProcessed': true,
            'refundAmount': amount,
            'refundedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to process refund: $e');
    }
  }

  @override
  Stream<List<OrderEntity>> watchUserOrders() {
    final userId = auth.currentUser?.uid;
    if (userId == null) {
      return Stream.error(Exception('User not authenticated'));
    }

    return firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return OrderEntity(
              id: data['id'],
              product: ProductEntity(
                id: data['productId'],
                name: data['productName'],
                category: data['productCategory'] ?? '',
                price: (data['unitPrice'] as num).toInt(),
                imageUrls: [data['productImage'] ?? ''],
                quantity: 0,
                unit: '',
              ),
              quantity: data['quantity'],
              totalAmount: (data['totalAmount'] as num).toDouble(),
              status: data['status'],
              createdAt:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              razorpayPaymentId: data['razorpayPaymentId'],
              razorpayOrderId: data['razorpayOrderId'],
            );
          }).toList();
        });
  }
}
