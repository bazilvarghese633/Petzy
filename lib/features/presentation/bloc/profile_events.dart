import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:petzy/features/domain/entity/profile_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final Profile profile;
  final File? imageFile;

  const UpdateProfileEvent({required this.profile, this.imageFile});

  @override
  List<Object?> get props => [profile, imageFile];
}
