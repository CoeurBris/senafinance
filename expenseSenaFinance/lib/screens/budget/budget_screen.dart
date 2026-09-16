import 'package:app_expenses/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:app_expenses/models/budget_model.dart';
import 'package:provider/provider.dart';
import 'package:app_expenses/providers/budget_provider.dart';
import 'add_budget_screen.dart';
import 'edit_budget_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  DateTime? _selectedDate;

  // ---------------------------------------------------------------------
  // Palette — dérivée du thème actif (clair ou sombre), plus aucune
  // couleur codée en dur pour le fond, le texte ou les bordures.
  // ---------------------------------------------------------------------
  Color get _ink => Theme.of(context).colorScheme.onSurface;
  Color get _muted => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _surface => Theme.of(context).colorScheme.surface;
  Color get _divider => Theme.of(context).colorScheme.outline;
  Color get _brand => Theme.of(context).colorScheme.primary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadBudgets();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _showDetails(BudgetModel b) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(b.nom),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Catégorie', b.category?.nom ?? '—'),
            _detailRow('Montant total', '${b.montant.toStringAsFixed(0)} FCFA'),
            _detailRow(
              'Dépensé',
              '${b.montantDepense.toStringAsFixed(0)} FCFA',
            ),
            _detailRow(
              'Restant',
              '${b.montantRestant.toStringAsFixed(0)} FCFA',
            ),
            _detailRow(
              'Utilisé',
              '${b.pourcentageUtilise.toStringAsFixed(0)} %',
            ),
            if (b.dateDebut != null) _detailRow('Début', _fmt(b.dateDebut!)),
            if (b.dateFin != null) _detailRow('Fin', _fmt(b.dateFin!)),
            if (b.description.isNotEmpty)
              _detailRow('Description', b.description),
            _detailRow('Statut', b.actif ? 'Actif' : 'Terminé'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _dateRangeLabel(BudgetModel b) {
    if (b.dateDebut != null && b.dateFin != null) {
      return '${_fmt(b.dateDebut!)} → ${_fmt(b.dateFin!)}';
    }
    if (b.dateDebut != null) {
      return 'Depuis ${_fmt(b.dateDebut!)}';
    }
    if (b.dateFin != null) {
      return "Jusqu'au ${_fmt(b.dateFin!)}";
    }
    return '';
  }

  List<BudgetModel> _filteredBudgets(List<BudgetModel> all) {
    return all.where((b) {
      final matchesSearch =
          _searchQuery.isEmpty || b.nom.toLowerCase().contains(_searchQuery);

      final matchesCategory =
          _selectedCategory == null || b.category?.nom == _selectedCategory;

      bool matchesDate = true;
      if (_selectedDate != null && b.dateDebut != null) {
        matchesDate =
            b.dateDebut!.year == _selectedDate!.year &&
            b.dateDebut!.month == _selectedDate!.month &&
            b.dateDebut!.day == _selectedDate!.day;
      }

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();
  }

  List<String> _availableCategories(List<BudgetModel> all) {
    final set = <String>{
      for (final b in all)
        if (b.category?.nom != null) b.category!.nom,
    };
    return set.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BudgetProvider>();
    final filtered = _filteredBudgets(provider.budgets);

    return Scaffold(
      appBar: AppBar(title: const Text('Liste des Budgets')),
      // Pas de backgroundColor ici : le Scaffold hérite de
      // scaffoldBackgroundColor défini dans ThemeData (clair ou sombre).
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_budget_list',
        backgroundColor: _brand,
        onPressed: () async {
          final result = await showAddBudgetSheet(context);
          if (result == true && mounted) {
            // ignore: use_build_context_synchronously
            context.read<BudgetProvider>().loadBudgets();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterBar(provider.budgets),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<BudgetProvider>().loadBudgets(),
              child: Builder(
                builder: (_) {
                  if (provider.isLoading && provider.budgets.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.error != null && provider.budgets.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }
                  if (filtered.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('Aucun résultat pour ces filtres.')),
                      ],
                    );
                  }
                  return ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final b = filtered[index];
                      final hasDates = b.dateDebut != null || b.dateFin != null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.border, width: 0.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.nom,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: _ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      b.category?.nom ?? 'Sans catégorie',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _muted,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_outlined,
                                          size: 14,
                                          color: _brand,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${b.montant.toStringAsFixed(0)} FCFA',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: _brand,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (hasDates) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 13,
                                            color: _muted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _dateRangeLabel(b),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                offset: const Offset(0, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onSelected: (value) async {
                                  if (value == 'view') {
                                    _showDetails(b);
                                  } else if (value == 'edit') {
                                    final updated = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditBudgetScreen(budget: b),
                                      ),
                                    );
                                    // ignore: use_build_context_synchronously
                                    if (updated == true && mounted) {
                                      // ignore: use_build_context_synchronously
                                      context
                                          .read<BudgetProvider>()
                                          .loadBudgets();
                                    }
                                  } else if (value == 'add') {
                                    final created = await showAddBudgetSheet(
                                      context,
                                    );
                                    // ignore: use_build_context_synchronously
                                    if (created == true && mounted) {
                                      // ignore: use_build_context_synchronously
                                      context
                                          .read<BudgetProvider>()
                                          .loadBudgets();
                                    }
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                          color: AppColors.textSecondary,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Modifier'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'view',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.visibility_outlined,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Voir les détails'),
                                      ],
                                    ),
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _brand.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _brand.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Actions',
                                        style: TextStyle(
                                          color: _brand,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(List<BudgetModel> all) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _divider),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: _muted, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Rechercher budget, catégorie, ...',
                        hintStyle: TextStyle(color: _muted, fontSize: 12),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(fontSize: 14, color: _ink),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildIconButton(
            icon: Icons.calendar_today_outlined,
            isActive: _selectedDate != null,
            onTap: _pickDate,
            onLongPress: () => setState(() => _selectedDate = null),
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            icon: Icons.filter_list_rounded,
            isActive: _selectedCategory != null,
            onTap: () => _showCategoryFilterSheet(all),
            onLongPress: () => setState(() => _selectedCategory = null),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: _brand),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _showCategoryFilterSheet(List<BudgetModel> all) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrer par catégorie',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _categoryChip(null, 'Toutes'),
                  for (final cat in _availableCategories(all))
                    _categoryChip(cat, cat),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String? value, String label) {
    final isSelected = _selectedCategory == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: _brand.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? _brand : _ink,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      onSelected: (_) {
        setState(() => _selectedCategory = value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? _brand.withValues(alpha: 0.12) : _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isActive ? _brand : _divider),
        ),
        child: Icon(icon, color: isActive ? _brand : _muted, size: 20),
      ),
    );
  }
}