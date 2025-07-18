import '../../domain/entity/address.dart';

abstract class AddressEvent {}

class LoadAddresses extends AddressEvent {}

class AddAddress extends AddressEvent {
  final Address address;
  AddAddress(this.address);
}

class SelectAddress extends AddressEvent {
  final String addressId;
  SelectAddress(this.addressId);
}

class DeleteAddress extends AddressEvent {
  final String addressId;
  DeleteAddress(this.addressId);
}

class UpdateAddress extends AddressEvent {
  final Address updatedAddress;
  UpdateAddress(this.updatedAddress);
}
