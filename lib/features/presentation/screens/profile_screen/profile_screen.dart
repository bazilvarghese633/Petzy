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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _selectedImage;

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
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileLoaded || state is ProfileUpdated) {
          final profile =
              (state is ProfileLoaded)
                  ? state.profile
                  : (state as ProfileUpdated).profile;

          final currentUser = FirebaseAuth.instance.currentUser;

          // Use fallback from FirebaseAuth if profile fields are null
          _nameController.text =
              (profile.name != null && profile.name!.isNotEmpty)
                  ? profile.name!
                  : currentUser?.displayName ?? '';

          _emailController.text =
              (profile.email != null && profile.email!.isNotEmpty)
                  ? profile.email!
                  : currentUser?.email ?? '';

          _phoneController.text = profile.phone ?? '';

          final displayImage =
              _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                  ? NetworkImage(profile.photoUrl!)
                  : null;

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
                        setState(() {
                          _selectedImage = File(pickedFile.path);
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: displayImage as ImageProvider<Object>?,
                      backgroundColor: greyColor,
                      child:
                          displayImage == null
                              ? Icon(Icons.person, size: 50, color: brownColr)
                              : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
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

                      context.read<ProfileBloc>().add(
                        UpdateProfileEvent(
                          profile: Profile(
                            name: _nameController.text.trim(),
                            email: _emailController.text.trim(),
                            phone: _phoneController.text.trim(),
                            photoUrl: profile.photoUrl,
                          ),
                          imageFile: _selectedImage,
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
        } else if (state is ProfileError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile"),
              backgroundColor: primaryColor,
              foregroundColor: whiteColor,
              elevation: 0,
            ),
            body: Center(
              child: Text(
                'Error: ${state.message}',
                style: TextStyle(color: redColor),
              ),
            ),
          );
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
