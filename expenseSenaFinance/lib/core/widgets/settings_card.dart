import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:senafinance/core/theme.dart';

/// Libellé de section (ex: "SÉCURITÉ DU COMPTE")
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
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

/// Carte blanche arrondie qui regroupe plusieurs lignes (NavRow / ToggleRow)
class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 0.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: children),
    );
  }
}

/// Petit carré d'icône coloré (icône + fond teinté)
class IconBox extends StatelessWidget {
  const IconBox({super.key, required this.bg, required this.color, required this.icon});
  final Color bg;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

/// Ligne cliquable avec icône, titre, sous-titre optionnel et chevron
class NavRow extends StatelessWidget {
  const NavRow({
    super.key,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 0.5)),
        ),
        child: Row(
          children: [
            IconBox(bg: iconBg, color: iconColor, icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: titleColor ?? Colors.black87),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 12, color: subtitleColor ?? const Color(0xFF888780)),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: titleColor != null ? titleColor!.withValues(alpha: 0.5) : Colors.black26,
                  size: 18,
                ),
          ],
        ),
      ),
    );
  }
}

/// Ligne avec un switch (toggle) — pour les réglages on/off
class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 0.5)),
      ),
      child: Row(
        children: [
          IconBox(bg: iconBg, color: iconColor, icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(subtitle!, style: const TextStyle(fontSize: 12, color: Color(0xFF888780))),
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

/// Petite pastille (ex: "Auto", "FCFA")
class Pill extends StatelessWidget {
  const Pill({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFE8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF888780))),
    );
  }
}