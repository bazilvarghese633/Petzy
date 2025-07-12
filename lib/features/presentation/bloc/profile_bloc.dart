import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:petzy/features/domain/entity/profile_entity.dart';
import 'package:petzy/features/domain/usecase/get_profile.dart';
import 'package:petzy/features/domain/usecase/update_profile.dart';
import 'package:petzy/features/presentation/bloc/profile_events.dart';

import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final FirebaseAuth firebaseAuth;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.firebaseAuth,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final uid = firebaseAuth.currentUser?.uid;
      if (uid == null) {
        emit(ProfileError("User not logged in"));
        return;
      }

      var profile = await getProfileUseCase(uid);

      if (profile == null) {
        // Auto-create profile from Firebase user info if none found
        final fbUser = firebaseAuth.currentUser!;
        profile = Profile(
          name: fbUser.displayName ?? '',
          email: fbUser.email ?? '',
          phone: '',
          photoUrl: fbUser.photoURL ?? '',
        );

        final success = await updateProfileUseCase(uid, profile, null);
        if (!success) {
          emit(ProfileError("Failed to create profile"));
          return;
        }
      }

      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError("Failed to load profile: $e"));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final uid = firebaseAuth.currentUser?.uid;
      if (uid == null) {
        emit(ProfileError("User not logged in"));
        return;
      }

      final success = await updateProfileUseCase(
        uid,
        event.profile,
        event.imageFile,
      );

      if (success) {
        final updatedProfile = await getProfileUseCase(uid);
        emit(ProfileUpdated(updatedProfile ?? event.profile));
      } else {
        emit(ProfileError("Update failed"));
      }
    } catch (e) {
      emit(ProfileError("Failed to update profile: $e"));
    }
  }
}
