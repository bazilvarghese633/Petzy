import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/bloc/cubit/profile_image_cubit.dart';
import 'package:petzy/features/presentation/bloc/profile_bloc.dart';
import 'package:petzy/features/presentation/bloc/profile_state.dart';
import 'package:petzy/features/presentation/screens/profile_screen/widgets/profile_untils.dart';

// class UserAvatar extends StatelessWidget {
//   final String? photoUrl;
//   final double radius;

//   const UserAvatar({super.key, this.photoUrl, this.radius = 30});

//   @override
//   Widget build(BuildContext context) {
//     return CircleAvatar(
//       radius: radius,
//       backgroundColor: grey200,
//       backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
//       child:
//           photoUrl == null
//               ? const Icon(Icons.person, size: 30, color: greyColor)
//               : null,
//     );
//   }
// }

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = ProfileUtils.getProfileFromState(state);

        return Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, primaryColor.withOpacity(0.7)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: whiteColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: GestureDetector(
                      onTap: () => ProfileUtils.pickImage(context),
                      child: BlocBuilder<ProfileImageCubit, File?>(
                        builder: (context, selectedImage) {
                          final displayImage = ProfileUtils.getDisplayImage(
                            selectedImage,
                            profile.photoUrl,
                          );

                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: displayImage,
                            backgroundColor: greyColor.withOpacity(0.1),
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
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.camera_alt, color: whiteColor, size: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}
