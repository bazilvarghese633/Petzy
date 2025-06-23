class UserEntity {
  final String? id;
  final String? email;
  final String? name;

  UserEntity({this.id, this.email, this.name});

  @override
  // ignore: override_on_non_overriding_member
  List<Object?> get props => [id, email, name];
}
