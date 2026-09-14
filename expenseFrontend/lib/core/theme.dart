import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Couleurs principales — Teal
  static const Color primary = Color(0xFF0F6E56); // teal foncé
  static const Color primaryMid = Color(0xFF5DCAA5); // teal moyen
  static const Color primaryLight = Color(0xFFE1F5EE); // teal très clair

  // Succès (même famille que primary ici)
  static const Color success = Color(0xFF0F6E56);
  static const Color successLight = Color(0xFFE1F5EE);

  // Danger / Dépenses
  static const Color danger = Color(0xFFE24B4A);
  static const Color dangerLight = Color(0xFFFCEBEB);

  // Avertissement
  static const Color warning = Color(0xFF854F0B);
  static const Color warningLight = Color(0xFFFAEEDA);

  // Info
  static const Color info = Color(0xFF185FA5);
  static const Color infoLight = Color(0xFFE6F1FB);

  // Neutres
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E5E5);
  static const Color divider = Color(0xFFF0F0F0);

  // Textes
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF888780);
  static const Color textHint = Color(0xFFB4B2A9);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Graphiques (stats)
  static const List<Color> chartColors = [
    Color(0xFF0F6E56), // teal
    Color(0xFF5DCAA5), // teal clair
    Color(0xFFE24B4A), // rouge
    Color(0xFFEF9F27), // orange
    Color(0xFF185FA5), // bleu
    Color(0xFF9B59B6), // violet
    Color(0xFF888780), // gris
  ];
}

// ─────────────────────────────────────────────────
// STYLES DE TEXTE CENTRALISÉS
// ─────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
  );

  // Montant dépense (rouge)
  static const TextStyle amountDanger = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.danger,
    letterSpacing: -0.5,
  );

  // Montant revenu (teal)
  static const TextStyle amountSuccess = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  // Grand montant (ex: total dans HomeScreen)
  static const TextStyle amountLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -1,
  );

  // Bouton
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  // Section label (NOTIFICATIONS, GÉNÉRAL...)
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
  );
}

// ─────────────────────────────────────────────────
// DIMENSIONS & ESPACEMENTS
// ─────────────────────────────────────────────────
class AppSizes {
  AppSizes._();

  // Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 100.0;

  // Padding
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;

  // Hauteur bouton
  static const double buttonHeight = 52.0;

  // Hauteur AppBar
  static const double appBarHeight = 56.0;
}

// ─────────────────────────────────────────────────
// THÈME GLOBAL FLUTTER
// ─────────────────────────────────────────────────
final ThemeData appTheme = ThemeData(
  fontFamily: 'PlusJakartaSans',
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,

  // Palette de couleurs
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.primaryMid,
    surface: AppColors.surface, // ici
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    error: AppColors.danger,
  ),

  // AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    iconTheme: IconThemeData(color: AppColors.textPrimary),
  ),

  // Bouton principal
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      elevation: 0,
      textStyle: AppTextStyles.button,
    ),
  ),

  // Bouton texte
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
  ),

  // Bouton outline
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
    ),
  ),

  // Champs de saisie
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF7F6F2),
    hintStyle: const TextStyle(color: AppColors.textHint),
    prefixIconColor: AppColors.textSecondary,
    suffixIconColor: AppColors.textSecondary,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: const BorderSide(color: AppColors.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: const BorderSide(color: AppColors.danger, width: 2),
    ),
    errorStyle: const TextStyle(color: AppColors.danger),
  ),

  // Cards
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      side: const BorderSide(color: AppColors.border, width: 0.5),
    ),
    margin: const EdgeInsets.only(bottom: 10),
  ),

  // ChoiceChip (filtres catégories)
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.surface,
    selectedColor: AppColors.primaryLight,
    labelStyle: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
    secondaryLabelStyle: const TextStyle(
      fontSize: 13,
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
    ),
    side: const BorderSide(color: AppColors.border),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),

  // Divider
  dividerTheme: const DividerThemeData(
    color: AppColors.divider,
    thickness: 0.5,
  ),

  // SnackBar
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.textPrimary,
    contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    ),
    behavior: SnackBarBehavior.floating,
  ),

  // Drawer
  drawerTheme: const DrawerThemeData(backgroundColor: AppColors.surface),

  // Switch (Cupertino style dans settings)
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.surface;
      }
      return AppColors.textHint;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.border;
    }),
  ),
);

final ThemeData appDarkTheme = ThemeData(
  fontFamily: 'PlusJakartaSans',
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),

  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    primary: AppColors.primaryMid,
    secondary: AppColors.primaryMid,
    surface: const Color(0xFF1E1E1E),
    onSurface: Colors.white,
    onSurfaceVariant: const Color(0xFFB0B0B0),
    outline: const Color(0xFF2C2C2C),
    error: AppColors.danger,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryMid,
      foregroundColor: Colors.black,
      minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      elevation: 0,
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.primaryMid),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryMid,
      side: const BorderSide(color: AppColors.primaryMid),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E1E1E),
    hintStyle: const TextStyle(color: Color(0xFF888780)),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: const BorderSide(color: AppColors.primaryMid, width: 2),
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    selectedColor: AppColors.primary.withValues(alpha: 0.3),
    labelStyle: const TextStyle(fontSize: 13, color: Colors.white),
    side: const BorderSide(color: Color(0xFF2C2C2C)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
    ),
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      side: const BorderSide(color: Color(0xFF2C2C2C), width: 0.5),
    ),
    margin: const EdgeInsets.only(bottom: 10),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFF2C2C2C),
    thickness: 0.5,
  ),

  drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1E1E1E)),

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.white
          : const Color(0xFF888780),
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.primaryMid
          : const Color(0xFF2C2C2C),
    ),
  ),
);

// final ThemeData appDarkTheme = ThemeData(
//   fontFamily: 'PlusJakartaSans',
//   useMaterial3: true,
//   brightness: Brightness.light, // ← au lieu de Brightness.dark
//   scaffoldBackgroundColor: const Color.fromARGB(255, 250, 249, 249),

//   colorScheme: ColorScheme.fromSeed(
//     seedColor: AppColors.primary,
//     brightness: Brightness.light,
//     primary: AppColors.primaryMid,
//     secondary: AppColors.primaryMid,
//     surface: const Color.fromARGB(255, 250, 249, 249),
//     error: AppColors.danger,
//   ),

//   appBarTheme: const AppBarTheme(
//     backgroundColor: Colors.white,
//     foregroundColor: Colors.black,
//     elevation: 0,
//     centerTitle: false,
//     titleTextStyle: TextStyle(
//       fontSize: 18,
//       fontWeight: FontWeight.w500,
//       color: Colors.black,
//     ),
//     iconTheme: IconThemeData(color: Colors.black),
//   ),

//   // ⬇️ AJOUTS MANQUANTS
//   elevatedButtonTheme: ElevatedButtonThemeData(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: AppColors.primaryMid,
//       foregroundColor: AppColors.textOnPrimary,
//       minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//       ),
//       elevation: 0,
//     ),
//   ),

//   textButtonTheme: TextButtonThemeData(
//     style: TextButton.styleFrom(foregroundColor: AppColors.primaryMid),
//   ),

//   outlinedButtonTheme: OutlinedButtonThemeData(
//     style: OutlinedButton.styleFrom(
//       foregroundColor: AppColors.primaryMid,
//       side: const BorderSide(color: AppColors.primaryMid),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//       ),
//       minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
//     ),
//   ),

//   inputDecorationTheme: InputDecorationTheme(
//     filled: true,
//     fillColor: const Color.fromARGB(255, 255, 255, 255),
//     hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
//     contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//       borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//       borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//       borderSide: const BorderSide(color: AppColors.primaryMid, width: 2),
//     ),
//   ),

//   chipTheme: ChipThemeData(
//     backgroundColor: const Color(0xFF1E1E1E),
//     selectedColor: AppColors.primary.withValues(alpha: 0.3),
//     labelStyle: const TextStyle(fontSize: 13, color: Colors.white),
//     side: const BorderSide(color: Color(0xFF2C2C2C)),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(AppSizes.radiusFull),
//     ),
//   ),

//   cardTheme: CardThemeData(
//     color: const Color(0xFFFFFFFF),
//     elevation: 0,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(AppSizes.radiusLg),
//       side: const BorderSide(color: Color(0xFF2C2C2C), width: 0.5),
//     ),
//     margin: const EdgeInsets.only(bottom: 10),
//   ),

//   dividerTheme: const DividerThemeData(
//     color: Color(0xFF2C2C2C),
//     thickness: 0.5,
//   ),

//   drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1E1E1E)),

//   switchTheme: SwitchThemeData(
//     thumbColor: WidgetStateProperty.resolveWith(
//       (states) => states.contains(WidgetState.selected)
//           ? Colors.white
//           : const Color(0xFF888780),
//     ),
//     trackColor: WidgetStateProperty.resolveWith(
//       (states) => states.contains(WidgetState.selected)
//           ? AppColors.primaryMid
//           : const Color(0xFF2C2C2C),
//     ),
//   ),
// );
