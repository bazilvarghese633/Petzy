import 'package:flutter_bloc/flutter_bloc.dart';

class PriceSliderState {
  final double minPrice;
  final double maxPrice;

  PriceSliderState({required this.minPrice, required this.maxPrice});

  PriceSliderState copyWith({double? minPrice, double? maxPrice}) {
    return PriceSliderState(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

class PriceSliderCubit extends Cubit<PriceSliderState> {
  final double initialMin;
  final double initialMax;

  PriceSliderCubit(this.initialMin, this.initialMax)
    : super(PriceSliderState(minPrice: initialMin, maxPrice: initialMax));

  /// Called when slider is moved
  void updateRange(double min, double max) {
    emit(state.copyWith(minPrice: min, maxPrice: max));
  }

  /// Called when reset is triggered
  void resetRange() {
    emit(PriceSliderState(minPrice: initialMin, maxPrice: initialMax));
  }
}
