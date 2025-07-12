// product_detail_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ProductDetailEvent {}

class IncrementQuantity extends ProductDetailEvent {}

class DecrementQuantity extends ProductDetailEvent {}

class UpdatePageIndex extends ProductDetailEvent {
  final int index;
  UpdatePageIndex(this.index);
}

// State
class ProductDetailState {
  final int quantity;
  final int currentPage;

  ProductDetailState({required this.quantity, required this.currentPage});

  ProductDetailState copyWith({int? quantity, int? currentPage}) {
    return ProductDetailState(
      quantity: quantity ?? this.quantity,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Bloc
class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc() : super(ProductDetailState(quantity: 1, currentPage: 0)) {
    on<IncrementQuantity>((event, emit) {
      emit(state.copyWith(quantity: state.quantity + 1));
    });

    on<DecrementQuantity>((event, emit) {
      if (state.quantity > 1) {
        emit(state.copyWith(quantity: state.quantity - 1));
      }
    });

    on<UpdatePageIndex>((event, emit) {
      emit(state.copyWith(currentPage: event.index));
    });
  }
}
