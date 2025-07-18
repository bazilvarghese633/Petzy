import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/domain/entity/fevorite.dart';

class FavoritesRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FavoritesRepository(this.firestore, this.auth);

  Future<void> toggleFavorite(String uid, Favorite fav) async {
    final docRef = firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(fav.productId);

    final snapshot = await docRef.get();

    if (snapshot.exists) {
      await docRef.delete(); // Unfavorite
    } else {
      await docRef.set(fav.toMap()); // Add favorite
    }
  }

  Stream<List<Favorite>> getFavorites(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Favorite.fromMap(doc.data())).toList(),
        );
  }
}
