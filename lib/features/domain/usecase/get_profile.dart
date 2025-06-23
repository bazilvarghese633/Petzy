// get_profile_usecase.dart
import 'package:petzy/features/domain/entity/profile_entity.dart';
import 'package:petzy/features/domain/repository/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Profile?> call(String uid) async {
    return await repository.getProfile(uid);
  }
}
