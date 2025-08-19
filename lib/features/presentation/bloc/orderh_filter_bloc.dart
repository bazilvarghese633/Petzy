import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/domain/entity/order_entity.dart';

// Events
abstract class OrderFilterEvent {}

class ChangeFilter extends OrderFilterEvent {
  final String filter;
  ChangeFilter(this.filter);
}

class UpdateOrdersList extends OrderFilterEvent {
  final List<OrderEntity> orders;
  UpdateOrdersList(this.orders);
}

// States
class OrderFilterState {
  final String selectedFilter;
  final List<OrderEntity> filteredOrders;
  final List<OrderEntity> allOrders;

  const OrderFilterState({
    required this.selectedFilter,
    required this.filteredOrders,
    required this.allOrders,
  });

  OrderFilterState copyWith({
    String? selectedFilter,
    List<OrderEntity>? filteredOrders,
    List<OrderEntity>? allOrders,
  }) {
    return OrderFilterState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      allOrders: allOrders ?? this.allOrders,
    );
  }
}

// BLoC
class OrderFilterBloc extends Bloc<OrderFilterEvent, OrderFilterState> {
  OrderFilterBloc()
    : super(
        const OrderFilterState(
          selectedFilter: 'All',
          filteredOrders: [],
          allOrders: [],
        ),
      ) {
    on<ChangeFilter>(_onChangeFilter);
    on<UpdateOrdersList>(_onUpdateOrdersList);
  }

  void _onChangeFilter(ChangeFilter event, Emitter<OrderFilterState> emit) {
    final filteredOrders = _filterOrdersByDate(state.allOrders, event.filter);
    emit(
      state.copyWith(
        selectedFilter: event.filter,
        filteredOrders: filteredOrders,
      ),
    );
  }

  void _onUpdateOrdersList(
    UpdateOrdersList event,
    Emitter<OrderFilterState> emit,
  ) {
    final filteredOrders = _filterOrdersByDate(
      event.orders,
      state.selectedFilter,
    );
    emit(
      state.copyWith(allOrders: event.orders, filteredOrders: filteredOrders),
    );
  }

  List<OrderEntity> _filterOrdersByDate(
    List<OrderEntity> orders,
    String filter,
  ) {
    final now = DateTime.now();

    switch (filter) {
      case 'This Month':
        return orders.where((order) {
          return order.createdAt.year == now.year &&
              order.createdAt.month == now.month;
        }).toList();

      case 'Last 3 Months':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return orders.where((order) {
          return order.createdAt.isAfter(threeMonthsAgo);
        }).toList();

      case 'This Year':
        return orders.where((order) {
          return order.createdAt.year == now.year;
        }).toList();

      default: // 'All'
        return orders;
    }
  }
}
