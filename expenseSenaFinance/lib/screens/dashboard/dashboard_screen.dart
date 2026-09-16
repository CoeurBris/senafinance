import 'package:app_expenses/core/widgets/user_avatar.dart';
import 'package:app_expenses/models/budget_model.dart';
import 'package:app_expenses/models/category_model.dart';
import 'package:app_expenses/models/expense_model.dart';
import 'package:app_expenses/models/transaction_model.dart';
import 'package:app_expenses/providers/budget_provider.dart';
import 'package:app_expenses/providers/expense_provider.dart';
import 'package:app_expenses/providers/notification_provider.dart';
import 'package:app_expenses/providers/transaction_provider.dart';
import 'package:app_expenses/repositories/category_repository.dart';
import 'package:app_expenses/screens/expenses/add_expense_screen.dart';
import 'package:app_expenses/screens/objectifs/objectif_depense_screen.dart';
import 'package:app_expenses/screens/profile/profile_screen.dart';
import 'package:app_expenses/screens/settings_screen.dart';
import 'package:app_expenses/screens/support_screen.dart';
import 'package:app_expenses/screens/transactions/transaction_screen.dart';
import 'package:app_expenses/services/api_service.dart';
import 'package:app_expenses/services/auth_service.dart';
import 'package:app_expenses/services/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../budget/budget_screen.dart';
// Adapte ce chemin si ton AddBudgetScreen se trouve ailleurs
import '../budget/add_budget_screen.dart';
import '../expenses/expense_list_screen.dart';
import '../notifications/notification_screen.dart';
import '../stats_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  final CategoryRepository _categoryRepository = CategoryRepository();

  late Future<Map<String, dynamic>> _dashboardFuture;
  late Future<List<CategoryModel>> _categoriesFuture;

  int _currentIndex = 0;
  String _selectedFilter = 'Tous'; // <-- AJOUT

  static const Color _activeColor = Color(0xFF3B6334);
  static const Color _brandGreen = Color(0xFF3B6334);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
      // context.read<ExpenseProvider>().loadExpenses();
      // context.read<BudgetProvider>().loadBudgets();
      // context.read<TransactionProvider>().loadTransactions();
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  void _refreshData() {
    if (!mounted) return;
    setState(() {
      // NB : _dashboardFuture ne sert plus qu'aux infos utilisateur
      // (nom / email / photo pour l'AppBar et le Drawer) et à l'état
      // d'erreur global. Les listes Dépenses/Budgets/Transactions ne
      // dépendent plus de cet appel — voir les Providers ci-dessous.
      _dashboardFuture = _apiService.fetchDashboardData();
      _categoriesFuture = _categoryRepository.getCategories();
    });
    // Recharge les dépenses et budgets via les providers
    context.read<ExpenseProvider>().loadExpenses();
    context.read<BudgetProvider>().loadBudgets();
    context.read<TransactionProvider>().loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildHomeTab(context),
      const ExpenseListScreen(),
      const BudgetScreen(),
      const StatsScreen(),
      SettingsScreen(onBack: () => setState(() => _currentIndex = 0)),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: _activeColor,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 8,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Dépenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.savings_outlined, color: Colors.green.shade700),
            const SizedBox(width: 8),
            const Text(
              'SenaTrack',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          const Icon(Icons.search),
          const SizedBox(width: 12),
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  if (provider.unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          provider.unreadCount > 9
                              ? '9+'
                              : '${provider.unreadCount}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),
          // --- AVATAR UTILISATEUR + PASTILLE "EN LIGNE" ---
          FutureBuilder<Map<String, dynamic>>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              final userData =
                  snapshot.data?['user'] as Map<String, dynamic>? ?? {};
              final int? userId = _parseUserId(userData['id']);
              final String name = userData['name']?.toString() ?? 'Utilisateur';
              final String? photoUrl = userData['photo_url']?.toString();

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      UserAvatar(
                        userKey: userId?.toString() ?? 'current_user',
                        name: name,
                        networkPhotoUrl: photoUrl,
                        radius: 18,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        textColor: const Color(0xFF3B6334),
                        fontSize: 14,
                      ),
                      // Pastille verte indiquant que l'utilisateur est connecté
                      Positioned(
                        right: -1,
                        bottom: -1,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          final userData =
              snapshot.data?['user'] as Map<String, dynamic>? ?? {};
          final int? userId = _parseUserId(userData['id']);

          return _buildDrawer(
            context,
            userId: userId,
            name: userData['name']?.toString() ?? 'Utilisateur',
            email: userData['email']?.toString() ?? 'inconnu',
            photoUrl: userData['photo_url']?.toString(),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshData();
          await _dashboardFuture;
        },
        backgroundColor: const Color(0xFF1E2A6B),
        color: const Color.fromARGB(255, 254, 255, 254),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorState(context, snapshot.error);
            }

            final data = snapshot.data ?? {};

            // FIX (Niveau 1) : on ne calcule plus `rawExpenses` depuis
            // `data['recent_expenses']` ici — les sections filtrées lisent
            // désormais directement les Providers (voir plus bas), qui sont
            // la seule source déjà à jour (c'est elle qui alimente aussi les
            // cartes de résumé en haut de l'écran).

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(data),

                  const SizedBox(height: 12),

                  // --- BARRE DE FILTRES ---
                  _buildFilterChips(),

                  const SizedBox(height: 12),

                  // --- CONTENU CONDITIONNEL SELON LE FILTRE ---
                  if (_selectedFilter == 'Tous') ...[
                    _buildSectionHeader('Catégories'),
                    const SizedBox(height: 12),
                    _buildCategoriesGrid(context),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Activités Récentes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => _selectedFilter = 'Activités'),
                          child: const Text(
                            'Voir tout',
                            style: TextStyle(
                              color: Color(0xFF3B6334),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildActivitesRecentes(),
                  ] else if (_selectedFilter == 'Dépenses')
                    // FIX (Niveau 1+2) : lit ExpenseProvider, plus rawExpenses
                    _buildAllExpensesSection()
                  else if (_selectedFilter == 'Budgets')
                    // FIX (Niveau 1+3) : lit BudgetProvider, plus data['budgets']
                    _buildAllBudgetsSection()
                  else if (_selectedFilter == 'Transactions')
                    // FIX (Niveau 4) : implémentation réelle via TransactionProvider
                    _buildAllTransactionsSection()
                  else if (_selectedFilter == 'Activités')
                    _buildToutesLesActivites(),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptionsSheet(context),
        backgroundColor: _brandGreen,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface, size: 28),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // SECTION : Toutes les dépenses
  // FIX (Niveau 2) : source = ExpenseProvider (plus /dashboard).
  // Garde le menu Modifier/Supprimer via _buildExpenseTile(ExpenseModel).
  // ---------------------------------------------------------------------
  Widget _buildAllExpensesSection() {
    final expenses = context.watch<ExpenseProvider>().expenses.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Toutes les Dépenses'),
        const SizedBox(height: 12),
        if (expenses.isEmpty)
          _buildEmptyExpensesState(context)
        else
          ...expenses.map((exp) => _buildExpenseTile(exp)),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // SECTION : Tous les budgets
  // FIX (Niveau 3) : source = BudgetProvider (plus /dashboard).
  // ---------------------------------------------------------------------
  Widget _buildAllBudgetsSection() {
    final budgets = context.watch<BudgetProvider>().budgets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tous les Budgets'),
        const SizedBox(height: 12),
        if (budgets.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Aucun budget pour le moment',
                  style: TextStyle(color: Colors.black45, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ...budgets.map((b) => _buildBudgetTile(b)),
      ],
    );
  }

  // FIX (Niveau 3) : accepte un BudgetModel et lit les bons getters
  // (montant / montantDepense / nom) au lieu des clés Map 'amount'/'spent'
  // qui ne correspondent pas au modèle réel (voir budget_model.dart).
  Widget _buildBudgetTile(BudgetModel budget) {
    final String name = budget.nom;
    final double amount = budget.montant;
    final double spent = budget.montantDepense;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _brandGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: _brandGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${spent.toStringAsFixed(0)} / ${amount.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // SECTION : Toutes les transactions
  // FIX (Niveau 4) : implémentation réelle via TransactionProvider,
  // au lieu du SizedBox(height: 400) vide.
  // ---------------------------------------------------------------------
  Widget _buildAllTransactionsSection() {
    final transactions = context.watch<TransactionProvider>().transactions
        .map(_depuisTransaction)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Toutes les Transactions'),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Aucune transaction pour le moment',
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),
          )
        else
          ...transactions.map(_buildActivityTile),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // ÉTATS (erreur / vide)
  // ---------------------------------------------------------------------

  Widget _buildErrorState(BuildContext context, Object? error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                'Erreur de chargement',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _refreshData,
                icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.surface),
                label: Text(
                  'Réessayer',
                  style: TextStyle(color: Theme.of(context).colorScheme.surface),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: _brandGreen),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int? _parseUserId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // CARDS DYNAMIQUES DÉPENSES / BUDGETS
  // ---------------------------------------------------------------------

  Widget _buildSummaryCards(Map<String, dynamic> data) {
    final double totalExpenses = context.watch<ExpenseProvider>().totalExpenses;
    final double totalBudget = context.watch<BudgetProvider>().totalBudgets;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildLightSummaryCard(
              icon: Icons.receipt_long_rounded,
              amount: totalExpenses,
              label: 'Dépenses',
              onTap: () => setState(() => _selectedFilter = 'Dépenses'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilledSummaryCard(
              icon: Icons.savings_rounded,
              amount: totalBudget,
              label: 'Budgets',
              onTap: () => setState(() => _selectedFilter = 'Budgets'),
            ),
          ),
        ],
      ),
    );
  }

  // Card claire (fond blanc/gris très clair, icône et texte foncés)
  Widget _buildLightSummaryCard({
    required IconData icon,
    required double amount,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: const Color(0xFF6B7280), size: 26),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${amount.toStringAsFixed(0)} FCFA',
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card pleine couleur verte
  Widget _buildFilledSummaryCard({
    required IconData icon,
    required double amount,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF3B6334),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B6334).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85), size: 26),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${amount.toStringAsFixed(0)} FCFA',
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // CATÉGORIES — grille dynamique alimentée par /categories/all
  // ---------------------------------------------------------------------

  Widget _buildCategoriesGrid(BuildContext context) {
    return FutureBuilder<List<CategoryModel>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 96,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Impossible de charger les catégories',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),
          );
        }

        final categories = snapshot.data ?? [];

        if (categories.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aucune catégorie pour le moment',
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          height: 96,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) =>
                  _buildCategoryTile(context, categories[index]),
            ),
          ),
        );
      },
    );
  }

  _ActiviteItem _depuisDepense(ExpenseModel e) => _ActiviteItem(
    type: _ActiviteType.depense,
    titre: e.titre.isNotEmpty ? e.titre : e.categorie,
    sousTitre: e.categorie,
    montant: e.montant,
    date: e.date,
    estEntree: false,
    icone: _getCategoryIcon(e.categorie),
    couleur: _getCategoryColor(e.categorie),
  );

  _ActiviteItem _depuisBudget(BudgetModel b) => _ActiviteItem(
    type: _ActiviteType.budget,
    titre: b.nom,
    sousTitre: 'Budget',
    montant: b.montant,
    date: b.dateDebut ?? b.createdAt ?? DateTime.now(),
    estEntree: true,
    icone: Icons.account_balance_wallet_rounded,
    couleur: _brandGreen,
  );

  _ActiviteItem _depuisTransaction(TransactionModel t) => _ActiviteItem(
    type: _ActiviteType.transaction,
    titre: t.title,
    sousTitre: t.category,
    montant: t.amount,
    date: t.date,
    estEntree: t.isIncome,
    icone: iconePourTransaction(t),
    couleur: t.isIncome ? AppColors.brand : AppColors.red,
  );

  Widget _buildCategoryTile(BuildContext context, CategoryModel category) {
    final Color color = _resolveCategoryColor(category);
    final IconData icon = _getCategoryIcon(category.nom);

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showCategoryExpenses(category),
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                category.nom,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile(_ActiviteItem item) {
    late String badgeLabel;
    switch (item.type) {
      case _ActiviteType.depense:
        badgeLabel = 'Dépense';
        break;
      case _ActiviteType.budget:
        badgeLabel = 'Budget';
        break;
      case _ActiviteType.transaction:
        badgeLabel = item.estEntree ? 'Entrée' : 'Dépense';
        break;
    }

    final montantTxt = item.type == _ActiviteType.budget
        ? formatFcfa(item.montant)
        : (item.estEntree ? '+ ' : '- ') + formatFcfa(item.montant);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.couleur.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icone, color: item.couleur, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.sousTitre} • ${formatDateIso(item.date)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                montantTxt,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: item.couleur,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.couleur.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: item.couleur,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitesRecentes() {
    final expenses = context.watch<ExpenseProvider>().expenses;
    final budgets = context.watch<BudgetProvider>().budgets;
    final transactions = context.watch<TransactionProvider>().transactions;

    final items = <_ActiviteItem>[
      ...expenses.map(_depuisDepense),
      ...budgets.map(_depuisBudget),
      ...transactions.map(_depuisTransaction),
    ]..sort((a, b) => b.date.compareTo(a.date));

    if (items.isEmpty) {
      return _buildEmptyExpensesState(context);
    }

    final recentes = items.take(7).toList();
    return Column(children: recentes.map(_buildActivityTile).toList());
  }

  Widget _buildToutesLesActivites() {
    final expenses = context.watch<ExpenseProvider>().expenses;
    final budgets = context.watch<BudgetProvider>().budgets;
    final transactions = context.watch<TransactionProvider>().transactions;

    final depenseItems = expenses.map(_depuisDepense).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final budgetItems = budgets.map(_depuisBudget).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final transactionItems = transactions.map(_depuisTransaction).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    Widget section(String titre, List<_ActiviteItem> liste, String vide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(titre),
          const SizedBox(height: 10),
          if (liste.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                vide,
                style: const TextStyle(color: Colors.black45, fontSize: 12),
              ),
            )
          else
            ...liste.map(_buildActivityTile),
          const SizedBox(height: 20),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        section(
          'Dépenses (${expenses.length})',
          depenseItems,
          'Aucune dépense pour le moment',
        ),
        section(
          'Budgets (${budgets.length})',
          budgetItems,
          'Aucun budget pour le moment',
        ),
        section(
          'Transactions (${transactions.length})',
          transactionItems,
          'Aucune transaction pour le moment',
        ),
      ],
    );
  }

  Color _resolveCategoryColor(CategoryModel category) {
    if (category.couleur != null && category.couleur!.isNotEmpty) {
      try {
        final hex = category.couleur!.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {
        // couleur invalide en base -> on retombe sur le mapping par nom
      }
    }
    return _getCategoryColor(category.nom);
  }

  Future<void> _showCategoryExpenses(CategoryModel category) async {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: ExpenseService().getExpenses(),
        builder: (context, snapshot) {
          Widget content;

          if (snapshot.connectionState == ConnectionState.waiting) {
            content = const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            content = Text(
              'Impossible de charger les dépenses.',
              style: TextStyle(color: Colors.grey.shade600),
            );
          } else {
            final expenses = (snapshot.data ?? []).where((e) {
              final expCategory = e['category'];
              final name = expCategory is Map
                  ? expCategory['name']?.toString()
                  : expCategory?.toString();
              return name?.toLowerCase() == category.nom.toLowerCase();
            }).toList();

            if (expenses.isEmpty) {
              content = Text(
                'Aucune dépense enregistrée pour "${category.nom}".',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              );
            } else {
              final total = expenses.fold<double>(
                0,
                (sum, e) =>
                    sum + (double.tryParse(e['amount']?.toString() ?? '') ?? 0),
              );

              content = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total : ${total.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B6334),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: expenses.length,
                      separatorBuilder: (_, _) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final e = expenses[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                e['title']?.toString() ?? 'Sans titre',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${e['amount']?.toString() ?? '0'} FCFA',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(category.nom),
            content: content,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // DÉPENSES RÉCENTES — cards arrondies + menu Modifier/Supprimer
  // FIX (Niveau 2) : accepte un ExpenseModel au lieu d'une Map dynamique,
  // pour rester cohérent avec ExpenseProvider.expenses (source de vérité).
  // ---------------------------------------------------------------------

  Widget _buildExpenseTile(ExpenseModel exp) {
    final String category = exp.categorie;
    final String title = exp.titre.isNotEmpty ? exp.titre : category;
    final String formattedDate = formatDateIso(exp.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: _getCategoryColor(category),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$category • $formattedDate',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            height: 32,
            width: 32,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey.shade500,
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) => _handleExpenseAction(value, exp),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Color(0xFF3B6334),
                      ),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 8),
                      Text('Supprimer'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FIX (Niveau 2) : accepte un ExpenseModel, et surtout appelle réellement
  // ExpenseProvider.deleteExpense(id) — avant, "Supprimer" ne faisait que
  // rafraîchir le dashboard sans jamais appeler l'API de suppression.
  //
  // ⚠️ Vérifie que ExpenseModel expose bien un champ `id` (int?) — adapte
  // le nom si besoin (ex: exp.expenseId).
  void _handleExpenseAction(String action, ExpenseModel exp) async {
    if (action == 'edit') {
      // NB : showAddExpenseSheet ne gère pour l'instant que l'AJOUT.
      // Pour éditer une dépense existante, il faudra soit une variante
      // showEditExpenseSheet(context, expense: exp), soit passer un
      // paramètre optionnel à showAddExpenseSheet pour pré-remplir les champs.
      final result = await showAddExpenseSheet(context);
      if (result == true) _refreshData();
      return;
    }

    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Supprimer la dépense'),
          content: Text(
            'Voulez-vous vraiment supprimer "${exp.titre.isNotEmpty ? exp.titre : 'cette dépense'}" ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        if (exp.id == null) return;

        final success =
            // ignore: use_build_context_synchronously
            await context.read<ExpenseProvider>().deleteExpense(exp.id!);

        if (!mounted) return;

        if (success) {
          // Le Provider a déjà retiré l'élément et notifié ses listeners ;
          // on rafraîchit quand même le reste (budgets/transactions liés).
          _refreshData();
        } else {
          final error = context.read<ExpenseProvider>().error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Échec de la suppression.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  Widget _buildEmptyExpensesState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            'Aucune dépense récente',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Vos dernières transactions apparaîtront ici.',
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // FAB — popup Ajouter une dépense / un budget
  // ---------------------------------------------------------------------

  void _showAddOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Que voulez-vous ajouter ?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 20),
              _buildAddOptionTile(
                icon: Icons.receipt_long_rounded,
                label: 'Ajouter une dépense',
                color: const Color(0xFFE53935),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await showAddExpenseSheet(context);
                  if (result == true) _refreshData();
                },
              ),
              const SizedBox(height: 12),
              _buildAddOptionTile(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Ajouter un budget',
                color: _brandGreen,
                onTap: () async {
                  Navigator.pop(context);
                  final result = await showAddBudgetSheet(context);
                  if (result == true) _refreshData();
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddOptionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // DRAWER (inchangé)
  // ---------------------------------------------------------------------

  Widget _buildDrawer(
    BuildContext context, {
    required String name,
    required String email,
    String? photoUrl,
    int? userId,
    int selectedIndex = 0,
  }) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: _brandGreen, // ici
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 48,
              bottom: 40,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo_romas0.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  'Romas Technologie',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12, top: 4, bottom: 8),
                    child: Text(
                      'APERÇU',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.grid_view_rounded,
                    title: 'Tableau de bord',
                    isSelected: selectedIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 0);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Transactions',
                    isSelected: selectedIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.payments_outlined,
                    title: 'Dépenses',
                    isSelected: selectedIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 1);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Budgets',
                    isSelected: selectedIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 2);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.savings_outlined,
                    title: "Objectifs d'épargne",
                    badgeCount: 2,
                    isSelected: selectedIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ObjectifScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.only(left: 12, top: 8, bottom: 8),
                    child: Text(
                      'PRÉFÉRENCES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Paramètres',
                    isSelected: selectedIndex == 4,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 4);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Aide et Support',
                    isSelected: selectedIndex == 5,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SupportScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  Navigator.pop(context);
                  final authService = AuthService();
                  await authService.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFC53030),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Déconnexion',
                        style: TextStyle(
                          color: Color(0xFFC53030),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    int? badgeCount,
  }) {
    const activeColor = _brandGreen; // ici on change la couleur de Tableau de bord 
    const textColor = Color(0xFF2D3748);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          selected: isSelected,
          selectedTileColor: activeColor,
          dense: true,
          leading: Icon(
            icon,
            color: isSelected ? Theme.of(context).colorScheme.surface : textColor,
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.surface : textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          trailing: badgeCount != null
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.3)
                        : const Color(0xFFE6F4EA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.surface : activeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // HELPERS CATÉGORIE (fallback si icon/color absents en base)
  // ---------------------------------------------------------------------

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'alimentation':
      case 'nourriture':
      case 'repas':
        return Icons.restaurant;
      case 'abonnements':
        return Icons.subscriptions_outlined;
      case 'transport':
      case 'déplacement':
        return Icons.directions_car_filled_outlined;
      case 'logement':
      case 'loyer':
        return Icons.home_outlined;
      case 'loisirs':
      case 'divertissement':
        return Icons.sports_esports_outlined;
      case 'santé':
        return Icons.medical_services_outlined;
      case 'cadeaux':
        return Icons.card_giftcard_outlined;
      case 'plus':
        return Icons.more_horiz;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'alimentation':
      case 'nourriture':
      case 'repas':
        return Colors.orange;
      case 'abonnements':
        return Colors.brown;
      case 'transport':
      case 'déplacement':
        return Colors.blue;
      case 'logement':
      case 'loyer':
        return Colors.deepPurple;
      case 'loisirs':
      case 'divertissement':
        return Colors.pink;
      case 'santé':
        return Colors.teal;
      case 'cadeaux':
        return Colors.deepOrange;
      case 'plus':
        return Colors.grey;
      default:
        return _brandGreen;
    }
  }

  Widget _buildFilterChips() {
    final filters = ['Tous', 'Dépenses', 'Budgets', 'Transactions'];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final bool isSelected = _selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) {
              setState(() => _selectedFilter = filter);
            },
            showCheckmark: false,
            labelStyle: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.surface : const Color(0xFF374151),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            selectedColor: _brandGreen,
            backgroundColor: const Color(0xFFF0F1F3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide.none,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
          );
        },
      ),
    );
  }
}

enum _ActiviteType { depense, budget, transaction }

class _ActiviteItem {
  final _ActiviteType type;
  final String titre;
  final String sousTitre;
  final double montant;
  final DateTime date;
  final bool estEntree;
  final IconData icone;
  final Color couleur;

  _ActiviteItem({
    required this.type,
    required this.titre,
    required this.sousTitre,
    required this.montant,
    required this.date,
    required this.estEntree,
    required this.icone,
    required this.couleur,
  });
}

class ExpenseSearchDelegate extends SearchDelegate<String> {
  final ExpenseService _expenseService = ExpenseService();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchList(context);
  }

  Widget _buildSearchList(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text(
          'Tapez pour rechercher une dépense...',
          style: TextStyle(color: Colors.black45),
        ),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _expenseService.getExpenses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erreur lors de la recherche.'));
        }

        final results = (snapshot.data ?? []).where((exp) {
          final title = exp['title']?.toString().toLowerCase() ?? '';
          final categoryRaw = exp['category'];
          final category =
              (categoryRaw is Map
                  ? categoryRaw['name']?.toString()
                  : categoryRaw?.toString()) ??
              '';
          final q = query.toLowerCase();
          return title.contains(q) || category.toLowerCase().contains(q);
        }).toList();

        if (results.isEmpty) {
          return const Center(
            child: Text(
              'Aucun résultat trouvé.',
              style: TextStyle(color: Colors.black45),
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final exp = results[index];
            final categoryRaw = exp['category'];
            final category =
                (categoryRaw is Map
                    ? categoryRaw['name']?.toString()
                    : categoryRaw?.toString()) ??
                'Général';

            return ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(exp['title']?.toString() ?? 'Sans titre'),
              subtitle: Text(category),
              trailing: Text('${exp['amount']?.toString() ?? '0'} FCFA'),
              onTap: () {
                close(context, exp['title']?.toString() ?? '');
              },
            );
          },
        );
      },
    );
  }
}