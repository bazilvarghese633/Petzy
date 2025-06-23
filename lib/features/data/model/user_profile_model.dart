// lib/features/data/models/profile_model.dart

import 'package:petzy/features/domain/entity/profile_entity.dart';

class ProfileModel extends Profile {
  ProfileModel({String? name, String? email, String? phone, String? photoUrl})
    : super(name: name, email: email, phone: phone, photoUrl: photoUrl);

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name ?? '',
      'email': email ?? '',
      'phone': phone ?? '',
      'photoUrl': photoUrl ?? '',
    };
  }
}
