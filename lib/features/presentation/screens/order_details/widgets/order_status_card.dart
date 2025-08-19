import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/order_entity.dart';

class OrderStatusCard extends StatelessWidget {
  final OrderEntity order;

  const OrderStatusCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(order.status);

    return Card(
      color: whiteColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(order.status),
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusDisplayText(order.status),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Order ID: #${order.id.substring(order.id.length - 8)}',
              style: TextStyle(fontSize: 14, color: grey600),
            ),
            Text(
              'Placed on: ${_formatDateTime(order.createdAt)}',
              style: TextStyle(fontSize: 14, color: grey600),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.indigo;
      case 'accepted':
        return Colors.teal;
      case 'shipped':
        return Colors.blue;
      case 'outfordelivery':
        return Colors.deepOrange;
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return redColor;
      case 'cancelled':
        return Colors.grey;
      case 'retrying':
        return Colors.indigo;
      default:
        return grey600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.payment;
      case 'accepted':
        return Icons.task_alt;
      case 'shipped':
        return Icons.local_shipping;
      case 'outfordelivery':
        return Icons.directions_bike;
      case 'delivered':
        return Icons.home_filled;
      case 'pending':
        return Icons.access_time;
      case 'failed':
        return Icons.error;
      case 'cancelled':
        return Icons.cancel;
      case 'retrying':
        return Icons.refresh;
      default:
        return Icons.info;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Payment Completed';
      case 'accepted':
        return 'Order Accepted';
      case 'shipped':
        return 'Order Shipped';
      case 'outfordelivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Order Delivered';
      case 'pending':
        return 'Order Pending';
      case 'failed':
        return 'Order Failed';
      case 'cancelled':
        return 'Order Cancelled';
      case 'retrying':
        return 'Payment Retrying';
      default:
        return 'Order ${status.toUpperCase()}';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
