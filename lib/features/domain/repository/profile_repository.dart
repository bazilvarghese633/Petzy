// profile_repository.dart
import 'dart:io';

import 'package:petzy/features/domain/entity/profile_entity.dart';

abstract class ProfileRepository {
  Future<Profile?> getProfile(String uid);
  Future<bool> updateProfile(String uid, Profile profile, File? imageFile);
}
