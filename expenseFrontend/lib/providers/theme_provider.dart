import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> appThemeNotifier = ValueNotifier(ThemeMode.system);

Future<void> loadThemeFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('pref_theme') ?? 'system';
  appThemeNotifier.value = _themeModeFromString(saved);
}

Future<void> setThemeMode(ThemeMode mode) async {
  appThemeNotifier.value = mode;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('pref_theme', _themeModeToString(mode));
}

ThemeMode _themeModeFromString(String value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}