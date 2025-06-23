import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/domain/entity/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({String? id, String? email, String? name})
    : super(id: id, email: email, name: name);

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(id: user.uid, email: user.email, name: user.displayName);
  }
}
