import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/domain/usecase/get_order_by_id.dart';

abstract class OrderDetailsEvent extends Equatable {
  const OrderDetailsEvent();
  @override
  List<Object?> get props => [];
}

class LoadOrderDetails extends OrderDetailsEvent {
  final String orderId;
  const LoadOrderDetails(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

abstract class OrderDetailsState extends Equatable {
  const OrderDetailsState();
  @override
  List<Object?> get props => [];
}

class OrderDetailsInitial extends OrderDetailsState {}

class OrderDetailsLoading extends OrderDetailsState {}

class OrderDetailsLoaded extends OrderDetailsState {
  final OrderEntity order;
  const OrderDetailsLoaded(this.order);
  @override
  List<Object?> get props => [order];
}

class OrderDetailsError extends OrderDetailsState {
  final String message;
  const OrderDetailsError(this.message);
  @override
  List<Object?> get props => [message];
}

class OrderDetailsBloc extends Bloc<OrderDetailsEvent, OrderDetailsState> {
  final GetOrderByIdUseCase getOrderByIdUseCase;

  OrderDetailsBloc({required this.getOrderByIdUseCase})
    : super(OrderDetailsInitial()) {
    on<LoadOrderDetails>(_onLoadOrderDetails);
  }

  void _onLoadOrderDetails(
    LoadOrderDetails event,
    Emitter<OrderDetailsState> emit,
  ) async {
    emit(OrderDetailsLoading());
    try {
      final order = await getOrderByIdUseCase(event.orderId);
      if (order != null) {
        emit(OrderDetailsLoaded(order));
      } else {
        emit(const OrderDetailsError('Order not found'));
      }
    } catch (e) {
      emit(OrderDetailsError(e.toString()));
    }
  }
}
