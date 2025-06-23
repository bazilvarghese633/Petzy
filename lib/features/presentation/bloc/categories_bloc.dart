// category_event.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/domain/usecase/fetch_categories_usecase.dart';

abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {}

class SelectCategory extends CategoryEvent {
  final String category;
  SelectCategory(this.category);
}

// category_state.dart
abstract class CategoryState {}

class CategoriesInitial extends CategoryState {}

class CategoriesLoading extends CategoryState {}

class CategoriesLoaded extends CategoryState {
  final List<String> all;
  final String selected;
  CategoriesLoaded(this.all, this.selected);
}

class CategoriesError extends CategoryState {
  final String message;
  CategoriesError(this.message);
}

// categories_bloc.dart
class CategoriesBloc extends Bloc<CategoryEvent, CategoryState> {
  final FetchCategoriesUseCase getCategories;
  CategoriesBloc(this.getCategories) : super(CategoriesInitial()) {
    on<LoadCategories>((e, emit) async {
      emit(CategoriesLoading());
      try {
        final cats = await getCategories();
        emit(CategoriesLoaded(cats, 'All'));
      } catch (e) {
        emit(CategoriesError('Error loading categories'));
      }
    });
    on<SelectCategory>((e, emit) {
      final st = state;
      if (st is CategoriesLoaded) {
        emit(CategoriesLoaded(st.all, e.category));
      }
    });
  }
}
