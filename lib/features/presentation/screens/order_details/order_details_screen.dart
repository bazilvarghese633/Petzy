import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/domain/repository/product_repository.dart';
import 'package:petzy/features/domain/repository/order_repository.dart';
import 'package:petzy/features/domain/repository/wallet_repository.dart';
import 'package:petzy/features/presentation/bloc/order_details_bloc.dart';
import 'package:petzy/features/presentation/bloc/order_cancel_bloc.dart';
import 'package:petzy/features/presentation/screens/order_details/widgets/order_status_card.dart';
import 'package:petzy/features/presentation/screens/order_details/widgets/product_details_card.dart';
import 'package:petzy/features/presentation/screens/order_details/widgets/order_info_card.dart';
import 'package:petzy/features/presentation/screens/order_details/widgets/payment_details_card.dart';
import 'package:petzy/features/presentation/screens/order_details/widgets/order_action_buttons.dart';
import 'package:petzy/features/presentation/screens/order_details/widgets/order_error_state.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderDetailsBloc>().add(LoadOrderDetails(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => OrderCancelBloc(
                orderRepository: context.read<OrderRepository>(),
                walletRepository: context.read<WalletRepository>(),
                productRepository: context.read<ProductRepository>(),
                firebaseAuth: FirebaseAuth.instance,
              ),
        ),
      ],
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: const Text(
            'Order Details',
            style: TextStyle(fontWeight: FontWeight.bold, color: brownColr),
          ),
          backgroundColor: whiteColor,
          foregroundColor: appTitleColor,
          centerTitle: true,
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<OrderCancelBloc, OrderCancelState>(
              listener: (context, state) {
                if (state is OrderCancelSuccess) {
                  // Refresh order details after successful cancellation
                  context.read<OrderDetailsBloc>().add(
                    LoadOrderDetails(widget.orderId),
                  );

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: 'OK',
                        textColor: whiteColor,
                        onPressed: () {},
                      ),
                    ),
                  );
                } else if (state is OrderCancelError) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: redColor,
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: 'Retry',
                        textColor: whiteColor,
                        onPressed: () {},
                      ),
                    ),
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
            builder: (context, state) {
              if (state is OrderDetailsLoading) {
                return Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              } else if (state is OrderDetailsLoaded) {
                return _buildOrderDetails(context, state.order);
              } else if (state is OrderDetailsError) {
                return OrderErrorState(
                  orderId: widget.orderId,
                  message: state.message,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, OrderEntity order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Status Card
          OrderStatusCard(order: order),
          const SizedBox(height: 16),

          // Product Details Card
          ProductDetailsCard(order: order),
          const SizedBox(height: 16),

          // Order Information Card
          OrderInfoCard(order: order),
          const SizedBox(height: 16),

          // Payment Details Card
          PaymentDetailsCard(order: order),
          const SizedBox(height: 24),

          // Action Buttons
          OrderActionButtons(order: order),
        ],
      ),
    );
  }
}
