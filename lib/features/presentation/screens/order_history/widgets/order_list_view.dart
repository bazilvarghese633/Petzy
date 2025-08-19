import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/presentation/bloc/orders_bloc.dart';
import 'package:petzy/features/presentation/screens/order_history/widgets/order_history_card.dart';
import 'package:petzy/features/presentation/screens/order_history/widgets/order_empty_state.dart';

class OrderListView extends StatelessWidget {
  final List<OrderEntity> orders;

  const OrderListView({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const OrderEmptyState();
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
          return OrderHistoryCard(order: order);
        },
      ),
    );
  }
}
