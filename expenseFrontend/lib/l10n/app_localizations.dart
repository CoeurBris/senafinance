import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get settingsSubtitle;

  /// No description provided for @general.
  ///
  /// In fr, this message translates to:
  /// **'Général'**
  String get general;

  /// No description provided for @currency.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get currency;

  /// No description provided for @appearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get theme;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @expenseReminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels de dépenses'**
  String get expenseReminders;

  /// No description provided for @expenseRemindersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Chaque soir à 20h'**
  String get expenseRemindersSubtitle;

  /// No description provided for @budgetAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes budget'**
  String get budgetAlerts;

  /// No description provided for @budgetAlertsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'À 80% du seuil'**
  String get budgetAlertsSubtitle;

  /// No description provided for @dataAndSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Données & Sécurité'**
  String get dataAndSecurity;

  /// No description provided for @exportData.
  ///
  /// In fr, this message translates to:
  /// **'Exporter les données'**
  String get exportData;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'CSV ou Excel'**
  String get exportDataSubtitle;

  /// No description provided for @account.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get account;

  /// No description provided for @supportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aide & Support'**
  String get supportTitle;

  /// No description provided for @logoutAction.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logoutAction;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @themeSystemOption.
  ///
  /// In fr, this message translates to:
  /// **'Automatique (système)'**
  String get themeSystemOption;

  /// No description provided for @closeAction.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get closeAction;

  /// No description provided for @cancelAction.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancelAction;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logoutDialogTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vous déconnecter ?'**
  String get logoutConfirmMessage;

  /// No description provided for @currencyFcfa.
  ///
  /// In fr, this message translates to:
  /// **'Franc CFA (FCFA)'**
  String get currencyFcfa;

  /// No description provided for @currencyUsd.
  ///
  /// In fr, this message translates to:
  /// **'Dollar américain (\$)'**
  String get currencyUsd;

  /// No description provided for @currencyEur.
  ///
  /// In fr, this message translates to:
  /// **'Euro (€)'**
  String get currencyEur;

  /// No description provided for @currencyGbp.
  ///
  /// In fr, this message translates to:
  /// **'Livre sterling (£)'**
  String get currencyGbp;

  /// No description provided for @currencyMad.
  ///
  /// In fr, this message translates to:
  /// **'Dirham marocain (MAD)'**
  String get currencyMad;

  /// No description provided for @autoLabel.
  ///
  /// In fr, this message translates to:
  /// **'Auto'**
  String get autoLabel;

  /// No description provided for @manualLabel.
  ///
  /// In fr, this message translates to:
  /// **'Manuel'**
  String get manualLabel;

  /// No description provided for @csvExportError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'export CSV : {error}'**
  String csvExportError(Object error);

  /// No description provided for @excelExportError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'export Excel : {error}'**
  String excelExportError(Object error);

  /// No description provided for @appVersionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Gestion Dépenses v1.0.0'**
  String get appVersionLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
