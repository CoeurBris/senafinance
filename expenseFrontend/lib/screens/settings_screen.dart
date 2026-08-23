import 'dart:io';

import 'package:app_expenses/l10n/app_localizations.dart';
import 'package:app_expenses/providers/locale_provider.dart';
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
  bool _weeklySummary = false;
  bool _cloudBackup = true;

  String _userName = 'Victoire Hounkpatin';
  String _userEmail = 'victoire@gmail.com';
  String _currency = 'FCFA';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await _authService.getUserName();
    final email = await _authService.getUserEmail();

    if (mounted) {
      setState(() {
        if (name != null && name.isNotEmpty) _userName = name;
        if (email != null && email.isNotEmpty) _userEmail = email;
      });
    }
  }

  String get _initials {
    final parts = _userName.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return 'VH';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // ── Action Déconnexion ─────────────────────────────────
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Déconnexion', style: TextStyle(fontWeight: FontWeight.w600)),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE24B4A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      title: Text(AppLocalizations.of(context)!.language),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Français'),
            onTap: () {
              appLocaleNotifier.value = const Locale('fr');
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            title: const Text('English'),
            onTap: () {
              appLocaleNotifier.value = const Locale('en');
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Colors.black87,
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Paramètres',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: const Color(0xFFE5E5E5), height: 0.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileCard(
            userName: _userName,
            userEmail: _userEmail,
            initials: _initials,
          ),
          const SizedBox(height: 20),

          const _SectionLabel(label: 'Général'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _NavRow(
                icon: Icons.person_outline_rounded,
                iconBg: const Color(0xFFE6F1FB),
                iconColor: const Color(0xFF185FA5),
                title: "Nom d'affichage",
                subtitle: _userName,
                onTap: () => _showEditNameSheet(context),
              ),
              _NavRow(
                icon: Icons.monetization_on_outlined,
                iconBg: const Color(0xFFE1F5EE),
                iconColor: AppColors.primary,
                title: 'Devise',
                subtitle: _currency,
                onTap: () => _showCurrencySheet(context),
              ),
              _NavRow(
                icon: Icons.language_rounded,
                iconBg: const Color(0xFFFAEEDA),
                iconColor: const Color(0xFF854F0B),
                title: AppLocalizations.of(context)!.language,
                subtitle: AppLocalizations.of(context)!.currentLanguage,
                isLast: true,
                onTap: () {
                  _showLanguageDialog(context);
                },
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
                iconBg: const Color(0xFFEEEDFE),
                iconColor: const Color(0xFF534AB7),
                title: 'Thème',
                subtitle: 'Système (clair)',
                trailing: const _Pill(label: 'Auto'),
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
                iconBg: const Color(0xFFE1F5EE),
                iconColor: const Color(0xFF0F6E56),
                title: 'Rappels de dépenses',
                subtitle: 'Chaque soir à 20h',
                value: _remindersEnabled,
                onChanged: (v) => setState(() => _remindersEnabled = v),
              ),
              _ToggleRow(
                icon: Icons.warning_amber_rounded,
                iconBg: const Color(0xFFFCEBEB),
                iconColor: const Color(0xFFA32D2D),
                title: 'Alertes budget',
                subtitle: 'À 80% du seuil',
                value: _budgetAlerts,
                onChanged: (v) => setState(() => _budgetAlerts = v),
              ),
              _ToggleRow(
                icon: Icons.description_outlined,
                iconBg: const Color(0xFFF1EFE8),
                iconColor: const Color(0xFF5F5E5A),
                title: 'Résumé hebdomadaire',
                subtitle: 'Chaque lundi matin',
                value: _weeklySummary,
                isLast: true,
                onChanged: (v) => setState(() => _weeklySummary = v),
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
                iconBg: const Color(0xFFE1F5EE),
                iconColor: const Color(0xFF0F6E56),
                title: 'Exporter les données',
                subtitle: 'CSV ou Excel',
                onTap: () => _showExportSheet(context),
              ),
              _ToggleRow(
                icon: Icons.cloud_upload_outlined,
                iconBg: const Color(0xFFF1EFE8),
                iconColor: const Color(0xFF5F5E5A),
                title: 'Sauvegarde cloud',
                subtitle: "Dernière sync: aujourd'hui",
                value: _cloudBackup,
                isLast: true,
                onChanged: (v) => setState(() => _cloudBackup = v),
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
                iconBg: const Color(0xFFFCEBEB),
                iconColor: const Color(0xFFE24B4A),
                title: 'Se déconnecter',
                titleColor: const Color(0xFFE24B4A),
                isLast: false,
                onTap: _logout,
              ),
              _NavRow(
                icon: Icons.delete_outline_rounded,
                iconBg: const Color(0xFFFCEBEB),
                iconColor: const Color(0xFFE24B4A),
                title: 'Supprimer le compte',
                titleColor: const Color(0xFFE24B4A),
                subtitle: 'Action irréversible',
                subtitleColor: const Color(0xFFE24B4A).withValues(alpha: 0.7),
                isLast: true,
                onTap: () => _showDeleteConfirm(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'Gestion Dépenses v1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
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

  // ── Dialogs ─────────────────────────────────────────────

  void _showEditNameSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: _userName);
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Nom d'affichage",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Votre nom',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_name', newName);
                  if (mounted) {
                    setState(() {
                      _userName = newName;
                    });
                  }
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.info,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _showCurrencySheet(BuildContext context) {
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
        title: const Text(
          'Devise',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: currencies
                .map(
                  (c) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    title: Text(c.$2),
                    trailing: Text(
                      c.$1,
                      style: const TextStyle(
                        color: Color(0xFF888780),
                        fontSize: 13,
                      ),
                    ),
                    onTap: () {
                      setState(() => _currency = c.$1);
                      Navigator.pop(ctx);
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

  void _showThemeSheet(BuildContext context) {
    const themes = [
      (Icons.brightness_auto_rounded, 'Automatique (système)'),
      (Icons.light_mode_rounded, 'Clair'),
      (Icons.dark_mode_rounded, 'Sombre'),
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Thème',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: themes
                .map(
                  (t) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: Icon(t.$1, color: const Color(0xFF534AB7)),
                    title: Text(t.$2),
                    onTap: () => Navigator.pop(ctx),
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

  void _showExportSheet(BuildContext context) {
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
              const Text(
                'Exporter les données',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ExportButton(
                      icon: Icons.table_chart_outlined,
                      label: 'CSV',
                      color: const Color(0xFF0F6E56),
                      bg: const Color(0xFFE1F5EE),
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
                      color: const Color(0xFF185FA5),
                      bg: const Color(0xFFE6F1FB),
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

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Supprimer le compte',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const SizedBox(
          width: double.maxFinite,
          child: Text(
            'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
            style: TextStyle(color: Color(0xFF888780)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE24B4A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widgets réutilisables
// ─────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String initials;

  const _ProfileCard({
    required this.userName,
    required this.userEmail,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE6F1FB),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0C447C),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF888780)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F1FB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Compte personnel',
                    style: TextStyle(fontSize: 11, color: Color(0xFF185FA5)),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.black38,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF888780),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 0.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: children),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.subtitleColor,
    this.isLast = false,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final Color? subtitleColor;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFF0F0F0), width: 0.5),
                ),
        ),
        child: Row(
          children: [
            _IconBox(bg: iconBg, color: iconColor, icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: titleColor ?? Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleColor ?? const Color(0xFF888780),
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
                      : Colors.black26,
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
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF0F0F0), width: 0.5),
              ),
      ),
      child: Row(
        children: [
          _IconBox(bg: iconBg, color: iconColor, icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888780),
                    ),
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
  const _IconBox({required this.bg, required this.color, required this.icon});
  final Color bg;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFE8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF888780)),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
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