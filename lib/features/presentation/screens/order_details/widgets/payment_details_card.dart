import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/order_entity.dart';

class PaymentDetailsCard extends StatelessWidget {
  final OrderEntity order;

  const PaymentDetailsCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: whiteColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Payment Method', 'Razorpay'),
            if (order.razorpayPaymentId != null)
              _buildInfoRow('Payment ID', order.razorpayPaymentId!),
            _buildInfoRow(
              'Payment Status',
              _getPaymentStatusText(order.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: grey600)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentStatusText(String orderStatus) {
    switch (orderStatus.toLowerCase()) {
      case 'paid':
      case 'accepted':
      case 'shipped':
      case 'outfordelivery':
      case 'delivered':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      case 'retrying':
        return 'Retrying';
      case 'pending':
      default:
        return 'Pending';
    }
  }
}
