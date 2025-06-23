import 'package:petzy/features/domain/entity/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn(String email, String password);
  Future<UserEntity> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<UserEntity> getCurrentUser();
  Future<UserEntity> signInWithGoogle();
}
