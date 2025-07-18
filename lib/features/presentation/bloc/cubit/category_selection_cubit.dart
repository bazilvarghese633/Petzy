import 'package:flutter_bloc/flutter_bloc.dart';

class CategorySelectionState {
  final List<String> selected;
  final String searchText;

  CategorySelectionState({required this.selected, required this.searchText});

  CategorySelectionState copyWith({
    List<String>? selected,
    String? searchText,
  }) {
    return CategorySelectionState(
      selected: selected ?? this.selected,
      searchText: searchText ?? this.searchText,
    );
  }
}

class CategorySelectionCubit extends Cubit<CategorySelectionState> {
  CategorySelectionCubit(List<String> initiallySelected)
    : super(
        CategorySelectionState(
          selected: List.from(initiallySelected),
          searchText: '',
        ),
      );

  void toggleCategory(String category) {
    final current = List<String>.from(state.selected);
    if (current.contains(category)) {
      current.remove(category);
    } else {
      current.add(category);
    }
    emit(state.copyWith(selected: current));
  }

  void updateSearchText(String text) {
    emit(state.copyWith(searchText: text));
  }
}
