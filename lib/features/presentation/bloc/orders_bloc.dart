import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/domain/repository/order_repository.dart';
import 'package:petzy/features/domain/usecase/get_user_orders.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();
  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersEvent {}

class RefreshOrders extends OrdersEvent {}

class WatchOrders extends OrdersEvent {}

class OrdersUpdated extends OrdersEvent {
  final List<OrderEntity> orders;
  const OrdersUpdated(this.orders);
  @override
  List<Object?> get props => [orders];
}

abstract class OrdersState extends Equatable {
  const OrdersState();
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  const OrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);
  @override
  List<Object?> get props => [message];
}

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetUserOrdersUseCase getUserOrdersUseCase;
  final OrderRepository orderRepository;

  StreamSubscription<List<OrderEntity>>? _ordersSub;

  OrdersBloc({
    required this.getUserOrdersUseCase,
    required this.orderRepository,
  }) : super(OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<RefreshOrders>(_onRefreshOrders);
    on<WatchOrders>(_onWatchOrders);
    on<OrdersUpdated>(_onOrdersUpdated);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    try {
      final orders = await getUserOrdersUseCase();
      emit(OrdersLoaded(orders));
      add(WatchOrders());
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onRefreshOrders(
    RefreshOrders event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      final orders = await getUserOrdersUseCase();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  void _onWatchOrders(WatchOrders event, Emitter<OrdersState> emit) {
    _ordersSub?.cancel();
    _ordersSub = orderRepository.watchUserOrders().listen(
      (orders) => add(OrdersUpdated(orders)),
      onError: (error) => addError(error, StackTrace.current),
    );
  }

  void _onOrdersUpdated(OrdersUpdated event, Emitter<OrdersState> emit) {
    if (state is! OrdersLoaded ||
        (state as OrdersLoaded).orders != event.orders) {
      emit(OrdersLoaded(event.orders));
    }
  }

  @override
  Future<void> close() {
    _ordersSub?.cancel();
    return super.close();
  }
}
