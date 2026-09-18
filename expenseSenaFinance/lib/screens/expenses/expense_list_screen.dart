
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:senafinance/providers/currency_provider.dart';
import 'package:senafinance/providers/locale_provider.dart';
import 'package:senafinance/services/expense_service.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final ExpenseService _expenseService = ExpenseService();

  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  DateTime? _selectedDate;

  String _monthLabel(DateTime date) {
    final locale = appLocaleNotifier.value.languageCode; // 'fr' ou 'en'
    return DateFormat.MMMM(locale).format(date);
  }

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final expenses = await _expenseService.getExpenses();
      if (!mounted) return;

      if (expenses.isNotEmpty) {
        debugPrint('RAW DATE FROM API: ${expenses.first['date']}');
      }

      expenses.sort((a, b) {
        final da =
            DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(1970);
        final db =
            DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(1970);
        return db.compareTo(da);
      });

      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _goToAdd() async {
    final result = await showAddExpenseSheet(context);
    if (result == true) _loadExpenses();
  }

  Future<void> _goToEdit(Map<String, dynamic> expense) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: expense)),
    );
    if (result == true) _loadExpenses();
  }

  Future<bool> _confirmDelete(Map<String, dynamic> expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer la dépense'),
        content: Text(
          'Voulez-vous vraiment supprimer "${expense['title'] ?? 'cette dépense'}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    final id = expense['id']?.toString();
    if (id == null) return false;

    try {
      await _expenseService.deleteExpense(id);
      if (!mounted) return true;
      setState(() => _expenses.removeWhere((e) => e['id']?.toString() == id));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dépense supprimée.')));
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      return false;
    }
  }

  String _formatAmount(dynamic rawAmount) {
    final value = double.tryParse(rawAmount?.toString() ?? '') ?? 0;
    final digits = value.round().abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(' ');
    }
    return buffer.toString();
  }

  String _categoryName(Map<String, dynamic> expense) {
    final category = expense['category'];
    if (category is Map && category['name'] != null) {
      return category['name'].toString();
    }
    if (category is String && category.isNotEmpty) return category;
    return 'Divers';
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(date.year, date.month, date.day);
    final diff = today.difference(that).inDays;

    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Hier';
    final yearSuffix = date.year != now.year ? ' ${date.year}' : '';
    return '${date.day} ${_monthLabel(date)}$yearSuffix';
  }

  List<Map<String, dynamic>> get _filteredExpenses {
    return _expenses.where((e) {
      final title = (e['title'] ?? '').toString().toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty || title.contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == null || _categoryName(e) == _selectedCategory;

      bool matchesDate = true;
      if (_selectedDate != null) {
        final date = DateTime.tryParse(e['date']?.toString() ?? '');
        matchesDate =
            date != null &&
            date.year == _selectedDate!.year &&
            date.month == _selectedDate!.month &&
            date.day == _selectedDate!.day;
      }

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();
  }

  List<String> get _availableCategories {
    final set = <String>{for (final e in _expenses) _categoryName(e)};
    return set.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Liste des Dépenses')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_expense_list',
        backgroundColor: cs.primary,
        onPressed: _goToAdd,
        child: Icon(Icons.add, color: cs.onPrimary),
      ),
      body: SafeArea(child: _buildBody(cs)),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurface),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadExpenses,
                style: ElevatedButton.styleFrom(backgroundColor: cs.primary),
                child: Text('Réessayer', style: TextStyle(color: cs.onPrimary)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: cs.primary,
      onRefresh: _loadExpenses,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildFilterBar(cs)),
          if (_filteredExpenses.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(cs),
            )
          else
            ..._buildGroupedSlivers(cs),
          const SliverToBoxAdapter(child: SizedBox(height: 25)),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outline),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: cs.onSurfaceVariant, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Rechercher dépense, catégorie, ...',
                        hintStyle: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(fontSize: 14, color: cs.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildIconButton(
            cs: cs,
            icon: Icons.calendar_today_outlined,
            isActive: _selectedDate != null,
            onTap: _pickDate,
            onLongPress: () => setState(() => _selectedDate = null),
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            cs: cs,
            icon: Icons.filter_list_rounded,
            isActive: _selectedCategory != null,
            onTap: _showCategoryFilterSheet,
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
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: Theme.of(context).colorScheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _showCategoryFilterSheet() {
    final cs = Theme.of(context).colorScheme;
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
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _categoryChip(cs, null, 'Toutes'),
                  for (final cat in _availableCategories)
                    _categoryChip(cs, cat, cat),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(ColorScheme cs, String? value, String label) {
    final isSelected = _selectedCategory == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: cs.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? cs.primary : cs.onSurface,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      onSelected: (_) {
        setState(() => _selectedCategory = value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildIconButton({
    required ColorScheme cs,
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
          color: isActive ? cs.primary.withValues(alpha: 0.12) : cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isActive ? cs.primary : cs.outline),
        ),
        child: Icon(
          icon,
          color: isActive ? cs.primary : cs.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune dépense pour le moment',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Touchez le bouton + pour enregistrer votre première dépense.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedSlivers(ColorScheme cs) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    final List<String> order = [];

    for (final expense in _filteredExpenses) {
      final date = DateTime.tryParse(expense['date']?.toString() ?? '');
      final label = date != null ? _dayLabel(date) : 'Date inconnue';
      if (!grouped.containsKey(label)) {
        grouped[label] = [];
        order.add(label);
      }
      grouped[label]!.add(expense);
    }

    final slivers = <Widget>[];

    for (final label in order) {
      final items = grouped[label]!;

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: cs.onSurface,
              ),
            ),
          ),
        ),
      );

      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildExpenseTile(cs, items[index]),
            childCount: items.length,
          ),
        ),
      );
    }

    return slivers;
  }

  void _showExpenseDetails(Map<String, dynamic> expense) {
    final category = _categoryName(expense);
    final date = DateTime.tryParse(expense['date']?.toString() ?? '');
    final description = expense['description']?.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(expense['title']?.toString() ?? 'Sans titre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(
              'Montant',
              '${_formatAmount(expense['amount'])} ${appCurrencyNotifier.value}',
            ),
            _detailRow('Catégorie', category),
            if (date != null) _detailRow('Date', _formatFullDate(date)),
            if (description != null && description.isNotEmpty)
              _detailRow('Description', description),
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
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  label,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatFullDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${_monthLabel(date)} ${date.year}';

  Widget _buildExpenseTile(ColorScheme cs, Map<String, dynamic> expense) {
    final category = _categoryName(expense);
    final date = DateTime.tryParse(expense['date']?.toString() ?? '');
    final id = expense['id']?.toString();

    return Dismissible(
      key: ValueKey(id ?? expense.hashCode),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(expense),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    expense['title']?.toString() ?? 'Sans titre',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildActionsButton(cs, expense),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ),
                if (date != null)
                  Text(
                    _formatFullDate(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsButton(ColorScheme cs, Map<String, dynamic> expense) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      padding: EdgeInsets.zero,
      offset: const Offset(0, 38),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') {
          _goToEdit(expense);
        } else if (value == 'details') {
          _showExpenseDetails(expense);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'details',
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Text('Voir les détails'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              const Text('Modifier'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Actions',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}