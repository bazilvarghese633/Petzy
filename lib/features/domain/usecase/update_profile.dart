// update_profile_usecase.dart
import 'dart:io';

import 'package:petzy/features/domain/entity/profile_entity.dart';
import 'package:petzy/features/domain/repository/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<bool> call(String uid, Profile profile, File? imageFile) async {
    return await repository.updateProfile(uid, profile, imageFile);
  }
}
