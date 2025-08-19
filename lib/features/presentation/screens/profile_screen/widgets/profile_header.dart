import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/profile_entity.dart';
import 'package:petzy/features/presentation/screens/profile_screen/widgets/circleavathar_widget.dart';

class ProfileHeader extends StatelessWidget {
  final Profile profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userName =
        profile.name?.isNotEmpty == true
            ? profile.name!
            : currentUser?.displayName ?? 'User';
    final userEmail =
        profile.email?.isNotEmpty == true
            ? profile.email!
            : currentUser?.email ?? '';

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const ProfileAvatar(),
          const SizedBox(height: 16),
          Text(
            userName,
            style: TextStyle(
              fontSize: 20,
              color: secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            style: TextStyle(
              fontSize: 14,
              color: secondaryColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// widgets/profile_app_bar.dart
// =============================================================================

class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      elevation: 0,
      title: const Text(
        'Profile',
        style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
          ),
        ),
      ),
      backgroundColor: primaryColor,
      foregroundColor: whiteColor,
    );
  }
}
