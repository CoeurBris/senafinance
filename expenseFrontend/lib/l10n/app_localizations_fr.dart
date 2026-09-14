// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSubtitle => 'Français';

  @override
  String get general => 'Général';

  @override
  String get currency => 'Devise';

  @override
  String get appearance => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get notifications => 'Notifications';

  @override
  String get expenseReminders => 'Rappels de dépenses';

  @override
  String get expenseRemindersSubtitle => 'Chaque soir à 20h';

  @override
  String get budgetAlerts => 'Alertes budget';

  @override
  String get budgetAlertsSubtitle => 'À 80% du seuil';

  @override
  String get dataAndSecurity => 'Données & Sécurité';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get exportDataSubtitle => 'CSV ou Excel';

  @override
  String get account => 'Compte';

  @override
  String get supportTitle => 'Aide & Support';

  @override
  String get logoutAction => 'Se déconnecter';

  @override
  String get language => 'Langue';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeSystemOption => 'Automatique (système)';

  @override
  String get closeAction => 'Fermer';

  @override
  String get cancelAction => 'Annuler';

  @override
  String get logoutDialogTitle => 'Déconnexion';

  @override
  String get logoutConfirmMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get currencyFcfa => 'Franc CFA (FCFA)';

  @override
  String get currencyUsd => 'Dollar américain (\$)';

  @override
  String get currencyEur => 'Euro (€)';

  @override
  String get currencyGbp => 'Livre sterling (£)';

  @override
  String get currencyMad => 'Dirham marocain (MAD)';

  @override
  String get autoLabel => 'Auto';

  @override
  String get manualLabel => 'Manuel';

  @override
  String csvExportError(Object error) {
    return 'Erreur lors de l\'export CSV : $error';
  }

  @override
  String excelExportError(Object error) {
    return 'Erreur lors de l\'export Excel : $error';
  }

  @override
  String get appVersionLabel => 'Gestion Dépenses v1.0.0';
}
