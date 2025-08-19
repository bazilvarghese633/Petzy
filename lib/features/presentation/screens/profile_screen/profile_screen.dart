import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/bloc/profile_bloc.dart';
import 'package:petzy/features/presentation/bloc/profile_events.dart';
import 'package:petzy/features/presentation/bloc/profile_state.dart';
import 'package:petzy/features/presentation/bloc/cubit/profile_image_cubit.dart';
import 'package:petzy/features/presentation/screens/profile_screen/widgets/profile_header.dart';
import 'package:petzy/features/presentation/screens/profile_screen/widgets/profile_text_feild.dart';
import 'package:petzy/features/presentation/screens/profile_screen/widgets/profile_untils.dart';

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

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger profile load once when this widget is built
    context.read<ProfileBloc>().add(LoadProfileEvent());

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        ProfileUtils.handleStateChanges(context, state);
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return ProfileUtils.buildLoadingScaffold();
        }

        if (state is ProfileLoaded || state is ProfileUpdated) {
          final profile = ProfileUtils.getProfileFromState(state);

          final nameController = TextEditingController(text: profile.name);
          final emailController = TextEditingController(text: profile.email);
          final phoneController = TextEditingController(text: profile.phone);

          return Scaffold(
            backgroundColor: whiteColor,
            body: CustomScrollView(
              slivers: [
                const ProfileAppBar(),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [primaryColor.withOpacity(0.05), whiteColor],
                      ),
                    ),
                    child: Column(
                      children: [
                        ProfileHeader(profile: profile),
                        ProfileForm(
                          nameController: nameController,
                          emailController: emailController,
                          phoneController: phoneController,
                          profile: profile,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ProfileUtils.buildErrorScaffold();
      },
    );
  }
}
