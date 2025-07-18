import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/data/repository/favorites_repository.dart';
import 'package:petzy/features/domain/entity/fevorite.dart';

class FavoritesCubit extends Cubit<List<Favorite>> {
  final FavoritesRepository repository;
  StreamSubscription<List<Favorite>>? _favoritesSub;
  StreamSubscription<User?>? _authSub;

  FavoritesCubit(this.repository) : super([]) {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _subscribeToFavorites(user.uid);
      } else {
        _clearFavorites();
      }
    });
  }

  void _subscribeToFavorites(String uid) {
    _favoritesSub?.cancel();
    _favoritesSub = repository.getFavorites(uid).listen((favorites) {
      if (FirebaseAuth.instance.currentUser?.uid == uid) {
        emit(favorites);
      }
    });
  }

  void _clearFavorites() {
    _favoritesSub?.cancel();
    emit([]);
  }

  Future<void> toggleFavorite(Favorite fav) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await repository.toggleFavorite(uid, fav);
    }
  }

  bool isFavorited(String productId) {
    return state.any((fav) => fav.productId == productId);
  }

  @override
  Future<void> close() {
    _favoritesSub?.cancel();
    _authSub?.cancel();
    return super.close();
  }
}
