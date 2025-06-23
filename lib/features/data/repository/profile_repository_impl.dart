// lib/features/data/repository/profile_repository_impl.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzy/features/data/data_source/profile_remote_datasource.dart';
import 'package:petzy/features/data/model/user_profile_model.dart';

import 'package:petzy/features/domain/entity/profile_entity.dart';
import 'package:petzy/features/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Profile?> getProfile(String uid) async {
    final data = await remoteDataSource.getProfileData(uid);
    if (data == null) return null;

    final model = ProfileModel.fromJson(data);
    return model; // Automatically upcast to Profile entity
  }

  @override
  Future<bool> updateProfile(
    String uid,
    Profile profile,
    File? imageFile,
  ) async {
    String? photoUrl = profile.photoUrl;

    // Upload new image if provided
    if (imageFile != null) {
      final uploadedUrl = await remoteDataSource.uploadImageToCloudinary(
        imageFile,
      );
      if (uploadedUrl == null) return false;
      photoUrl = uploadedUrl;
      await remoteDataSource.updateFirebaseUserPhotoUrl(uploadedUrl);
    }

    // Convert entity to model and then to JSON
    final model = ProfileModel(
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
      photoUrl: photoUrl,
    );

    final data = model.toJson();
    data['timestamp'] = FieldValue.serverTimestamp();

    try {
      await remoteDataSource.saveProfileData(uid, data);
      return true;
    } catch (e) {
      print("Error saving profile: $e");
      return false;
    }
  }
}
