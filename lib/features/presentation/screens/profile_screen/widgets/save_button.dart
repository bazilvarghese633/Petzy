import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/profile_entity.dart';
import 'package:petzy/features/presentation/screens/profile_screen/widgets/profile_untils.dart';

class ProfileSaveButton extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final Profile profile;

  const ProfileSaveButton({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: whiteColor,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed:
            () => ProfileUtils.saveProfile(
              context,
              nameController,
              emailController,
              phoneController,
              profile,
            ),
        icon: const Icon(Icons.save_outlined, size: 20),
        label: const Text(
          "Save Changes",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
