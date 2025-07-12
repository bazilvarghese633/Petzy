// user_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserState {
  final User? user;
  final String? name;
  final bool isLoading;

  const UserState({this.user, this.name, this.isLoading = false});
}

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState(isLoading: true)) {
    fetchUser();
  }

  Future<void> fetchUser() async {
    emit(const UserState(isLoading: true));

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const UserState(user: null, name: null, isLoading: false));
      return;
    }

    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(refreshedUser!.uid)
            .get();

    final data = doc.data();
    final name =
        (data != null && data.containsKey('name'))
            ? data['name'] as String
            : refreshedUser.email ?? 'User';

    emit(UserState(user: refreshedUser, name: name, isLoading: false));
  }
}
