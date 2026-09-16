// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'English';

  @override
  String get general => 'General';

  @override
  String get currency => 'Currency';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get notifications => 'Notifications';

  @override
  String get expenseReminders => 'Expense reminders';

  @override
  String get expenseRemindersSubtitle => 'Every evening at 8pm';

  @override
  String get budgetAlerts => 'Budget alerts';

  @override
  String get budgetAlertsSubtitle => 'At 80% of threshold';

  @override
  String get dataAndSecurity => 'Data & Security';

  @override
  String get exportData => 'Export data';

  @override
  String get exportDataSubtitle => 'CSV or Excel';

  @override
  String get account => 'Account';

  @override
  String get supportTitle => 'Help & Support';

  @override
  String get logoutAction => 'Log out';

  @override
  String get language => 'Language';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemOption => 'Automatic (system)';

  @override
  String get closeAction => 'Close';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get logoutDialogTitle => 'Log out';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get currencyFcfa => 'CFA Franc (FCFA)';

  @override
  String get currencyUsd => 'US Dollar (\$)';

  @override
  String get currencyEur => 'Euro (€)';

  @override
  String get currencyGbp => 'British Pound (£)';

  @override
  String get currencyMad => 'Moroccan Dirham (MAD)';

  @override
  String get autoLabel => 'Auto';

  @override
  String get manualLabel => 'Manual';

  @override
  String csvExportError(Object error) {
    return 'Error exporting CSV: $error';
  }

  @override
  String excelExportError(Object error) {
    return 'Error exporting Excel: $error';
  }

  @override
  String get appVersionLabel => 'Expense Manager v1.0.0';
}
