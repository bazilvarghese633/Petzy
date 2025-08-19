import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/bloc/orderh_filter_bloc.dart';
import 'package:petzy/features/presentation/bloc/orders_bloc.dart';
import 'package:petzy/features/presentation/screens/order_history/widgets/order_filter_section.dart';
import 'package:petzy/features/presentation/screens/order_history/widgets/order_list_view.dart';
import 'package:petzy/features/presentation/screens/order_history/widgets/order_error_state.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final List<String> _filterOptions = [
    'All',
    'This Month',
    'Last 3 Months',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(LoadOrders());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderFilterBloc(),
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            // Filter Section
            BlocBuilder<OrderFilterBloc, OrderFilterState>(
              builder: (context, filterState) {
                return OrderFilterSection(
                  selectedFilter: filterState.selectedFilter,
                  filterOptions: _filterOptions,
                  onFilterChanged: (filter) {
                    context.read<OrderFilterBloc>().add(ChangeFilter(filter));
                  },
                );
              },
            ),

            // Orders List
            Expanded(
              child: MultiBlocListener(
                listeners: [
                  // Listen to orders loading and update filter bloc
                  BlocListener<OrdersBloc, OrdersState>(
                    listener: (context, state) {
                      if (state is OrdersLoaded) {
                        context.read<OrderFilterBloc>().add(
                          UpdateOrdersList(state.orders),
                        );
                      }
                    },
                  ),
                ],
                child: BlocBuilder<OrdersBloc, OrdersState>(
                  builder: (context, ordersState) {
                    if (ordersState is OrdersLoading) {
                      return Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    } else if (ordersState is OrdersLoaded) {
                      return BlocBuilder<OrderFilterBloc, OrderFilterState>(
                        builder: (context, filterState) {
                          return OrderListView(
                            orders: filterState.filteredOrders,
                          );
                        },
                      );
                    } else if (ordersState is OrdersError) {
                      return OrderErrorState(message: ordersState.message);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Order History',
        style: TextStyle(fontWeight: FontWeight.bold, color: brownColr),
      ),
      backgroundColor: whiteColor,
      foregroundColor: appTitleColor,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: secondaryColor,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
