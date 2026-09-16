// import 'package:flutter/material.dart';

// final ValueNotifier<Locale> appLocaleNotifier = ValueNotifier(const Locale('fr'));

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<Locale> appLocaleNotifier = ValueNotifier(const Locale('fr'));

/// Change la langue de toute l'app et persiste le choix (comme setThemeMode).
Future<void> setAppLocale(String languageCode) async {
  appLocaleNotifier.value = Locale(languageCode);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('pref_locale', languageCode);
}