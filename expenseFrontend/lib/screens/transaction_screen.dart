import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String _selectedFilter = 'Toutes'; // 'Toutes', 'Dépense', 'Revenu'
  String _searchQuery = '';
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/transactions');
      if (mounted) {
        setState(() {
          _transactions = response as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Données fictives de repli pour la démonstration
        _transactions = [
          {
            'id': 1,
            'title': 'Achats Supermarché',
            'category': 'Alimentation',
            'amount': 24500,
            'type': 'Dépense',
            'date': '2026-08-20',
          },
          {
            'id': 2,
            'title': 'Virement Salaire',
            'category': 'Revenu',
            'amount': 450000,
            'type': 'Revenu',
            'date': '2026-08-15',
          },
          {
            'id': 3,
            'title': 'Facture Électricité',
            'category': 'Factures',
            'amount': 18000,
            'type': 'Dépense',
            'date': '2026-08-10',
          },
        ];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _transactions.where((tx) {
      final matchesFilter = _selectedFilter == 'Toutes' ||
          tx['type'].toString().toLowerCase() ==
              _selectedFilter.toLowerCase();
      final matchesSearch = tx['title']
              .toString()
              .toLowerCase()
              .contains(_searchQuery) ||
          tx['category'].toString().toLowerCase().contains(_searchQuery);
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() => _searchQuery = val.toLowerCase().trim());
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher une transaction...',
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF10B981)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip('Toutes'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Dépense'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Revenu'),
                  ],
                ),
              ],
            ),
          ),

          // Liste des transactions
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF10B981)))
                : filteredTransactions.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune transaction trouvée.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredTransactions.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final tx = filteredTransactions[index];
                          final isExpense = tx['type'] == 'Dépense';

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0.5,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isExpense
                                    ? Colors.red.shade50
                                    : const Color(0xFFE6F4EA),
                                child: Icon(
                                  isExpense
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: isExpense
                                      ? Colors.red
                                      : const Color(0xFF10B981),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                tx['title'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${tx['category']} • ${tx['date']}',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12),
                              ),
                              trailing: Text(
                                '${isExpense ? "-" : "+"}${tx['amount']} FCFA',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isExpense
                                      ? Colors.red.shade700
                                      : const Color(0xFF10B981),
                                ),
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

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF10B981),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = label);
        }
      },
    );
  }
}