import 'package:flutter_bloc/flutter_bloc.dart';

class SearchCubit extends Cubit<String> {
  SearchCubit() : super('');

  void updateQuery(String query) {
    emit(query);
  }

  void clearQuery() {
    emit('');
  }
}
