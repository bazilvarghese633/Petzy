import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/presentation/bloc/theme_bloc.dart';
import 'package:petzy/features/presentation/bloc/theme_event.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.themeMode == ThemeMode.dark;

    return FilledButton.icon(
      icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
      label: Text(isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode'),
      onPressed: () {
        context.read<ThemeBloc>().add(ToggleTheme());
      },
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
