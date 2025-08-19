// home_user_info.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:petzy/features/presentation/screens/profile_screen/profile_screen.dart';
import 'package:petzy/features/presentation/bloc/cubit/user_cubit.dart'; // Import your cubit

class HomeUserInfo extends StatelessWidget {
  const HomeUserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: grey300,
                  highlightColor: grey100,
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: whiteColor,
                  ),
                ),
                sizedBoxW10,
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: grey300,
                    highlightColor: grey100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 12, width: 100, color: whiteColor),
                        sizedBoxH6,
                        Container(height: 14, width: 150, color: whiteColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state.user == null) {
          return const SizedBox();
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );

                  // Refresh user info after returning
                  context.read<UserCubit>().fetchUser();
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: grey200,
                  backgroundImage:
                      state.user!.photoURL != null
                          ? NetworkImage(state.user!.photoURL!)
                          : null,
                  child:
                      state.user!.photoURL == null
                          ? const Icon(Icons.person, color: greyColor)
                          : null,
                ),
              ),
              sizedBoxW10,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(fontSize: 12, color: greyColor),
                  ),
                  Text(
                    state.name ?? 'User',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
