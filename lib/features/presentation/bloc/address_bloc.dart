import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repository/address_repository.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository repository;

  AddressBloc(this.repository) : super(AddressInitial()) {
    on<LoadAddresses>((event, emit) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        emit(AddressError("User not logged in"));
        return;
      }

      emit(AddressLoading());

      await emit.forEach(
        repository.getAddresses(uid),
        onData: (addresses) => AddressLoaded(addresses),
        onError: (e, _) => AddressError(e.toString()),
      );
    });

    on<AddAddress>((event, emit) async {
      await repository.addAddress(event.address);
    });

    on<SelectAddress>((event, emit) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await repository.selectAddress(uid, event.addressId);
      }
    });

    on<DeleteAddress>((event, emit) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await repository.deleteAddress(uid, event.addressId);
      }
    });

    on<UpdateAddress>((event, emit) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await repository.updateAddress(uid, event.updatedAddress);
      }
    });
  }
}
