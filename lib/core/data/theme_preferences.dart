// region Lógica Backend Frontend: persistencia local del tema visual
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  ThemePreferences._();

  static final ThemePreferences instance = ThemePreferences._();

  static const String _themeKey = 'theme_mode';

  final ValueNotifier<ThemeMode> notifier = ValueNotifier(ThemeMode.system);

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_themeKey);

    switch (saved) {
      case 'light':
        notifier.value = ThemeMode.light;
      case 'dark':
        notifier.value = ThemeMode.dark;
      default:
        notifier.value = ThemeMode.system;
    }
  }

  Future<void> save(ThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();

    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
      case ThemeMode.dark:
        value = 'dark';
      default:
        value = 'system';
    }

    notifier.value = mode;
    await preferences.setString(_themeKey, value);
  }

  Future<void> toggle() async {
    final next =
        notifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await save(next);
  }
}
// endregion