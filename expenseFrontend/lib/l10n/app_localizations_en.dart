// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SenaTrack';

  @override
  String get supportTitle => 'Help & Support';

  @override
  String get language => 'Language';

  @override
  String get currentLanguage => 'English';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get security => 'Security & Password';

  @override
  String get logout => 'Logout';
}
