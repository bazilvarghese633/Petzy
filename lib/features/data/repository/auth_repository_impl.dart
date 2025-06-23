import 'package:petzy/features/data/data_source/auth_remote_datasource.dart';
import 'package:petzy/features/domain/entity/user_entity.dart';
import 'package:petzy/features/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> signIn(String email, String password) async {
    return await remoteDataSource.signIn(email, password);
  }

  @override
  Future<UserEntity> signUp(String email, String password, String name) async {
    return await remoteDataSource.signUp(email, password, name);
  }

  @override
  Future<void> signOut() async {
    return await remoteDataSource.signOut();
  }

  @override
  Future<bool> isSignedIn() async {
    return await remoteDataSource.isSignedIn();
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    return await remoteDataSource.signInWithGoogle();
  }
}
