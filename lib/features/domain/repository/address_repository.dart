import '../entity/address.dart';

abstract class AddressRepository {
  Future<void> addAddress(Address address);
  Stream<List<Address>> getAddresses(String uid);
  Future<void> selectAddress(String uid, String addressId);
  Future<void> deleteAddress(String uid, String addressId);
  Future<void> updateAddress(String uid, Address address);
}
