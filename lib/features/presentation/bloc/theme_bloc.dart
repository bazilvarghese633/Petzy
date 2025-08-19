import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/utils/theme_helper.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(themeMode: ThemeMode.light)) {
    on<LoadTheme>((event, emit) async {
      final isDark = await ThemeHelper.getTheme();
      emit(ThemeState(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
    });

    on<ToggleTheme>((event, emit) async {
      final isDark = state.themeMode == ThemeMode.dark;
      final newThemeMode = isDark ? ThemeMode.light : ThemeMode.dark;
      await ThemeHelper.setTheme(!isDark);
      emit(ThemeState(themeMode: newThemeMode));
    });
  }
}
