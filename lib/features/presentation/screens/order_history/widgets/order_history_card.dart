import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/domain/usecase/get_order_by_id.dart';
import 'package:petzy/features/presentation/bloc/order_details_bloc.dart';
import 'package:petzy/features/presentation/screens/order_details/order_details_screen.dart';

class OrderHistoryCard extends StatelessWidget {
  final OrderEntity order;

  const OrderHistoryCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToOrderDetails(context),
      child: Card(
        color: whiteColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header with Date
              _buildOrderHeader(),
              const SizedBox(height: 12),

              // Product Info (Compact)
              _buildProductInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.id.substring(order.id.length - 6)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: secondaryColor,
              ),
            ),
            Text(
              _formatDate(order.createdAt),
              style: TextStyle(fontSize: 12, color: grey600),
            ),
          ],
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(order.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(order.status).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(order.status),
            size: 14,
            color: _getStatusColor(order.status),
          ),
          const SizedBox(width: 4),
          Text(
            order.status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(order.status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            order.product.imageUrls.isNotEmpty
                ? order.product.imageUrls.first
                : '',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  width: 50,
                  height: 50,
                  color: grey200,
                  child: Icon(
                    Icons.image_not_supported,
                    color: greyColor,
                    size: 20,
                  ),
                ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.product.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: secondaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Qty: ${order.quantity} • ₹${order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12, color: grey600),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: primaryColor, size: 20),
      ],
    );
  }

  void _navigateToOrderDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider(
              create:
                  (context) => OrderDetailsBloc(
                    getOrderByIdUseCase: context.read<GetOrderByIdUseCase>(),
                  ),
              child: OrderDetailsScreen(orderId: order.id),
            ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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
      default:
        return grey600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
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
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
