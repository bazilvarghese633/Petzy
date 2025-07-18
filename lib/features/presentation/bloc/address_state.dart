import '../../domain/entity/address.dart';

abstract class AddressState {}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressLoaded extends AddressState {
  final List<Address> addresses;
  AddressLoaded(this.addresses);
}

class AddressError extends AddressState {
  final String message;
  AddressError(this.message);
}

class AddressOperationSuccess
    extends AddressState {} // optional, for add/edit/delete feedback
