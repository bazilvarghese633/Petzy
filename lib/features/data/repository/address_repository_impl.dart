import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entity/address.dart';
import '../../domain/repository/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AddressRepositoryImpl({required this.firestore, required this.auth});

  @override
  Future<void> addAddress(Address address) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    await firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .add(address.toMap());
  }

  @override
  Stream<List<Address>> getAddresses(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Address.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  @override
  Future<void> selectAddress(String uid, String addressId) async {
    final userRef = firestore
        .collection('users')
        .doc(uid)
        .collection('addresses');
    final snapshot = await userRef.get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'isSelected': doc.id == addressId});
    }
  }

  Future<void> deleteAddress(String uid, String addressId) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  Future<void> updateAddress(String uid, Address address) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(address.id)
        .update(address.toMap());
  }
}
