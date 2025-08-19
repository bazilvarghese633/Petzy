import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/domain/usecase/get_order_by_id.dart';
import 'package:petzy/features/presentation/bloc/order_details_bloc.dart';
import 'package:petzy/features/presentation/bloc/orders_bloc.dart';
import 'package:petzy/features/presentation/screens/home_screen/widgets/custom_navbar.dart';
import 'package:petzy/features/presentation/screens/order_details/order_details_screen.dart';
import 'package:petzy/features/presentation/screens/order_history/order_history_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _MyOrdersScreen();
}

class _MyOrdersScreen extends State<OrderScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<OrdersBloc>().add(LoadOrders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold, color: brownColr),
        ),
        backgroundColor: whiteColor,
        foregroundColor: appTitleColor,
        centerTitle: true,
        actions: [
          // 🔥 NEW: Order History Button
          IconButton(
            icon: Icon(Icons.history, color: primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: grey600,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          } else if (state is OrdersLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(_filterActiveOrders(state.orders)),
                _buildOrdersList(_filterDeliveredOrders(state.orders)),
                _buildOrdersList(_filterCancelledOrders(state.orders)),
                _buildOrdersList(state.orders),
              ],
            );
          } else if (state is OrdersError) {
            return _buildErrorState(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {},
      ),
    );
  }

  // 🔥 NEW: Filter methods for different order statuses
  List<OrderEntity> _filterActiveOrders(List<OrderEntity> orders) {
    return orders.where((order) {
      final status = order.status.toLowerCase();
      return [
        'pending',
        'paid',
        'accepted',
        'shipped',
        'outfordelivery',
      ].contains(status);
    }).toList();
  }

  List<OrderEntity> _filterDeliveredOrders(List<OrderEntity> orders) {
    return orders.where((order) {
      final status = order.status.toLowerCase();
      return ['delivered', 'completed'].contains(status);
    }).toList();
  }

  List<OrderEntity> _filterCancelledOrders(List<OrderEntity> orders) {
    return orders.where((order) {
      final status = order.status.toLowerCase();
      return ['cancelled', 'failed'].contains(status);
    }).toList();
  }

  Widget _buildOrdersList(List<OrderEntity> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async {
        context.read<OrdersBloc>().add(LoadOrders());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(order: order);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: grey300),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start shopping to see your orders here',
            style: TextStyle(fontSize: 14, color: grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: redColor),
          const SizedBox(height: 16),
          Text(
            'Failed to load orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: redColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: grey600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<OrdersBloc>().add(LoadOrders());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: whiteColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderEntity order;

  const OrderCard({super.key, required this.order});

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
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => BlocProvider(
                  create:
                      (context) => OrderDetailsBloc(
                        getOrderByIdUseCase:
                            context.read<GetOrderByIdUseCase>(),
                      ),
                  child: OrderDetailsScreen(orderId: order.id),
                ),
          ),
        );
      },

      child: Card(
        color: whiteColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: primaryColor.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(order.id.length - 6)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: grey600,
                    ),
                  ),
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(fontSize: 12, color: grey600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Product Info
              Row(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      order.product.imageUrls.isNotEmpty
                          ? order.product.imageUrls.first
                          : '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: grey200,
                            child: Icon(
                              Icons.image_not_supported,
                              color: greyColor,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.product.category,
                          style: TextStyle(fontSize: 14, color: grey600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Qty: ${order.quantity}',
                          style: TextStyle(fontSize: 14, color: grey600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Price and Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(order.status).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(order.status),
                          size: 16,
                          color: _getStatusColor(order.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap for details',
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 12, color: primaryColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
