import 'package:app_expenses/screens/expenses/add_expense_screen.dart';
import 'package:app_expenses/screens/objectif_depense_screen.dart';
import 'package:app_expenses/screens/support_screen.dart';
import 'package:app_expenses/screens/transaction_screen.dart';
import 'package:app_expenses/services/api_service.dart';
import 'package:app_expenses/services/auth_service.dart';
import 'package:flutter/material.dart';

import '../../utils/date_utils.dart';
import '../../widgets/user_avatar.dart';
import '../budget/budget_screen.dart';
import '../categories/category_list_screen.dart';
import '../expenses/expense_list_screen.dart';
import '../notifications/notification_screen.dart';
import '../profile/profile_screen.dart';
import '../stats_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();

  late Future<Map<String, dynamic>>
      _dashboardFuture;

  int _currentIndex = 0;

  static const Color _activeColor =
      Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    if (!mounted) return;

    setState(() {
      _dashboardFuture =
          _apiService.fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildHomeTab(context),
      const ExpenseListScreen(),
      const BudgetScreen(),
      const StatsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _activeColor,
        unselectedItemColor:
            Colors.grey.shade500,
        showUnselectedLabels: true,
        selectedLabelStyle:
            const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle:
            const TextStyle(
          fontSize: 11,
        ),
        elevation: 8,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon:
                Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt_long_outlined,
            ),
            activeIcon:
                Icon(Icons.receipt_long),
            label: 'Dépenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
            ),
            activeIcon: Icon(
              Icons.account_balance_wallet,
            ),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bar_chart_outlined,
            ),
            activeIcon:
                Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            activeIcon:
                Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6F8),

      appBar: AppBar(
        title: const Text(
          'SenaTrack',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E5A27),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,

        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const NotificationScreen(),
                ),
              );
            },
          ),

          FutureBuilder<
              Map<String, dynamic>>(
            future: _dashboardFuture,
            builder: (
              context,
              snapshot,
            ) {
              final userData =
                  snapshot.data?['user']
                      as Map<String, dynamic>? ??
                  {};

              final String userName =
                  userData['name']
                          ?.toString() ??
                      'Utilisateur';

              final String? photoUrl =
                  userData['photo_url']
                      ?.toString();

              final String userKey =
                  userData['id']
                          ?.toString() ??
                      'current_user';

              return Padding(
                padding:
                    const EdgeInsets.only(
                  right: 16,
                  left: 8,
                ),
                child: UserAvatar(
                  userKey: userKey,
                  name: userName,
                  networkPhotoUrl: photoUrl,
                  radius: 18,
                  backgroundColor:
                      const Color(0xFF3B6334),
                  textColor: Colors.white,
                  editable: false,
                  onTap: () {
                    setState(() {
                      _currentIndex = 4;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),

      drawer: FutureBuilder<
          Map<String, dynamic>>(
        future: _dashboardFuture,
        builder: (
          context,
          snapshot,
        ) {
          final userData =
              snapshot.data?['user']
                      as Map<String, dynamic>? ??
                  {};

          final int? userId =
              _parseUserId(
            userData['id'],
          );

          return _buildDrawer(
            context,
            userId: userId,
            name: userData['name']
                    ?.toString() ??
                'Utilisateur',
            email: userData['email']
                    ?.toString() ??
                'inconnu',
            photoUrl: userData[
                    'photo_url']
                ?.toString(),
          );
        },
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          _refreshData();
          await _dashboardFuture;
        },
        color: const Color(0xFF3B6334),

        child: FutureBuilder<
            Map<String, dynamic>>(
          future: _dashboardFuture,
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(
                  color: Color(0xFF3B6334),
                ),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height:
                        MediaQuery.of(context)
                                .size
                                .height *
                            0.25,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color:
                              Colors.redAccent,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          'Erreur de chargement',
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 32,
                          ),
                          child: Text(
                            '${snapshot.error}',
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              color:
                                  Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        ElevatedButton.icon(
                          onPressed:
                              _refreshData,
                          icon:
                              const Icon(
                            Icons.refresh,
                            color:
                                Colors.white,
                          ),
                          label:
                              const Text(
                            'Réessayer',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                            ),
                          ),
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                const Color(
                              0xFF3B6334,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            final data =
                snapshot.data ?? {};

            final double totalBudget =
                (data['total_budget']
                            as num? ??
                        0)
                    .toDouble();

            final double totalExpenses =
                (data['total_expenses']
                            as num? ??
                        0)
                    .toDouble();

            final double remaining =
                totalBudget -
                    totalExpenses;

            final List rawExpenses =
                List.from(
              data['recent_expenses'] ??
                  [],
            );

            rawExpenses.sort(
              (a, b) {
                final dateA =
                    DateTime.tryParse(
                          a['date']
                                  ?.toString() ??
                              '',
                        ) ??
                        DateTime(1970);

                final dateB =
                    DateTime.tryParse(
                          b['date']
                                  ?.toString() ??
                              '',
                        ) ??
                        DateTime(1970);

                return dateB.compareTo(
                  dateA,
                );
              },
            );

            return SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(
                    totalBudget,
                    totalExpenses,
                    remaining,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceEvenly,
                    children: [
                      _buildQuickActionButton(
                        Icons
                            .account_balance_wallet_outlined,
                        'Budgets',
                        () {
                          setState(() {
                            _currentIndex =
                                2;
                          });
                        },
                      ),
                      _buildQuickActionButton(
                        Icons
                            .receipt_long_outlined,
                        'Dépenses',
                        () {
                          setState(() {
                            _currentIndex =
                                1;
                          });
                        },
                      ),
                      _buildQuickActionButton(
                        Icons.category_outlined,
                        'Catégories',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const CategoryListScreen(),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        Icons
                            .bar_chart_rounded,
                        'Stats',
                        () {
                          setState(() {
                            _currentIndex =
                                3;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      const Text(
                        'Dépenses Récentes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF1F2937),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex =
                                1;
                          });
                        },
                        child:
                            const Text(
                          'Voir tout',
                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF3B6334,
                            ),
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  if (rawExpenses.isEmpty)
                    _buildEmptyExpensesState(
                      context,
                    )
                  else
                    ...rawExpenses.map(
                      (exp) =>
                          _buildExpenseTile(
                        exp,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddExpenseScreen(),
            ),
          ).then((_) {
            _refreshData();
          });
        },
        backgroundColor:
            const Color(0xFF3B6334),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  int? _parseUserId(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value.toString(),
    );
  }

  Widget _buildBalanceCard(
    double total,
    double spent,
    double remaining,
  ) {
    final double progress =
        total > 0
            ? (spent / total)
                .clamp(0.0, 1.0)
            : 0.0;

    Color statusColor =
        Colors.lightGreenAccent;

    if (progress > 0.85) {
      statusColor =
          Colors.orangeAccent;
    }

    if (remaining < 0) {
      statusColor =
          Colors.redAccent;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF2E5A27),
            Color(0xFF436C3C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF2E5A27)
                    .withValues(
              alpha: 0.3,
            ),
            blurRadius: 16,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              const Text(
                'Solde Restant',
                style: TextStyle(
                  color:
                      Colors.white70,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.15,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}% utilisé',
                  style: TextStyle(
                    color:
                        statusColor,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            '${remaining.toStringAsFixed(0)} FCFA',
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight:
                  FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(8),
            child:
                LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  Colors.white
                      .withValues(
                alpha: 0.2,
              ),
              valueColor:
                  AlwaysStoppedAnimation<
                      Color>(
                statusColor,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              _buildBalanceDetail(
                'Budget Total',
                '${total.toStringAsFixed(0)} FCFA',
              ),
              _buildBalanceDetail(
                'Dépenses Totales',
                '${spent.toStringAsFixed(0)} FCFA',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail(
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        const SizedBox(
          height: 3,
        ),
        Text(
          value,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(16),
      child: Padding(
        padding:
            const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.all(14),
              decoration:
                  const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color:
                    const Color(
                  0xFF3B6334,
                ),
                size: 24,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              label,
              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color:
                    Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTile(
    dynamic exp,
  ) {
    final String category =
        exp['category']
                ?.toString() ??
            'Général';

    final double amount =
        (exp['amount'] as num? ??
                0)
            .toDouble();

    final String title =
        exp['title']?.toString() ??
            'Dépense';

    final rawDate = exp['date'];

    String formattedDate =
        'Date non disponible';

    if (rawDate != null) {
      if (rawDate is String) {
        formattedDate =
            AppDateUtils.formatDate(
          rawDate,
        );
      } else if (rawDate
          is DateTime) {
        formattedDate =
            AppDateUtils.formatDate(
          rawDate.toIso8601String(),
        );
      }
    }

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withValues(
              alpha: 0.03,
            ),
            blurRadius: 8,
            offset:
                const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: CircleAvatar(
          backgroundColor:
              _getCategoryColor(
            category,
          ).withValues(
            alpha: 0.12,
          ),
          child: Icon(
            _getCategoryIcon(
              category,
            ),
            color:
                _getCategoryColor(
              category,
            ),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w600,
            fontSize: 15,
            color:
                Color(0xFF1F2937),
          ),
        ),
        subtitle: Text(
          '$category • $formattedDate',
          style:
              const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        trailing: Text(
          '-${amount.toStringAsFixed(0)} FCFA',
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
            color:
                Color(0xFFE53935),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyExpensesState(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: 16,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons
                .receipt_long_outlined,
            size: 48,
            color:
                Colors.grey.shade400,
          ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            'Aucune dépense récente',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 15,
              color:
                  Color(0xFF374151),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          const Text(
            'Vos dernières transactions apparaîtront ici.',
            style:
                TextStyle(
              fontSize: 12,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context, {
    required String name,
    required String email,
    String? photoUrl,
    int? userId,
    int selectedIndex = 0,
  }) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  UserAccountsDrawerHeader(
                    margin:
                        const EdgeInsets
                            .only(
                      bottom: 12,
                    ),
                    accountName:
                        Text(
                      name,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    accountEmail:
                        Text(email),

                    currentAccountPicture:
                        UserAvatar(
                      userKey:
                          userId?.toString() ??
                              'current_user',
                      name: name,
                      networkPhotoUrl:
                          photoUrl,
                      radius: 32,
                      backgroundColor:
                          Colors.white,
                      textColor:
                          const Color(
                        0xFF10B981,
                      ),
                      fontSize: 22,
                      editable: true,

                      onImagePicked:
                          (file) async {
                        await _apiService
                            .uploadAvatar(
                          file,
                        );

                        _refreshData();
                      },
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF10B981,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                  ),

                  const Padding(
                    padding:
                        EdgeInsets.only(
                      left: 12,
                      top: 12,
                      bottom: 8,
                    ),
                    child: Text(
                      'APERÇU',
                      style:
                          TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Colors.grey,
                        letterSpacing:
                            1.1,
                      ),
                    ),
                  ),

                  _buildDrawerItem(
                    icon:
                        Icons.grid_view_rounded,
                    title:
                        'Tableau de bord',
                    isSelected:
                        selectedIndex ==
                            0,
                    onTap: () {
                      Navigator.pop(
                        context,
                      );

                      setState(() {
                        _currentIndex =
                            0;
                      });
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons
                        .receipt_long_outlined,
                    title:
                        'Transactions',
                    isSelected:
                        selectedIndex ==
                            1,
                    onTap: () {
                      Navigator.pop(
                        context,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const TransactionsScreen(),
                        ),
                      );
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons
                        .payments_outlined,
                    title:
                        'Dépenses',
                    isSelected:
                        selectedIndex ==
                            1,
                    onTap: () {
                      Navigator.pop(
                        context,
                      );

                      setState(() {
                        _currentIndex =
                            1;
                      });
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons
                        .account_balance_wallet_outlined,
                    title:
                        'Budgets',
                    isSelected:
                        selectedIndex ==
                            2,
                    onTap: () {
                      Navigator.pop(
                        context,
                      );

                      setState(() {
                        _currentIndex =
                            2;
                      });
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons
                        .savings_outlined,
                    title:
                        "Objectifs d'épargne",
                    badgeCount: 2,
                    isSelected:
                        selectedIndex ==
                            3,
                    onTap: () {
                      Navigator.pop(
                        context,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ObjectifDepenseScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Padding(
                    padding:
                        EdgeInsets.only(
                      left: 12,
                      top: 8,
                      bottom: 8,
                    ),
                    child: Text(
                      'PRÉFÉRENCES',
                      style:
                          TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Colors.grey,
                        letterSpacing:
                            1.1,
                      ),
                    ),
                  ),

                  _buildDrawerItem(
                    icon: Icons
                        .settings_outlined,
                    title:
                        'Paramètres',
                    isSelected:
                        selectedIndex ==
                            4,
                    onTap: () {
                      Navigator.pop(
                        context,
                      );

                      setState(() {
                        _currentIndex =
                            4;
                      });
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons
                        .help_outline_rounded,
                    title:
                        'Aide et Support',
                    isSelected:
                        selectedIndex ==
                            5,
                    onTap: () {
                      Navigator.pop(
                        context,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SupportScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                onTap: () async {
                  Navigator.pop(
                    context,
                  );

                  final authService =
                      AuthService();

                  await authService
                      .logout();

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
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 12,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .red
                        .shade50
                        .withValues(
                      alpha: 0.5,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Icon(
                        Icons
                            .logout_rounded,
                        color:
                            Color(
                          0xFFC53030,
                        ),
                        size: 20,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Déconnexion',
                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFFC53030,
                          ),
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
    const activeColor =
        Color(0xFF10B981);

    const textColor =
        Color(0xFF2D3748);

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          selected: isSelected,
          selectedTileColor:
              activeColor,
          dense: true,
          leading: Icon(
            icon,
            color: isSelected
                ? Colors.white
                : textColor,
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : textColor,
              fontWeight:
                  isSelected
                      ? FontWeight.bold
                      : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          trailing:
              badgeCount != null
                  ? Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration:
                          BoxDecoration(
                        color: isSelected
                            ? Colors.white
                                .withValues(
                            alpha: 0.3,
                          )
                            : const Color(
                                0xFFE6F4EA,
                              ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child: Text(
                        '$badgeCount',
                        style:
                            TextStyle(
                          color: isSelected
                              ? Colors.white
                              : activeColor,
                          fontWeight:
                              FontWeight
                                  .bold,
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

  IconData _getCategoryIcon(
    String category,
  ) {
    switch (
        category.toLowerCase()) {
      case 'alimentation':
      case 'nourriture':
      case 'repas':
        return Icons.restaurant;

      case 'transport':
      case 'déplacement':
        return Icons
            .directions_car_filled_outlined;

      case 'logement':
      case 'loyer':
        return Icons.home_outlined;

      case 'loisirs':
      case 'divertissement':
        return Icons
            .sports_esports_outlined;

      case 'santé':
        return Icons
            .medical_services_outlined;

      default:
        return Icons
            .shopping_bag_outlined;
    }
  }

  Color _getCategoryColor(
    String category,
  ) {
    switch (
        category.toLowerCase()) {
      case 'alimentation':
      case 'nourriture':
      case 'repas':
        return Colors.orange;

      case 'transport':
      case 'déplacement':
        return Colors.blue;

      case 'logement':
      case 'loyer':
        return Colors.purple;

      case 'loisirs':
      case 'divertissement':
        return Colors.pink;

      case 'santé':
        return Colors.teal;

      default:
        return const Color(
          0xFF3B6334,
        );
    }
  }
}