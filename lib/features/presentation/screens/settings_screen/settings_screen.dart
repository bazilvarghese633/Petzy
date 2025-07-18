import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/repository/address_repository.dart';
import 'package:petzy/features/presentation/bloc/address_bloc.dart';
import 'package:petzy/features/presentation/bloc/address_event.dart';
import 'package:petzy/features/presentation/screens/address_screen/address_screen.dart';
import 'package:petzy/features/presentation/screens/fevorites_screen/fevorites_screen.dart';
import 'package:petzy/features/presentation/screens/home_screen/widgets/custom_navbar.dart';
import 'package:petzy/features/presentation/screens/welcome_screen/welcome_screen.dart';
import 'package:petzy/features/presentation/widgets/cutom_dailog.dart';
import 'widgets/settings_card.dart';
import 'widgets/settings_item.dart';
import 'widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: whiteColor,
        foregroundColor: appTitleColor,
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: grey200),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            SettingsSection(title: "Account"),
            SettingsCard(
              children: [
                SettingsItem(
                  icon: Icons.favorite_rounded,
                  title: "Favorites",
                  subtitle: "Manage your favorite products",
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FavoritesPage(),
                        ),
                      ),
                ),
                SettingsItem.divider(),
                SettingsItem(
                  icon: Icons.location_on_rounded,
                  title: "Delivery Address",
                  subtitle: "Manage your delivery addresses",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) {
                          final repo = ctx.read<AddressRepository>();
                          return BlocProvider(
                            create:
                                (_) => AddressBloc(repo)..add(LoadAddresses()),
                            child: const AddressScreen(),
                          );
                        },
                      ),
                    );
                  },
                ),
                SettingsItem.divider(),
                SettingsItem(
                  icon: Icons.payment_rounded,
                  title: "Payment Methods",
                  subtitle: "Manage your payment options",
                  onTap:
                      () => CustomDialog.show(
                        context: context,
                        title: 'Coming Soon',
                        message:
                            'This feature is coming soon in the next update.',
                        confirmText: 'OK',
                      ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SettingsSection(title: "Preferences"),
            SettingsCard(
              children: [
                SettingsItem(
                  icon: Icons.notifications_rounded,
                  title: "Notifications",
                  subtitle: "Push notifications and alerts",
                  onTap:
                      () => CustomDialog.show(
                        context: context,
                        title: 'Coming Soon',
                        message:
                            'This feature is coming soon in the next update.',
                        confirmText: 'OK',
                      ),
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                    activeColor: primaryColor,
                  ),
                ),
                SettingsItem.divider(),
                SettingsItem(
                  icon: Icons.language_rounded,
                  title: "Language",
                  subtitle: "English",
                  onTap:
                      () => CustomDialog.show(
                        context: context,
                        title: 'Coming Soon',
                        message:
                            'This feature is coming soon in the next update.',
                        confirmText: 'OK',
                      ),
                ),
                SettingsItem.divider(),
                SettingsItem(
                  icon: Icons.dark_mode_rounded,
                  title: "Dark Mode",
                  subtitle: "Toggle app theme",
                  onTap:
                      () => CustomDialog.show(
                        context: context,
                        title: 'Coming Soon',
                        message:
                            'This feature is coming soon in the next update.',
                        confirmText: 'OK',
                      ),
                  trailing: Switch(
                    value: false,
                    onChanged: (_) {},
                    activeColor: primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SettingsSection(title: "Support & Legal"),
            SettingsCard(
              children: [
                SettingsItem(
                  icon: Icons.help_rounded,
                  title: "Help & Support",
                  subtitle: "Get help and contact support",
                  onTap:
                      () => CustomDialog.show(
                        context: context,
                        title: 'Coming Soon',
                        message:
                            'This feature is coming soon in the next update.',
                        confirmText: 'OK',
                      ),
                ),
                SettingsItem.divider(),
                SettingsItem(
                  icon: Icons.info_rounded,
                  title: "About",
                  subtitle: "App version and information",
                  onTap:
                      () => CustomDialog.show(
                        context: context,
                        title: 'About Petzy',
                        message:
                            'Version 1.0.0\n\nYour trusted companion for all pet care needs.',
                        confirmText: 'OK',
                      ),
                ),
                SettingsItem.divider(),
                SettingsItem(
                  icon: Icons.privacy_tip_rounded,
                  title: "Privacy Policy",
                  subtitle: "Read our privacy policy",
                  onTap:
                      () => CustomDialog.show(
                        context: context,
                        title: 'Coming Soon',
                        message:
                            'This feature is coming soon in the next update.',
                        confirmText: 'OK',
                      ),
                ),
                SettingsItem.divider(),
                SettingsItem(
                  icon: Icons.description_rounded,
                  title: "Terms of Service",
                  subtitle: "Read our terms and conditions",
                  onTap:
                      () => CustomDialog.show(
                        context: context,
                        title: 'Coming Soon',
                        message:
                            'This feature is coming soon in the next update.',
                        confirmText: 'OK',
                      ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SettingsCard(
              children: [
                SettingsItem(
                  icon: Icons.logout_rounded,
                  title: "Logout",
                  subtitle: "Sign out of your account",
                  titleColor: redColor,
                  iconColor: redColor,
                  onTap:
                      () => CustomDialog.show(
                        context: context,
                        title: 'Logout',
                        message: 'Are you sure you want to logout?',
                        confirmText: 'Logout',
                        cancelText: 'Cancel',
                        isDestructive: true,
                        onConfirm: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WelcomePage(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                ),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 3, onTap: (_) {}),
    );
  }
}
