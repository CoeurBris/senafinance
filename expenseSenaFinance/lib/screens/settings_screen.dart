import 'dart:io';

import 'package:app_expenses/l10n/app_localizations.dart';
import 'package:app_expenses/providers/currency_provider.dart';
import 'package:app_expenses/providers/locale_provider.dart';
import 'package:app_expenses/providers/theme_provider.dart';
import 'package:app_expenses/screens/auth/login_screen.dart';
import 'package:app_expenses/utils/date_utils.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' hide Border, BorderStyle;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../services/expense_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const SettingsScreen({super.key, this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

  bool _remindersEnabled = true;
  bool _budgetAlerts = true;

  // String _userName = 'Utilisateur';
  // String _userEmail = 'utilisateur@gmail.com';
  String _currency = 'FCFA';

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Système';
    }
  }

  void _showThemeSheet(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final themes = [
      (
        ThemeMode.system,
        Icons.brightness_auto_rounded,
        'Automatique (système)',
      ),
      (ThemeMode.light, Icons.light_mode_rounded, 'Clair'),
      (ThemeMode.dark, Icons.dark_mode_rounded, 'Sombre'),
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Thème',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: themes.map((t) {
              final selected = appThemeNotifier.value == t.$1;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Icon(t.$2, color: cs.primary),
                title: Text(t.$3, style: TextStyle(color: cs.onSurface)),
                trailing: selected
                    ? Icon(Icons.check, color: cs.primary)
                    : null,
                onTap: () async {
                  await setThemeMode(t.$1);
                  if (ctx.mounted) Navigator.pop(ctx);
                  setState(() {}); // rafraîchit le sous-titre de la ligne
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // _loadUserData();
  }

  // Future<void> _loadUserData() async {
  //   // final name = await _authService.getUserName();
  //   // final email = await _authService.getUserEmail();

  //   if (mounted) {
  //     setState(() {
  //       // if (name != null && name.isNotEmpty) _userName = name;
  //       // if (email != null && email.isNotEmpty) _userEmail = email;
  //     });
  //   }
  // }

  // String get _initials {
  //   // final parts = _userName.trim().split(' ');
  //   if (parts.isEmpty || parts.first.isEmpty) return 'VH';
  //   if (parts.length == 1) return parts.first[0].toUpperCase();
  //   return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  // }

  // ── Action Déconnexion ─────────────────────────────────
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Déconnexion',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _authService.logout();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              onTap: () async {
                appLocaleNotifier.value = const Locale('fr');
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('pref_locale', 'fr');
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () async {
                appLocaleNotifier.value = const Locale('en');
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('pref_locale', 'en');
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      // Pas de backgroundColor en dur : hérite de scaffoldBackgroundColor
      // (appTheme = clair, appDarkTheme = sombre) selon le thème actif.
      appBar: AppBar(
        // Pas de backgroundColor/elevation en dur : hérite de appBarTheme.
        leading: BackButton(color: cs.onSurface, onPressed: widget.onBack),
        title: Text(
          'Paramètres',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: cs.outline, height: 0.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // _ProfileCard(
          //   userName: _userName,
          //   userEmail: _userEmail,
          //   initials: _initials,
          // ),
          // const SizedBox(height: 20),
          const _SectionLabel(label: 'Général'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _NavRow(
                icon: Icons.monetization_on_outlined,
                accent: AppColors.primary,
                title: 'Devise',
                subtitle: _currency,
                onTap: () => _showCurrencySheet(context),
              ),
              _NavRow(
                icon: Icons.language_rounded,
                accent: AppColors.warning,
                title: AppLocalizations.of(context)!.settingsTitle,
                subtitle: AppLocalizations.of(context)!.settingsSubtitle,
                isLast: true,
                onTap: () => _showLanguageDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const _SectionLabel(label: 'Apparence'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _NavRow(
                icon: Icons.contrast_rounded,
                accent: const Color(0xFF534AB7),
                title: 'Thème',
                subtitle: _themeLabel(appThemeNotifier.value),
                trailing: _Pill(
                  label: appThemeNotifier.value == ThemeMode.system
                      ? 'Auto'
                      : 'Manuel',
                ),
                isLast: true,
                onTap: () => _showThemeSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const _SectionLabel(label: 'Notifications'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _ToggleRow(
                icon: Icons.notifications_outlined,
                accent: AppColors.primary,
                title: 'Rappels de dépenses',
                subtitle: 'Chaque soir à 20h',
                value: _remindersEnabled,
                onChanged: (v) => setState(() => _remindersEnabled = v),
              ),
              _ToggleRow(
                icon: Icons.warning_amber_rounded,
                accent: AppColors.danger,
                title: 'Alertes budget',
                subtitle: 'À 80% du seuil',
                value: _budgetAlerts,
                onChanged: (v) => setState(() => _budgetAlerts = v),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 20),

          const _SectionLabel(label: 'Données & Sécurité'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _NavRow(
                icon: Icons.file_download_outlined,
                accent: AppColors.primary,
                title: 'Exporter les données',
                subtitle: 'CSV ou Excel',
                isLast: true,
                onTap: () => _showExportSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const _SectionLabel(label: 'Compte'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _NavRow(
                icon: Icons.logout_rounded,
                accent: AppColors.danger,
                title: 'Se déconnecter',
                titleColor: AppColors.danger,
                isLast: true,
                onTap: _logout,
              ),
            ],
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'Gestion Dépenses v1.0.0',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Export CSV ──────────────────────────────────────────
  Future<void> _exportCSV(BuildContext context) async {
    try {
      final List<dynamic> expenses = await ExpenseService().getExpenses();

      final rows = <List<dynamic>>[
        ['Titre', 'Montant (FCFA)', 'Catégorie', 'Date'],
        ...expenses.map(
          (e) => [
            e.titre,
            e.montant.toStringAsFixed(0),
            e.categorie,
            AppDateUtils.fullDateTimeFr.format(e.date),
          ],
        ),
      ];

      final csvContent = const ListToCsvConverter().convert(rows);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/depenses.csv');
      await file.writeAsString(csvContent);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Export CSV des dépenses');
    } catch (e) {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'export CSV : $e')),
      );
    }
  }

  // ── Export Excel ────────────────────────────────────────
  Future<void> _exportExcel(BuildContext context) async {
    try {
      final List<dynamic> expenses = await ExpenseService().getExpenses();

      final excel = Excel.createExcel();
      final sheet = excel['Dépenses'];

      sheet.appendRow([
        TextCellValue('Titre'),
        TextCellValue('Montant (FCFA)'),
        TextCellValue('Catégorie'),
        TextCellValue('Date'),
      ]);

      for (final e in expenses) {
        sheet.appendRow([
          TextCellValue(e.titre.toString()),
          TextCellValue(e.montant.toStringAsFixed(0)),
          TextCellValue(e.categorie.toString()),
          TextCellValue(AppDateUtils.fullDateTimeFr.format(e.date)),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/depenses.xlsx');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Export Excel des dépenses');
    } catch (e) {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'export Excel : $e')),
      );
    }
  }

  void _showCurrencySheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const currencies = [
      ('FCFA', 'Franc CFA (FCFA)'),
      ('USD', 'Dollar américain (\$)'),
      ('EUR', 'Euro (€)'),
      ('GBP', 'Livre sterling (£)'),
      ('MAD', 'Dirham marocain (MAD)'),
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Devise',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: currencies
                .map(
                  (c) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    title: Text(c.$2, style: TextStyle(color: cs.onSurface)),
                    trailing: Text(
                      c.$1,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () async {
                      appCurrencyNotifier.value = c.$1;
                      setState(() => _currency = c.$1);
                      await _setStringPref('pref_currency', c.$1);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<void> _setStringPref(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void _showExportSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Exporter les données',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ExportButton(
                      icon: Icons.table_chart_outlined,
                      label: 'CSV',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.pop(ctx);
                        _exportCSV(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ExportButton(
                      icon: Icons.grid_on_outlined,
                      label: 'Excel',
                      color: AppColors.info,
                      onTap: () {
                        Navigator.pop(ctx);
                        _exportExcel(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: children),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.accent,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.isLast = false,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: cs.outline, width: 0.5)),
        ),
        child: Row(
          children: [
            _IconBox(color: accent, icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: titleColor ?? cs.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: titleColor != null
                      ? titleColor!.withValues(alpha: 0.5)
                      : cs.onSurfaceVariant,
                  size: 18,
                ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.accent,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: cs.outline, width: 0.5)),
      ),
      child: Row(
        children: [
          _IconBox(color: accent, icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: cs.onSurface),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.info,
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: cs.onSurfaceVariant.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.20 : 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
