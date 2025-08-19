import 'package:shared_preferences/shared_preferences.dart';

class ThemeHelper {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setTheme(bool isDark) async {
    await _prefs.setBool('isDark', isDark);
  }

  static Future<bool> getTheme() async {
    return _prefs.getBool('isDark') ?? false;
  }
}
