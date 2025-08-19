import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/bloc/orders_bloc.dart';

class OrderErrorState extends StatelessWidget {
  final String message;

  const OrderErrorState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: redColor),
          const SizedBox(height: 16),
          Text(
            'Failed to load order history',
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
