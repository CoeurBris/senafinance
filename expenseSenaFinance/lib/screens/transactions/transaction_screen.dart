
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senafinance/models/transaction_model.dart';
import 'package:senafinance/providers/transaction_provider.dart';
import 'package:senafinance/screens/transactions/add_transaction_screen.dart';

/// ---------------------------------------------------------------------
/// Couleurs & constantes
/// ---------------------------------------------------------------------
class AppColors {
  static const Color bg = Color(0xFFF5F6F7);
  static const Color card = Colors.white;
  static const Color dark = Color(0xFF1C1C1E);

  // --- Vert unique de la charte ---
  static const Color brand = Color(0xFF3B6334);
  static const Color brandDark = Color(0xFF3B6334);
  static const Color brandSoft = Color(0xFFDCE6D6); // teinte claire dérivée

  static const Color red = Color(0xFFE05656);
  static const Color redSoft = Color(0xFFFCE7E7);
  static const Color grey = Color(0xFF8A8F98);
  static const Color chipBg = Color(0xFFEFEFF1);
}

const Map<String, IconData> kIconsDepense = {
  'Alimentation': Icons.restaurant,
  'Transport': Icons.directions_car,
  'Loisirs': Icons.sports_esports,
  'Achats': Icons.shopping_bag,
  'Santé': Icons.local_hospital,
  'Logement': Icons.home,
  'Autre': Icons.category,
};

const Map<String, IconData> kIconsRevenu = {
  'Salaire': Icons.work,
  'Vente': Icons.storefront,
  'Freelance': Icons.laptop_mac,
  'Cadeau': Icons.card_giftcard,
  'Autre': Icons.category,
};

const List<String> kMoisFr = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

/// ---------------------------------------------------------------------
/// Utilitaires de formatage (aucune dépendance externe)
/// ---------------------------------------------------------------------
String pad2(int n) => n.toString().padLeft(2, '0');

String formatDateIso(DateTime d) => '${d.year}-${pad2(d.month)}-${pad2(d.day)}';

String formatDateFr(DateTime d) => '${d.day} ${kMoisFr[d.month - 1]} ${d.year}';

String formatFcfa(num valeur, {bool avecSigne = false}) {
  final estNegatif = valeur < 0;
  final entier = valeur.abs().round();
  final chiffres = entier.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < chiffres.length; i++) {
    final resteADroite = chiffres.length - i;
    if (i > 0 && resteADroite % 3 == 0) buffer.write(' ');
    buffer.write(chiffres[i]);
  }
  final signe = estNegatif ? '-' : (avecSigne ? '+' : '');
  return '$signe${buffer.toString()} FCFA';
}

String etiquetteGroupe(DateTime d) {
  final maintenant = DateTime.now();
  final aujourdHui = DateTime(
    maintenant.year,
    maintenant.month,
    maintenant.day,
  );
  final jour = DateTime(d.year, d.month, d.day);
  final diff = aujourdHui.difference(jour).inDays;
  if (diff == 0) return "AUJOURD'HUI";
  if (diff == 1) return 'HIER';
  return formatDateFr(d).toUpperCase();
}

IconData iconePourTransaction(TransactionModel t) {
  final table = t.isExpense ? kIconsDepense : kIconsRevenu;
  return table[t.category] ?? Icons.category;
}

/// ---------------------------------------------------------------------
/// Page Transactions
/// ---------------------------------------------------------------------
class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _filtre = 'Tout'; // Tout | Revenus | Dépenses
  String _recherche = '';
  bool _voirTout = false;
  DateTime? _dateFiltre;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  List<TransactionModel> _filtrees(List<TransactionModel> source) {
    Iterable<TransactionModel> liste = source;
    if (_filtre == 'Revenus') {
      liste = liste.where((t) => t.isIncome);
    } else if (_filtre == 'Dépenses') {
      liste = liste.where((t) => t.isExpense);
    }
    if (_dateFiltre != null) {
      liste = liste.where(
        (t) =>
            t.date.year == _dateFiltre!.year &&
            t.date.month == _dateFiltre!.month &&
            t.date.day == _dateFiltre!.day,
      );
    }
    if (_recherche.trim().isNotEmpty) {
      final q = _recherche.trim().toLowerCase();
      liste = liste.where(
        (t) =>
            t.title.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q),
      );
    }
    final resultat = liste.toList()..sort((a, b) => b.date.compareTo(a.date));
    return resultat;
  }

  Map<String, List<TransactionModel>> _groupes(
    List<TransactionModel> filtrees,
  ) {
    final source = _voirTout ? filtrees : filtrees.take(7).toList();
    final Map<String, List<TransactionModel>> map = {};
    for (final t in source) {
      final cle = etiquetteGroupe(t.date);
      map.putIfAbsent(cle, () => []).add(t);
    }
    return map;
  }

  Future<void> _goToAdd() async {
    final succes = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (succes == true && mounted) {
      context.read<TransactionProvider>().loadTransactions();
    }
  }

  /// Ouvre l'écran d'ajout pré-rempli avec les infos de [t] pour la modifier.
  Future<void> _goToEdit(TransactionModel t) async {
    final succes = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddTransactionScreen(transaction: t)),
    );
    if (succes == true && mounted) {
      context.read<TransactionProvider>().loadTransactions();
    }
  }

  /// Popup affichant le détail complet d'une transaction, avec un accès
  /// direct au bouton "Modifier".
  void _afficherDetails(TransactionModel t) {
    final estRevenu = t.isIncome;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: estRevenu
                            ? AppColors.brandSoft
                            : AppColors.chipBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        iconePourTransaction(t),
                        color: estRevenu ? AppColors.brandDark : AppColors.dark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            estRevenu ? 'Entrée' : 'Dépense',
                            style: TextStyle(
                              fontSize: 12,
                              color: estRevenu
                                  ? AppColors.brandDark
                                  : AppColors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ligneDetail(
                  'Montant',
                  (estRevenu ? '+' : '-') + formatFcfa(t.amount),
                ),
                _ligneDetail('Catégorie', t.category),
                _ligneDetail('Date', t.formattedDate),
                if (t.paymentMethod != null)
                  _ligneDetail('Mode de paiement', t.paymentMethod!),
                if (t.note != null && t.note!.trim().isNotEmpty)
                  _ligneDetail('Note', t.note!),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Fermer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _goToEdit(t);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Modifier'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ligneDetail(String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              valeur,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  void _afficherSnackBar(bool succes, String? erreur) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: succes ? AppColors.brand : AppColors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: Row(
          children: [
            Icon(
              succes ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              succes
                  ? 'Transaction ajoutée avec succès'
                  : (erreur ?? "Échec de l'ajout de la transaction"),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmerEtSupprimer(TransactionModel t) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer la transaction ?'),
        content: Text(
          'Voulez-vous vraiment supprimer "${t.title}" ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirme != true || !mounted) return;

    final succes = await context.read<TransactionProvider>().deleteTransaction(
      t.id,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: succes ? AppColors.brand : AppColors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: Text(
          succes ? 'Transaction supprimée' : 'Échec de la suppression',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _choisirDate() async {
    final selection = await showDatePicker(
      context: context,
      initialDate: _dateFiltre ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr'),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
              primary: AppColors.brand,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selection != null) {
      setState(() => _dateFiltre = selection);
    }
  }

  void _effacerFiltreDate() {
    setState(() => _dateFiltre = null);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      // backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brand,
          onRefresh: () =>
              context.read<TransactionProvider>().loadTransactions(),
          child: _buildBody(provider),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _floattingButtonNavigation(onTap: _goToAdd),
    );
  }

  Widget _buildBody(TransactionProvider provider) {
    if (provider.error != null &&
        provider.transactions.isEmpty &&
        !provider.isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Icon(Icons.error_outline, size: 48, color: AppColors.red),
          const SizedBox(height: 12),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.grey),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.read<TransactionProvider>().loadTransactions(),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Réessayer',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
            ),
          ),
        ],
      );
    }

    if (provider.isLoading && provider.transactions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brand),
      );
    }

    final filtrees = _filtrees(provider.transactions);
    final groupes = _groupes(filtrees);
    final total = filtrees.length;

    final double totalRevenus = provider.totalIncome;
    final double totalDepenses = provider.totalExpense;
    final double solde = provider.balance;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: AppColors.dark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Transactions',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: _choisirDate,
                      onLongPress: _dateFiltre != null
                          ? _effacerFiltreDate
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _dateFiltre != null
                              ? AppColors.brand
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: _dateFiltre != null
                              ? Colors.white
                              : AppColors.dark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  onChanged: (v) => setState(() => _recherche = v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une transaction...',
                    hintStyle: const TextStyle(color: AppColors.grey),
                    prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_dateFiltre != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatDateFr(_dateFiltre!),
                              style: const TextStyle(
                                color: AppColors.brandDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: _effacerFiltreDate,
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: AppColors.brandDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _chipFiltre('Tout'),
                      const SizedBox(width: 8),
                      _chipFiltre('Revenus'),
                      const SizedBox(width: 8),
                      _chipFiltre('Dépenses'),
                      const SizedBox(width: 8),
                      _chipPlus(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _carteSolde(totalRevenus, totalDepenses, solde),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Historique',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    if (total > 7)
                      TextButton(
                        onPressed: () => setState(() => _voirTout = !_voirTout),
                        child: Text(
                          _voirTout ? 'Réduire' : 'Voir tout',
                          style: const TextStyle(
                            color: AppColors.brandDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (groupes.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Aucune transaction trouvée',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _construireListeGroupee(groupes),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _construireListeGroupee(
    Map<String, List<TransactionModel>> groupes,
  ) {
    final widgets = <Widget>[];
    for (final entree in groupes.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Text(
            entree.key,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
      for (final t in entree.value) {
        widgets.add(
          Dismissible(
            key: ValueKey('transaction_${t.id}'),
            direction: DismissDirection.endToStart, // droite -> gauche
            confirmDismiss: (_) async {
              await _confirmerEtSupprimer(t);
              return false; // on gère nous-mêmes le retrait via loadTransactions/provider
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, color: Colors.white, size: 22),
                  SizedBox(height: 2),
                  Text(
                    'Supprimer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            child: _carteTransaction(t),
          ),
        );
        widgets.add(const SizedBox(height: 10));
      }
    }
    return widgets;
  }

  Widget _chipFiltre(String label) {
    final selectionne = _filtre == label;
    return GestureDetector(
      onTap: () => setState(() => _filtre = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selectionne ? AppColors.brand : AppColors.chipBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selectionne ? Colors.white : AppColors.dark,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _chipPlus() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filtres avancés bientôt disponibles')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.chipBg, width: 1.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.filter_alt_outlined, size: 16, color: AppColors.grey),
            SizedBox(width: 4),
            Text('Plus', style: TextStyle(color: AppColors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _carteSolde(double totalRevenus, double totalDepenses, double solde) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Solde disponible',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatFcfa(solde),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(
                solde >= 0 ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REVENUS',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+ ${formatFcfa(totalRevenus)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'DÉPENSES',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '- ${formatFcfa(totalDepenses)}',
                      style: const TextStyle(
                        color: AppColors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _carteTransaction(TransactionModel t) {
    final estRevenu = t.isIncome;
    final montantTxt = (estRevenu ? '+' : '-') + formatFcfa(t.amount);
    return InkWell(
      onTap: () => _afficherDetails(t),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: estRevenu ? AppColors.brandSoft : AppColors.chipBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconePourTransaction(t),
                color: estRevenu ? AppColors.brandDark : AppColors.dark,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${t.category}  •  ${formatDateIso(t.date)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
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
                    color: estRevenu ? AppColors.brandDark : AppColors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: estRevenu ? AppColors.brandSoft : AppColors.redSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estRevenu ? 'Entrée' : 'Dépense',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: estRevenu ? AppColors.brandDark : AppColors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                size: 18,
                color: AppColors.grey,
              ),
              padding: EdgeInsets.zero,
              onSelected: (value) {
                if (value == 'details') {
                  _afficherDetails(t);
                } else if (value == 'edit') {
                  _goToEdit(t);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'details',
                  child: Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Voir détails'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton flottant à bords arrondis, en bas à droite.
Widget _floattingButtonNavigation({required VoidCallback onTap}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.brand,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.brand.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    ),
  );
}
