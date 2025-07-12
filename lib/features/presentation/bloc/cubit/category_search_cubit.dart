// category_search_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class CategorySearchCubit extends Cubit<String> {
  CategorySearchCubit() : super('');

  void updateQuery(String query) => emit(query.trim().toLowerCase());
  void clearQuery() => emit('');
}
