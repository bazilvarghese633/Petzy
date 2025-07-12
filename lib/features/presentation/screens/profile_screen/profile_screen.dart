import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/bloc/profile_bloc.dart';
import 'package:petzy/features/presentation/bloc/profile_events.dart';
import 'package:petzy/features/presentation/bloc/profile_state.dart';
import 'package:petzy/features/domain/entity/profile_entity.dart';
import 'package:petzy/features/presentation/bloc/cubit/profile_image_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileImageCubit(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProfileLoaded || state is ProfileUpdated) {
          final profile =
              state is ProfileLoaded
                  ? state.profile
                  : (state as ProfileUpdated).profile;

          final currentUser = FirebaseAuth.instance.currentUser;

          _nameController.text =
              profile.name?.isNotEmpty == true
                  ? profile.name!
                  : currentUser?.displayName ?? '';
          _emailController.text =
              profile.email?.isNotEmpty == true
                  ? profile.email!
                  : currentUser?.email ?? '';
          _phoneController.text = profile.phone ?? '';

          return Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              title: const Text('Profile'),
              backgroundColor: primaryColor,
              foregroundColor: whiteColor,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final pickedFile = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        context.read<ProfileImageCubit>().setImage(
                          File(pickedFile.path),
                        );
                      }
                    },
                    child: BlocBuilder<ProfileImageCubit, File?>(
                      builder: (context, selectedImage) {
                        final displayImage =
                            selectedImage != null
                                ? FileImage(selectedImage)
                                : (profile.photoUrl?.isNotEmpty == true
                                    ? NetworkImage(profile.photoUrl!)
                                    : null);

                        return CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              displayImage as ImageProvider<Object>?,
                          backgroundColor: greyColor,
                          child:
                              displayImage == null
                                  ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: brownColr,
                                  )
                                  : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_nameController, "Name"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _emailController,
                    "Email",
                    TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _phoneController,
                    "Phone Number",
                    TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: whiteColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                      if (uid.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User not logged in')),
                        );
                        return;
                      }

                      final imageFile = context.read<ProfileImageCubit>().state;

                      context.read<ProfileBloc>().add(
                        UpdateProfileEvent(
                          profile: Profile(
                            name: _nameController.text.trim(),
                            email: _emailController.text.trim(),
                            phone: _phoneController.text.trim(),
                            photoUrl: profile.photoUrl,
                          ),
                          imageFile: imageFile,
                        ),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text('Something went wrong.')),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: secondaryColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      style: TextStyle(color: secondaryColor),
    );
  }
}
