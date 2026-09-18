import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senafinance/models/budget_model.dart';
import 'package:senafinance/models/category_model.dart';
import 'package:senafinance/models/transaction_model.dart';
import 'package:senafinance/providers/budget_provider.dart';
import 'package:senafinance/providers/category_provider.dart';
import 'package:senafinance/providers/transaction_provider.dart';
import 'package:senafinance/screens/profile/profile_screen.dart';


/// ==========================================================================
/// PERIODE D'ANALYSE
/// ==========================================================================

enum PeriodFilter { aujourdhui, semaine, mois, trimestre }

class _PeriodRange {
  final DateTime start;
  final DateTime end;
  const _PeriodRange(this.start, this.end);

  Duration get length => end.difference(start);

  bool contains(DateTime date) => !date.isBefore(start) && date.isBefore(end);

  /// Période équivalente immédiatement précédente (même durée), utilisée
  /// pour calculer les variations en %.
  _PeriodRange get previous {
    final prevEnd = start;
    final prevStart = prevEnd.subtract(length);
    return _PeriodRange(prevStart, prevEnd);
  }
}

_PeriodRange _rangeFor(PeriodFilter filter, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  switch (filter) {
    case PeriodFilter.aujourdhui:
      return _PeriodRange(today, today.add(const Duration(days: 1)));
    case PeriodFilter.semaine:
      final start = today.subtract(Duration(days: today.weekday - 1));
      return _PeriodRange(start, today.add(const Duration(days: 1)));
    case PeriodFilter.mois:
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 1);
      return _PeriodRange(start, end);
    case PeriodFilter.trimestre:
      final start = DateTime(now.year, now.month - 2, 1);
      final end = DateTime(now.year, now.month + 1, 1);
      return _PeriodRange(start, end);
  }
}

const List<String> _moisFr = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

String _periodLabel(_PeriodRange range) {
  final lastDay = range.end.subtract(const Duration(days: 1));
  String fmt(DateTime d) => '${d.day} ${_moisFr[d.month - 1]}';
  if (range.start.year == lastDay.year) {
    return '${fmt(range.start)} - ${fmt(lastDay)} ${lastDay.year}';
  }
  return '${fmt(range.start)} ${range.start.year} - ${fmt(lastDay)} ${lastDay.year}';
}

/// ==========================================================================
/// MODELES D'AFFICHAGE (dérivés des vraies données à chaque build)
/// ==========================================================================

enum AdviceType { info, success, warning }

class _CategoryStat {
  final String name;
  final Color color;
  final IconData icon;
  final double amount;
  final double percent; // 0-100
  final int count;

  const _CategoryStat({
    required this.name,
    required this.color,
    required this.icon,
    required this.amount,
    required this.percent,
    required this.count,
  });
}

class _EvolutionPoint {
  final String label;
  final double amount;
  const _EvolutionPoint({required this.label, required this.amount});
}

const List<Color> _fallbackPalette = [
  Color(0xFF8B7CF6),
  Color(0xFF4FC3F7),
  Color(0xFF34C77B),
  Color.fromARGB(255, 2, 254, 116),
  Color(0xFFEF5A6F),
  Color(0xFF9E9E9E),
];

Color _colorForCategory(
  String name,
  List<CategoryModel> categories,
  int fallbackIndex,
) {
  final match = categories.where(
    (c) => c.nom.toLowerCase() == name.toLowerCase(),
  );
  if (match.isNotEmpty && match.first.couleur != null) {
    final parsed = _parseHexColor(match.first.couleur!);
    if (parsed != null) return parsed;
  }
  return _fallbackPalette[fallbackIndex % _fallbackPalette.length];
}

List<_CategoryStat> _computeCategoryStats<T>({
  required List<T> items,
  required String Function(T) categoryOf,
  required double Function(T) amountOf,
  required List<CategoryModel> categories,
}) {
  final Map<String, List<T>> grouped = {};
  for (final item in items) {
    grouped.putIfAbsent(categoryOf(item), () => []).add(item);
  }
  final total = items.fold<double>(0, (s, i) => s + amountOf(i));
  final stats = <_CategoryStat>[];
  int colorIndex = 0;
  for (final entry in grouped.entries) {
    final amount = entry.value.fold<double>(0, (s, i) => s + amountOf(i));
    stats.add(
      _CategoryStat(
        name: entry.key,
        color: _colorForCategory(entry.key, categories, colorIndex),
        icon: _iconForCategory(entry.key),
        amount: amount,
        percent: total == 0 ? 0 : (amount / total) * 100,
        count: entry.value.length,
      ),
    );
    colorIndex++;
  }
  stats.sort((a, b) => b.amount.compareTo(a.amount));
  return stats;
}

Color? _parseHexColor(String hex) {
  var value = hex.trim().replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return null;
  final intValue = int.tryParse(value, radix: 16);
  if (intValue == null) return null;
  return Color(intValue);
}

IconData _iconForCategory(String name) {
  final n = name.toLowerCase();
  if (n.contains('logement') || n.contains('loyer')) return Icons.home_outlined;
  if (n.contains('loisir') || n.contains('sortie')) {
    return Icons.local_activity_outlined;
  }
  if (n.contains('aliment') || n.contains('resto') || n.contains('course')) {
    return Icons.restaurant_outlined;
  }
  if (n.contains('transport') || n.contains('carburant')) {
    return Icons.directions_car_outlined;
  }
  if (n.contains('santé') || n.contains('sante')) {
    return Icons.local_hospital_outlined;
  }
  if (n.contains('éduc') || n.contains('educ') || n.contains('école')) {
    return Icons.school_outlined;
  }
  return Icons.category_outlined;
}

/// ==========================================================================
/// PALETTE THEME-AWARE
/// ==========================================================================

class _Palette {
  final ColorScheme cs;
  _Palette(BuildContext context) : cs = Theme.of(context).colorScheme;

  bool get isDark => cs.brightness == Brightness.dark;

  Color get bg => cs.surface;
  Color get card => cs.surface;
  Color get border => cs.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.6);

  Color get textDark => cs.onSurface;
  Color get textGrey => cs.onSurface.withValues(alpha: 0.6);

  Color get chipBg => cs.onSurface.withValues(alpha: 0.06);

  Color get accent => cs.primary;
  Color get onAccent => cs.onPrimary;

  Color get tooltipBg => cs.inverseSurface;
  Color get tooltipText => cs.onInverseSurface;

  static const Color green = Color(0xFF34C77B);
  static const Color red = Color(0xFFEF5A6F);
  static const Color orange = Color(0xFFFFA726);
  static const Color blue = Color(0xFF4FC3F7);

  Color get greenBg => green.withValues(alpha: isDark ? 0.2 : 0.12);
  Color get redBg => red.withValues(alpha: isDark ? 0.2 : 0.12);
  Color get orangeBg => orange.withValues(alpha: isDark ? 0.2 : 0.12);
  Color get blueBg => blue.withValues(alpha: isDark ? 0.2 : 0.12);
}

String _formatFcfa(double value, {bool withSign = false}) {
  final rounded = value.round();
  final str = rounded.abs().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    final posFromEnd = str.length - i;
    buffer.write(str[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(' ');
  }
  final sign = rounded < 0 ? '-' : (withSign ? '+' : '');
  return '$sign$buffer';
}

String _formatCompact(double value) {
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return value.round().toString();
}

/// ==========================================================================
/// ECRAN PRINCIPAL
/// ==========================================================================

class StatsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const StatsScreen({super.key, this.onBack});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

double _spentForBudget(BudgetModel b, List<TransactionModel> transactions) {
  final categoryName = (b.category?.nom.isNotEmpty ?? false)
      ? b.category!.nom
      : b.nom;

  return transactions
      .where((t) {
        if (!t.isExpense) return false;
        if (t.category.toLowerCase() != categoryName.toLowerCase()) {
          return false;
        }
        if (b.dateDebut != null && t.date.isBefore(b.dateDebut!)) return false;
        if (b.dateFin != null && t.date.isAfter(b.dateFin!)) return false;
        return true;
      })
      .fold<double>(0, (sum, t) => sum + t.amount);
}

class _StatsScreenState extends State<StatsScreen> {
  PeriodFilter _selectedPeriod = PeriodFilter.mois;
  bool _smoothCurve = true;
  int? _touchedEvolutionIndex;

  _Palette get _p => _Palette(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureDataLoaded());
  }

  /// Charge les données une seule fois si elles ne sont pas déjà en mémoire
  /// (les providers étant déjà instanciés au niveau de l'app via
  /// MultiProvider, on évite de recharger si un autre écran l'a déjà fait).
  void _ensureDataLoaded() {
    final txProvider = context.read<TransactionProvider>();
    final catProvider = context.read<CategoryProvider>();
    final budgetProvider = context.read<BudgetProvider>();

    if (txProvider.transactions.isEmpty && !txProvider.isLoading) {
      txProvider.loadTransactions();
    }
    if (catProvider.categories.isEmpty && !catProvider.isLoading) {
      catProvider.loadCategories();
    }
    if (budgetProvider.budgets.isEmpty && !budgetProvider.isLoading) {
      budgetProvider.loadBudgets();
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<TransactionProvider>().loadTransactions(),
      context.read<CategoryProvider>().loadCategories(),
      context.read<BudgetProvider>().loadBudgets(),
    ]);
  }

  void _onPeriodChanged(PeriodFilter period) {
    setState(() {
      _selectedPeriod = period;
      _touchedEvolutionIndex = null;
    });
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final catProvider = context.watch<CategoryProvider>();
    final budgetProvider = context.watch<BudgetProvider>();

    final isInitialLoading =
        (txProvider.isLoading && txProvider.transactions.isEmpty) ||
        (catProvider.isLoading && catProvider.categories.isEmpty) ||
        (budgetProvider.isLoading && budgetProvider.budgets.isEmpty);

    return Scaffold(
      backgroundColor: _p.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            if (isInitialLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: _buildBody(
                  transactions: txProvider.transactions,
                  categories: catProvider.categories,
                  budgets: budgetProvider.budgets,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
    required List<BudgetModel> budgets,
  }) {
    final now = DateTime.now();
    final range = _rangeFor(_selectedPeriod, now);
    final previousRange = range.previous;

    final periodTx = transactions.where((t) => range.contains(t.date)).toList();
    final previousTx = transactions
        .where((t) => previousRange.contains(t.date))
        .toList();

    final revenus = periodTx
        .where((t) => t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final depenses = periodTx
        .where((t) => t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final revenusPrev = previousTx
        .where((t) => t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final depensesPrev = previousTx
        .where((t) => t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final soldeNet = revenus - depenses;
    final expenseTx = periodTx.where((t) => t.isExpense).toList();

    // final moyenne = expenseTx.isEmpty
    //     ? 0.0
    //     : depenses / expenseTx.length;
    // final plusGrosse = expenseTx.isEmpty
    //     ? 0.0
    //     : expenseTx.map((t) => t.amount).reduce(math.max);

    double variation(double current, double previous) {
      if (previous == 0) return current == 0 ? 0 : 100;
      return ((current - previous) / previous) * 100;
    }

    final depensesVariation = variation(depenses, depensesPrev);
    final revenusVariation = variation(revenus, revenusPrev);
    final ratioEpargne = revenus <= 0
        ? 0.0
        : ((soldeNet / revenus) * 100).clamp(-999, 100);

    // ---- Répartition par catégorie : 3 vues ----
    final categoryStats = _computeCategoryStats(
      items: expenseTx,
      categoryOf: (t) => t.category,
      amountOf: (t) => t.amount,
      categories: categories,
    );
    final totalEngage = categoryStats.fold<double>(0, (s, c) => s + c.amount);

    final transactionCategoryStats = _computeCategoryStats(
      items: periodTx, // toutes les transactions : revenus + dépenses
      categoryOf: (t) => t.category,
      amountOf: (t) => t.amount,
      categories: categories,
    );
    final totalTransactionsEngage = transactionCategoryStats.fold<double>(
      0,
      (s, c) => s + c.amount,
    );

    // ---- Budgets actifs ----
    final activeBudgets = budgets.where((b) => b.actif).toList();

    final budgetCategoryStats = _computeCategoryStats(
      items: activeBudgets,
      categoryOf: (b) => b.category?.nom ?? b.nom,
      amountOf: (b) => b.montant,
      categories: categories,
    );
    final totalBudgetsEngage = budgetCategoryStats.fold<double>(
      0,
      (s, c) => s + c.amount,
    );

    // // ---- Plus grosses dépenses ----
    final biggestExpenses = [...expenseTx]
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final top3Expenses = biggestExpenses.take(3).toList();

    // ---- Évolution journalière ----
    final Map<DateTime, double> byDay = {};
    for (final t in expenseTx) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      byDay[day] = (byDay[day] ?? 0) + t.amount;
    }
    final sortedDays = byDay.keys.toList()..sort();
    final evolution = sortedDays
        .map(
          (d) => _EvolutionPoint(
            label:
                '${d.day.toString().padLeft(2, '0')} ${_moisFr[d.month - 1]}',
            amount: byDay[d]!,
          ),
        )
        .toList();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _buildPeriodSelector(_periodLabel(range)),
          const SizedBox(height: 16),
          _buildSoldeCard(soldeNet: soldeNet, epargneSaine: soldeNet >= 0),
          const SizedBox(height: 12),
          _buildDepensesRevenusRow(
            depenses: depenses,
            depensesVariation: depensesVariation,
            revenus: revenus,
            revenusVariation: revenusVariation,
          ),
          const SizedBox(height: 16),
          _buildRatioFluxCard(
            revenus: revenus,
            depenses: depenses,
            ratioEpargnePercent: ratioEpargne.toDouble(),
          ),
          const SizedBox(height: 16),
          _buildRepartitionCard(
            depensesStats: categoryStats,
            depensesTotal: totalEngage,
            transactionsStats: transactionCategoryStats,
            transactionsTotal: totalTransactionsEngage,
            budgetsStats: budgetCategoryStats,
            budgetsTotal: totalBudgetsEngage,
          ),
          const SizedBox(height: 16),
          if (categoryStats.isNotEmpty) ...[
            _buildTopCategoriesCard(categoryStats),
            const SizedBox(height: 16),
          ],
          _buildBiggestExpensesCard(top3Expenses),
          const SizedBox(height: 16),
          _buildEvolutionCard(evolution),
          const SizedBox(height: 16),
          _buildBudgetsCard(activeBudgets, transactions),
          const SizedBox(height: 16),
          // _buildAdvicesCard(advices),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // APP BAR
  // -------------------------------------------------------------------
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: _p.textDark),
            onPressed: _handleBack,
          ),
          Expanded(
            child: Text(
              'Statistiques',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _p.textDark,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _p.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: _p.onAccent, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // SELECTEUR DE PERIODE
  // -------------------------------------------------------------------
  Widget _buildPeriodSelector(String periodLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 14, color: _p.textGrey),
            const SizedBox(width: 6),
            Text(
              'Période d\'analyse   $periodLabel',
              style: TextStyle(
                fontSize: 12.5,
                color: _p.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _periodChip('Aujourd\'hui', PeriodFilter.aujourdhui),
              const SizedBox(width: 8),
              _periodChip('Cette semaine', PeriodFilter.semaine),
              const SizedBox(width: 8),
              _periodChip('Ce mois', PeriodFilter.mois),
              const SizedBox(width: 8),
              _periodChip('3 derniers mois', PeriodFilter.trimestre),
            ],
          ),
        ),
      ],
    );
  }

  Widget _periodChip(String label, PeriodFilter period) {
    final selected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => _onPeriodChanged(period),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _p.accent : _p.chipBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? _p.onAccent : _p.textDark,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // CARD: SOLDE NET DISPONIBLE
  // -------------------------------------------------------------------
  Widget _buildSoldeCard({
    required double soldeNet,
    required bool epargneSaine,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SOLDE NET DISPONIBLE',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _p.textGrey,
                  letterSpacing: 0.4,
                ),
              ),
              _badge(
                epargneSaine ? 'Épargne saine' : 'Déficit',
                epargneSaine ? _Palette.green : _Palette.red,
                epargneSaine ? _p.greenBg : _p.redBg,
                epargneSaine
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatFcfa(soldeNet, withSign: true)} FCFA',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _p.textDark,
            ),
          ),
          const SizedBox(height: 18),
          // Row(
          //   children: [
          //     _statColumn('Moyenne', '${_formatFcfa(moyenne)} F'),
          //     _vDivider(),
          //     _statColumn('Plus grosse', '${_formatFcfa(plusGrosse)} F'),
          //     _vDivider(),
          //     _statColumn('Opérations', '$operations tx'),
          //   ],
          // ),
        ],
      ),
    );
  }

  // Widget _statColumn(String label, String value) {
  //   return Expanded(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(value,
  //             style: TextStyle(
  //                 fontSize: 14.5,
  //                 fontWeight: FontWeight.w700,
  //                 color: _p.textDark)),
  //         const SizedBox(height: 3),
  //         Text(label, style: TextStyle(fontSize: 11.5, color: _p.textGrey)),
  //       ],
  //     ),
  //   );
  // }

  // Widget _vDivider() => Container(
  //       width: 1,
  //       height: 30,
  //       margin: const EdgeInsets.symmetric(horizontal: 8),
  //       color: _p.border,
  //     );

  // -------------------------------------------------------------------
  // ROW: DEPENSES / REVENUS
  // -------------------------------------------------------------------
  Widget _buildDepensesRevenusRow({
    required double depenses,
    required double depensesVariation,
    required double revenus,
    required double revenusVariation,
  }) {
    return Row(
      children: [
        Expanded(
          child: _miniStatCard(
            icon: Icons.arrow_downward,
            iconColor: _Palette.red,
            iconBg: _p.redBg,
            variationLabel: '${depensesVariation.abs().toStringAsFixed(1)}%',
            variationUp: depensesVariation > 0,
            amount: '${_formatFcfa(depenses)} FCFA',
            label: 'Dépenses',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _miniStatCard(
            icon: Icons.arrow_upward,
            iconColor: _Palette.green,
            iconBg: _p.greenBg,
            variationLabel: '${revenusVariation.abs().toStringAsFixed(1)}%',
            variationUp: revenusVariation >= 0,
            amount: '${_formatFcfa(revenus)} FCFA',
            label: 'Revenus',
          ),
        ),
      ],
    );
  }

  Widget _miniStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String variationLabel,
    required bool variationUp,
    required String amount,
    required String label,
  }) {
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              Row(
                children: [
                  Icon(
                    variationUp ? Icons.trending_up : Icons.trending_down,
                    size: 13,
                    color: variationUp ? _Palette.green : _Palette.red,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    variationLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: variationUp ? _Palette.green : _Palette.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: _p.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11.5, color: _p.textGrey)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // CARD: RATIO FLUX FINANCIER
  // -------------------------------------------------------------------
  Widget _buildRatioFluxCard({
    required double revenus,
    required double depenses,
    required double ratioEpargnePercent,
  }) {
    final total = revenus + depenses;
    final revenusFrac = total == 0 ? 0.0 : revenus / total;
    final depensesFrac = total == 0 ? 0.0 : depenses / total;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ratio Flux Financier',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _p.textDark,
                ),
              ),
              _badge(
                '${ratioEpargnePercent.toStringAsFixed(1)}% épargné',
                ratioEpargnePercent >= 0 ? _Palette.green : _Palette.red,
                ratioEpargnePercent >= 0 ? _p.greenBg : _p.redBg,
                null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _legendRow(_Palette.green, 'Revenus', '${_formatFcfa(revenus)} FCFA'),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: total == 0
                  ? Container(color: _p.chipBg)
                  : Row(
                      children: [
                        Expanded(
                          flex: (revenusFrac * 1000).round().clamp(1, 100000),
                          child: Container(color: _Palette.green),
                        ),
                        Expanded(
                          flex: (depensesFrac * 1000).round().clamp(1, 100000),
                          child: Container(color: _p.chipBg),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 14),
          _legendRow(_p.textGrey, 'Dépenses', '${_formatFcfa(depenses)} FCFA'),
        ],
      ),
    );
  }

  Widget _legendRow(Color dotColor, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13, color: _p.textDark)),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _p.textDark,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // CARD: REPARTITION PAR CATEGORIE (donut)
  // -------------------------------------------------------------------
  //

  Widget _buildRepartitionCard({
    required List<_CategoryStat> depensesStats,
    required double depensesTotal,
    required List<_CategoryStat> transactionsStats,
    required double transactionsTotal,
    required List<_CategoryStat> budgetsStats,
    required double budgetsTotal,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Répartition par Catégorie',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _p.textDark,
                ),
              ),
              Icon(Icons.pie_chart_outline, size: 18, color: _p.textGrey),
            ],
          ),
          Text(
            'Vue d\'ensemble de la période sélectionnée',
            style: TextStyle(fontSize: 11.5, color: _p.textGrey),
          ),
          const SizedBox(height: 20),
          _repartitionSection(
            label: 'Dépenses',
            icon: Icons.arrow_downward,
            accentColor: _Palette.red,
            stats: depensesStats,
            total: depensesTotal,
            emptyLabel: 'Aucune dépense sur cette période',
          ),
          const SizedBox(height: 22),
          Divider(color: _p.border, height: 1),
          const SizedBox(height: 22),
          _repartitionSection(
            label: 'Transactions',
            icon: Icons.swap_vert,
            accentColor: _Palette.blue,
            stats: transactionsStats,
            total: transactionsTotal,
            emptyLabel: 'Aucune transaction sur cette période',
          ),
          const SizedBox(height: 22),
          Divider(color: _p.border, height: 1),
          const SizedBox(height: 22),
          _repartitionSection(
            label: 'Budgets',
            icon: Icons.savings_outlined,
            accentColor: _Palette.orange,
            stats: budgetsStats,
            total: budgetsTotal,
            emptyLabel: 'Aucun budget actif sur cette période',
          ),
        ],
      ),
    );
  }

  Widget _repartitionSection({
    required String label,
    required IconData icon,
    required Color accentColor,
    required List<_CategoryStat> stats,
    required double total,
    required String emptyLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: accentColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _p.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (stats.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              emptyLabel,
              style: TextStyle(fontSize: 12.5, color: _p.textGrey),
            ),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(96, 96),
                      painter: _DonutChartPainter(
                        categories: stats,
                        trackColor: _p.chipBg,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatCompact(total),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _p.textDark,
                          ),
                        ),
                        Text(
                          'FCFA',
                          style: TextStyle(fontSize: 9.5, color: _p.textGrey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: stats.take(4).map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: c.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: _p.textDark,
                              ),
                            ),
                          ),
                          Text(
                            '${c.percent.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _p.textDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        if (stats.length > 4) ...[
          const SizedBox(height: 4),
          Text(
            '+ ${stats.length - 4} autre${stats.length - 4 > 1 ? 's' : ''} catégorie${stats.length - 4 > 1 ? 's' : ''}',
            style: TextStyle(fontSize: 11, color: _p.textGrey),
          ),
        ],
      ],
    );
  }

  // -------------------------------------------------------------------
  // CARD: TOP CATEGORIES DEPENSEES
  // -------------------------------------------------------------------
  Widget _buildTopCategoriesCard(List<_CategoryStat> categoryStats) {
    final top3 = categoryStats.take(3).toList();
    final maxAmount = top3.isEmpty
        ? 1.0
        : top3.map((e) => e.amount).reduce(math.max);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Catégories Dépensières',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _p.textDark,
                ),
              ),
              Icon(Icons.bar_chart, size: 18, color: _p.textGrey),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < top3.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == top3.length - 1 ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${i + 1}. ${top3[i].name}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _p.textDark,
                        ),
                      ),
                      Text(
                        '${_formatFcfa(top3[i].amount)} FCFA',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _p.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: maxAmount == 0
                          ? 0
                          : (top3[i].amount / maxAmount).clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: _p.chipBg,
                      valueColor: AlwaysStoppedAnimation<Color>(top3[i].color),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // CARD: PLUS GROSSES DEPENSES
  // -------------------------------------------------------------------
  Widget _buildBiggestExpensesCard(List<TransactionModel> top3Expenses) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plus Grosses Dépenses',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _p.textDark,
            ),
          ),
          const SizedBox(height: 12),
          if (top3Expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aucune dépense sur cette période',
                style: TextStyle(fontSize: 12.5, color: _p.textGrey),
              ),
            )
          else
            ...top3Expenses.map((e) {
              final color = _colorForCategory(e.category, const [], 0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _iconForCategory(e.category),
                        size: 18,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: _p.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${e.category} • ${e.formattedDate}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: _p.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '-${_formatFcfa(e.amount)} F',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _Palette.red,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // CARD: EVOLUTION DES DEPENSES
  // -------------------------------------------------------------------
  Widget _buildEvolutionCard(List<_EvolutionPoint> evolution) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Évolution des Dépenses',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _p.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _smoothCurve = !_smoothCurve),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _p.chipBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _smoothCurve ? 'Courbe lissée' : 'Courbe brute',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: _p.textDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Flux temporel journalier',
            style: TextStyle(fontSize: 11.5, color: _p.textGrey),
          ),
          const SizedBox(height: 12),
          if (evolution.length < 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'Pas assez de données pour tracer une courbe',
                  style: TextStyle(fontSize: 12.5, color: _p.textGrey),
                ),
              ),
            )
          else
            SizedBox(
              height: 170,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanUpdate: (details) {
                      final index = _indexForDx(
                        details.localPosition.dx,
                        constraints.maxWidth,
                        evolution.length,
                      );
                      setState(() => _touchedEvolutionIndex = index);
                    },
                    onPanDown: (details) {
                      final index = _indexForDx(
                        details.localPosition.dx,
                        constraints.maxWidth,
                        evolution.length,
                      );
                      setState(() => _touchedEvolutionIndex = index);
                    },
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, 170),
                      painter: _AreaChartPainter(
                        points: evolution,
                        smooth: _smoothCurve,
                        touchedIndex: _touchedEvolutionIndex,
                        lineColor: _Palette.green,
                        labelColor: _p.textGrey,
                        tooltipBg: _p.tooltipBg,
                        tooltipText: _p.tooltipText,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  int _indexForDx(double dx, double width, int count) {
    if (count == 0) return 0;
    final step = width / (count - 1).clamp(1, 999);
    final index = (dx / step).round();
    return index.clamp(0, count - 1);
  }

  // -------------------------------------------------------------------
  // CARD: ETAT DES BUDGETS
  // -------------------------------------------------------------------
  Widget _buildBudgetsCard(
    List<BudgetModel> budgets,
    List<TransactionModel> transactions) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 17,
                    color: _p.textDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'État des Budgets',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _p.textDark,
                    ),
                  ),
                ],
              ),
              Text(
                'Gérer',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _p.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (budgets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Aucun budget actif pour le moment',
                style: TextStyle(fontSize: 12.5, color: _p.textGrey),
              ),
            )
          else
            for (int i = 0; i < budgets.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == budgets.length - 1 ? 0 : 18,
                ),
                child: _budgetRow(budgets[i], _spentForBudget(budgets[i], transactions)),
              ),
        ],
      ),
    ); // fin
  }

  Widget _budgetRow(BudgetModel b, double spent) {
    final exceeded = spent > b.montant;
    final restant = b.montant - spent;
    final barColor = exceeded ? _Palette.red : _Palette.green;
    final exactPercent = b.montant <= 0 ? 0.0 : (spent / b.montant) * 100;
    final progress = b.montant <= 0
        ? 0.0
        : (spent / b.montant).clamp(0, 1).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              b.nom,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _p.textDark,
              ),
            ),
            _badge(
              exceeded ? 'Dépassé' : 'Normal',
              exceeded ? _Palette.red : _Palette.green,
              exceeded ? _p.redBg : _p.greenBg,
              null,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          exceeded
              ? 'Dépassé de ${_formatFcfa(spent - b.montant)} F'
              : 'Reste : ${_formatFcfa(restant)} FCFA',
          style: TextStyle(
            fontSize: 12,
            color: exceeded ? _Palette.red : _p.textGrey,
            fontWeight: exceeded ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            backgroundColor: _p.chipBg,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_formatFcfa(spent)} FCFA',
              style: TextStyle(fontSize: 11.5, color: _p.textGrey),
            ),
            Text(
              '${_formatFcfa(b.montant)} FCFA (${exactPercent.toStringAsFixed(0)}%)',
              style: TextStyle(fontSize: 11.5, color: _p.textGrey),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // HELPERS COMMUNS
  // -------------------------------------------------------------------
  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _p.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _p.border, width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _p.isDark ? 0.0 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _badge(String text, Color color, Color bg, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// ==========================================================================
/// CUSTOM PAINTERS
/// ==========================================================================

class _DonutChartPainter extends CustomPainter {
  final List<_CategoryStat> categories;
  final Color trackColor;
  _DonutChartPainter({required this.categories, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final total = categories.fold<double>(0, (sum, c) => sum + c.amount);
    if (total <= 0) return;

    final strokeWidth = size.width * 0.16;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Piste de fond (visible si les segments ne couvrent pas 360°).
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    double startAngle = -math.pi / 2;
    const gapRadians = 0.05;

    for (final c in categories) {
      final sweep = (c.amount / total) * (2 * math.pi) - gapRadians;
      final paint = Paint()
        ..color = c.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        startAngle,
        sweep.clamp(0, 2 * math.pi),
        false,
        paint,
      );
      startAngle += sweep + gapRadians;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.categories != categories ||
        oldDelegate.trackColor != trackColor;
  }
}

/// Graphique en aire (courbe + dégradé) pour l'évolution des dépenses,
/// avec un point "touché" affichant un tooltip. Toutes les couleurs sont
/// injectées depuis le widget parent (donc theme-aware).
class _AreaChartPainter extends CustomPainter {
  final List<_EvolutionPoint> points;
  final bool smooth;
  final int? touchedIndex;
  final Color lineColor;
  final Color labelColor;
  final Color tooltipBg;
  final Color tooltipText;

  _AreaChartPainter({
    required this.points,
    required this.smooth,
    required this.touchedIndex,
    required this.lineColor,
    required this.labelColor,
    required this.tooltipBg,
    required this.tooltipText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const topPadding = 36.0;
    const bottomPadding = 20.0;
    final chartHeight = size.height - topPadding - bottomPadding;
    final maxValue = points.map((p) => p.amount).reduce(math.max) * 1.15 + 1;
    const minValue = 0.0;

    final stepX = points.length > 1
        ? size.width / (points.length - 1)
        : size.width;

    Offset offsetFor(int i) {
      final x = i * stepX;
      final normalized = (points[i].amount - minValue) / (maxValue - minValue);
      final y = topPadding + chartHeight - (normalized * chartHeight);
      return Offset(x, y);
    }

    final linePath = Path();
    final fillPath = Path();

    if (smooth && points.length > 1) {
      linePath.moveTo(offsetFor(0).dx, offsetFor(0).dy);
      fillPath.moveTo(offsetFor(0).dx, topPadding + chartHeight);
      fillPath.lineTo(offsetFor(0).dx, offsetFor(0).dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = offsetFor(i);
        final p1 = offsetFor(i + 1);
        final midX = (p0.dx + p1.dx) / 2;
        linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
        fillPath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
      }
      fillPath.lineTo(
        offsetFor(points.length - 1).dx,
        topPadding + chartHeight,
      );
      fillPath.close();
    } else {
      linePath.moveTo(offsetFor(0).dx, offsetFor(0).dy);
      fillPath.moveTo(offsetFor(0).dx, topPadding + chartHeight);
      fillPath.lineTo(offsetFor(0).dx, offsetFor(0).dy);
      for (int i = 1; i < points.length; i++) {
        final p = offsetFor(i);
        linePath.lineTo(p.dx, p.dy);
        fillPath.lineTo(p.dx, p.dy);
      }
      fillPath.lineTo(
        offsetFor(points.length - 1).dx,
        topPadding + chartHeight,
      );
      fillPath.close();
    }

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.28),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, topPadding, size.width, chartHeight));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    final labelIndices = <int>{
      0,
      (points.length * 0.25).round().clamp(0, points.length - 1),
      (points.length * 0.5).round().clamp(0, points.length - 1),
      (points.length * 0.75).round().clamp(0, points.length - 1),
      points.length - 1,
    };
    for (final i in labelIndices) {
      final p = offsetFor(i);
      final tp = TextPainter(
        text: TextSpan(
          text: points[i].label.split(' ').first,
          style: TextStyle(fontSize: 10, color: labelColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(p.dx - tp.width / 2, size.height - bottomPadding + 4),
      );
    }

    final idx = touchedIndex ?? _defaultPeakIndex();
    if (idx >= 0 && idx < points.length) {
      final p = offsetFor(idx);

      canvas.drawCircle(
        p,
        4,
        Paint()..color = tooltipBg == lineColor ? Colors.white : tooltipBg,
      );
      canvas.drawCircle(
        p,
        4,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      canvas.drawCircle(
        p,
        8.5,
        Paint()..color = lineColor.withValues(alpha: 0.15),
      );

      final dashPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.4)
        ..strokeWidth = 1;
      _drawDashedLine(
        canvas,
        Offset(p.dx, p.dy + 6),
        Offset(p.dx, topPadding + chartHeight),
        dashPaint,
      );

      final tp = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${points[idx].label}\n',
              style: TextStyle(
                fontSize: 9.5,
                color: tooltipText.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: '${_formatFcfa(points[idx].amount)} FCFA',
              style: TextStyle(
                fontSize: 12,
                color: tooltipText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final boxWidth = tp.width + 20;
      final boxHeight = tp.height + 12;
      double boxLeft = p.dx - boxWidth / 2;
      boxLeft = boxLeft.clamp(0, size.width - boxWidth);
      final boxRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(boxLeft, 0, boxWidth, boxHeight),
        const Radius.circular(10),
      );
      canvas.drawRRect(
        boxRect,
        Paint()..color = tooltipBg.withValues(alpha: 0.95),
      );
      tp.paint(canvas, Offset(boxLeft + 10, 6));
    }
  }

  int _defaultPeakIndex() {
    if (points.isEmpty) return -1;
    double maxVal = points.first.amount;
    int maxIdx = 0;
    for (int i = 1; i < points.length; i++) {
      if (points[i].amount > maxVal) {
        maxVal = points[i].amount;
        maxIdx = i;
      }
    }
    return maxIdx;
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 3.0;
    const dashSpace = 3.0;
    final totalLength = (end - start).distance;
    if (totalLength == 0) return;
    final direction = (end - start) / totalLength;
    double drawn = 0;
    while (drawn < totalLength) {
      final segStart = start + direction * drawn;
      final segEnd =
          start + direction * math.min(drawn + dashWidth, totalLength);
      canvas.drawLine(segStart, segEnd, paint);
      drawn += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.smooth != smooth ||
        oldDelegate.touchedIndex != touchedIndex ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.tooltipBg != tooltipBg;
  }
}
