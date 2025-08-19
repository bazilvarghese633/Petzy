import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/profile_entity.dart';
import 'package:petzy/features/presentation/bloc/cubit/profile_image_cubit.dart';
import 'package:petzy/features/presentation/bloc/profile_bloc.dart';
import 'package:petzy/features/presentation/bloc/profile_events.dart';
import 'package:petzy/features/presentation/bloc/profile_state.dart';

class ProfileUtils {
  static void handleStateChanges(BuildContext context, ProfileState state) {
    if (state is ProfileUpdated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (state is ProfileError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  static Profile getProfileFromState(ProfileState state) {
    return state is ProfileLoaded
        ? state.profile
        : (state as ProfileUpdated).profile;
  }

  static void populateControllers(
    Profile profile,
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController phoneController,
  ) {
    final currentUser = FirebaseAuth.instance.currentUser;

    nameController.text =
        profile.name?.isNotEmpty == true
            ? profile.name!
            : currentUser?.displayName ?? '';
    emailController.text =
        profile.email?.isNotEmpty == true
            ? profile.email!
            : currentUser?.email ?? '';
    phoneController.text = profile.phone ?? '';
  }

  static Future<void> pickImage(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      context.read<ProfileImageCubit>().setImage(File(pickedFile.path));
    }
  }

  static ImageProvider<Object>? getDisplayImage(
    File? selectedImage,
    String? photoUrl,
  ) {
    if (selectedImage != null) {
      return FileImage(selectedImage);
    } else if (photoUrl?.isNotEmpty == true) {
      return NetworkImage(photoUrl!);
    }
    return null;
  }

  static void saveProfile(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController phoneController,
    Profile profile,
  ) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User not logged in'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final imageFile = context.read<ProfileImageCubit>().state;

    context.read<ProfileBloc>().add(
      UpdateProfileEvent(
        profile: Profile(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          photoUrl: profile.photoUrl,
        ),
        imageFile: imageFile,
      ),
    );
  }

  static Widget buildLoadingScaffold() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withOpacity(0.1), whiteColor],
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  static Widget buildErrorScaffold() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withOpacity(0.1), whiteColor],
          ),
        ),
        child: const Center(
          child: Text('Something went wrong.', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
