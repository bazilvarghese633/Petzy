import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzy/features/domain/entity/address.dart';

class AddressModel extends Address {
  AddressModel({
    required super.id,
    required super.name,
    required super.houseName,
    required super.town,
    required super.district,
    required super.state,
    required super.country,
    required super.pincode,
    required super.phone,
    super.instructions = '',
    super.isSelected = false,
  });

//convert entity to firesotre map
  Map<String, dynamic> toMap() => {
    'name': name,
    'houseName': houseName,
    'town': town,
    'district': district,
    'state': state,
    'country': country,
    'pincode': pincode,
    'phone': phone,
    'instructions': instructions,
    'isSelected': isSelected,
  };

//build model from a raw firesotre map and doc id
  factory AddressModel.fromMap(String id, Map<String, dynamic> data) {
    return AddressModel(
      id: id,
      name: data['name'] ?? '',
      houseName: data['houseName'] ?? '',
      town: data['town'] ?? '',
      district: data['district'] ?? '',
      state: data['state'] ?? '',
      country: data['country'] ?? '',
      pincode: data['pincode'] ?? '',
      phone: data['phone'] ?? '',
      instructions: data['instructions'] ?? '',
      isSelected: data['isSelected'] ?? false,
    );
  }

// build model form firestore documentsnapshot
  factory AddressModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel.fromMap(doc.id, data);
  }

//convdert a address entity ot address model
  factory AddressModel.fromEntity(Address entity) {
    return AddressModel(
      id: entity.id,
      name: entity.name,
      houseName: entity.houseName,
      town: entity.town,
      district: entity.district,
      state: entity.state,
      country: entity.country,
      pincode: entity.pincode,
      phone: entity.phone,
      instructions: entity.instructions,
      isSelected: entity.isSelected,
    );
  }
}
