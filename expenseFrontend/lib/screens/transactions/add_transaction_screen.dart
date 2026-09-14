import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_expenses/core/widgets/app_snackbar.dart';
import 'package:app_expenses/models/category_model.dart';
import 'package:app_expenses/models/transaction_model.dart';
import 'package:app_expenses/providers/transaction_provider.dart';
import 'package:app_expenses/repositories/category_repository.dart';

class AddTransactionScreen extends StatefulWidget {
  /// Si [transaction] est fourni, l'écran s'ouvre en mode "édition" :
  /// les champs sont pré-remplis et la soumission fait un update
  /// au lieu d'une création.
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  static const String _typeDepense = 'Dépense';
  static const String _typeRevenu = 'Revenu';
  static const String _paiementCarte = 'Carte';
  static const String _paiementEspeces = 'Espèces';

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final CategoryRepository _categoryRepository = CategoryRepository();

  late String _selectedType;
  late String _selectedPaymentMethod;
  late DateTime _selectedDate;

  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;

  bool _isLoadingCategories = true;
  String? _categoriesError;
  bool _isSubmitting = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    final existing = widget.transaction;
    _selectedType = existing?.type ?? _typeDepense;
    _selectedPaymentMethod = existing?.paymentMethod ?? _paiementCarte;
    _selectedDate = existing?.date ?? DateTime.now();

    if (existing != null) {
      _amountController.text = _formatAmountForInput(existing.amount);
      _noteController.text = existing.note ?? '';
    }

    _amountController.addListener(() => setState(() {}));
    _loadCategories();
  }

  String _formatAmountForInput(double amount) {
    return amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    try {
      final categories = await _categoryRepository.getCategories();
      if (!mounted) return;

      String? preselected;
      final existing = widget.transaction;
      if (existing != null) {
        // En édition : on retrouve la catégorie par son nom
        // (la transaction ne stocke que le nom, pas l'id).
        final match = categories.where((c) => c.nom == existing.category);
        preselected = match.isNotEmpty
            ? match.first.id?.toString()
            : (categories.isNotEmpty ? categories.first.id?.toString() : null);
      } else {
        preselected =
            categories.isNotEmpty ? categories.first.id?.toString() : null;
      }

      setState(() {
        _categories = categories;
        _selectedCategoryId = preselected;
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categoriesError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  double? get _parsedAmount {
    final raw = _amountController.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  bool get _isFormValid {
    final amount = _parsedAmount;
    return amount != null && amount > 0 && _selectedCategoryId != null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_isFormValid) return;

    setState(() => _isSubmitting = true);

    try {
      final selectedCategory = _categories.firstWhere(
        (c) => c.id?.toString() == _selectedCategoryId,
      );

      final transaction = TransactionModel(
        id: widget.transaction?.id ?? 0,
        title: selectedCategory.nom,
        category: selectedCategory.nom,
        amount: _parsedAmount!,
        type: _selectedType,
        date: _selectedDate,
        paymentMethod: _selectedPaymentMethod,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      final provider = context.read<TransactionProvider>();
      final success = _isEditing
          ? await provider.updateTransaction(transaction)
          : await provider.createTransaction(transaction);

      if (!mounted) return;

      if (success) {
        AppSnackbar.success(
          context,
          _isEditing
              ? 'Transaction mise à jour avec succès 🎉'
              : 'Transaction ajoutée avec succès 🎉',
        );
        // On arrête le spinner AVANT de fermer l'écran, pas après.
        setState(() => _isSubmitting = false);
        Navigator.pop(context, true);
      } else {
        final error = provider.error;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ??
                  (_isEditing
                      ? "La transaction n'a pas pu être modifiée."
                      : "La transaction n'a pas pu être ajoutée."),
            ),
          ),
        );
      }
    } catch (e) {
      // Filet de sécurité : même en cas d'erreur imprévue, le spinner s'arrête.
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur inattendue : $e')));
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        // backgroundColor: const Color(0xFFF3F4F6),
        // elevation: 0,
        foregroundColor: Colors.black87,
        title: Text(
          _isEditing ? 'Modifier la transaction' : 'Ajouter une transaction',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTypeToggle(),
              const SizedBox(height: 24),
              _buildAmountField(),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionLabel(Icons.local_offer_outlined, 'Catégorie'),
                    const SizedBox(height: 8),
                    _buildCategoryField(),
                    const SizedBox(height: 20),
                    _buildSectionLabel(
                      Icons.calendar_today_outlined,
                      "Date de l'opération",
                    ),
                    const SizedBox(height: 8),
                    _buildDateField(),
                    const SizedBox(height: 20),
                    _buildSectionLabel(
                      Icons.credit_card_outlined,
                      'Mode de paiement',
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentMethodField(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ajouter une note (optionnel)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ex: Déjeuner professionnel...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: (_isFormValid && !_isSubmitting) ? _submit : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: const Color(0xFF34C759),
                  disabledBackgroundColor: const Color(0xFFA9E2B8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isEditing ? 'Mettre à jour' : 'Enregistrer'),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _isEditing
                      ? 'Les modifications seront appliquées à cette transaction.'
                      : 'La transaction sera ajoutée à votre historique.',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.green),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTypeToggle() {
    const types = [_typeDepense, _typeRevenu];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: types.map((type) {
          final isSelected = _selectedType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  type,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      children: [
        const Text(
          'MONTANT',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.black26),
                  border: InputBorder.none,
                ),
                validator: (v) {
                  final value = v?.trim().replaceAll(',', '.');
                  if (value == null || value.isEmpty) return 'Montant requis';
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) return 'Montant invalide';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'FCFA',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    if (_isLoadingCategories) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_categoriesError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_categoriesError!, style: const TextStyle(color: Colors.red)),
          TextButton(
            onPressed: _loadCategories,
            child: const Text('Réessayer'),
          ),
        ],
      );
    }

    if (_categories.isEmpty) {
      return const Text(
        "Aucune catégorie disponible. Créez-en une avant d'ajouter une transaction.",
        style: TextStyle(color: Colors.orange),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedCategoryId,
      decoration: InputDecoration(
        hintText: 'Choisir une catégorie',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      items: _categories
          .map(
            (c) => DropdownMenuItem<String>(
              value: c.id?.toString(),
              child: Text(c.nom),
            ),
          )
          .toList(),
      onChanged: (val) => setState(() => _selectedCategoryId = val),
      validator: (v) => v == null ? 'Catégorie requise' : null,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _isSubmitting ? null : _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDate(_selectedDate)),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodField() {
    const methods = [_paiementCarte, _paiementEspeces];
    return Row(
      children: methods.map((method) {
        final isSelected = _selectedPaymentMethod == method;
        final icon = method == _paiementCarte
            ? Icons.credit_card
            : Icons.account_balance_wallet_outlined;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: method == methods.first ? 8 : 0,
              left: method == methods.last ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _selectedPaymentMethod = method),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey.shade200,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? Colors.green : Colors.grey.shade600,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      method,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}