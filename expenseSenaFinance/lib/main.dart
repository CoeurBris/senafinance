
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:senafinance/l10n/app_localizations.dart';
import 'package:senafinance/providers/budget_provider.dart';
import 'package:senafinance/providers/category_provider.dart';
import 'package:senafinance/providers/currency_provider.dart';
import 'package:senafinance/providers/expense_provider.dart';
import 'package:senafinance/providers/notification_provider.dart';
import 'package:senafinance/providers/objectif_provider.dart';
import 'package:senafinance/providers/theme_provider.dart';
import 'package:senafinance/providers/transaction_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'providers/locale_provider.dart';
import 'repositories/auth_repository.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'utils/date_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des dates
  await AppDateUtils.init();

  // On passe par le Repository pour vérifier la connexion
  final authRepository = AuthRepository();
  final bool isLoggedIn = await authRepository.isAuthenticated();

  final prefs = await SharedPreferences.getInstance();

  final savedLocale = prefs.getString('pref_locale');
  if (savedLocale != null) {
    appLocaleNotifier.value = Locale(savedLocale);
  }
  
  appCurrencyNotifier.value = prefs.getString('pref_currency') ?? 'FCFA';
  await loadThemeFromPrefs();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ObjectifProvider()),
        ChangeNotifierProvider(create: (_) => appCurrencyNotifier),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => appThemeNotifier),
      ],
      child: MainApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;

  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocaleNotifier,
      builder: (context, locale, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: appThemeNotifier,
          builder: (context, mode, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'SenaTrack',
              theme: appTheme,
              darkTheme: appDarkTheme,
              themeMode:
                  mode, // ← plus besoin du ternaire, mode EST déjà le bon ThemeMode
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
              routes: {
                '/login': (context) => const LoginScreen(),
                '/register': (context) => const RegisterScreen(),
                '/dashboard': (context) => const DashboardScreen(),
              },
            );
          },
        );
      },
    );
  }
}
