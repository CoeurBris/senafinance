
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senafinance/core/widgets/app_snackbar.dart';
import 'package:senafinance/models/category_model.dart';
import 'package:senafinance/models/expense_model.dart';
import 'package:senafinance/providers/expense_provider.dart';
import 'package:senafinance/repositories/category_repository.dart';

Future<bool?> showAddExpenseSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _AddExpenseSheetContent(),
  );
}

class _AddExpenseSheetContent extends StatefulWidget {
  const _AddExpenseSheetContent();

  @override
  State<_AddExpenseSheetContent> createState() =>
      _AddExpenseSheetContentState();
}

class _AddExpenseSheetContentState extends State<_AddExpenseSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  final CategoryRepository _categoryRepository = CategoryRepository();

  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;

  DateTime _selectedDate = DateTime.now();

  bool _isLoadingCategories = true;
  bool _isSubmitting = false;
  String? _categoriesError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
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

      setState(() {
        _categories = categories;
        _selectedCategoryId = categories.isNotEmpty
            ? categories.first.id?.toString()
            : null;
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
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une catégorie.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final selectedCategory = _categories.firstWhere(
      (c) => c.id?.toString() == _selectedCategoryId,
    );

    final expense = ExpenseModel(
      titre: _titleController.text.trim(),
      montant: double.parse(_amountController.text),
      categorie: selectedCategory.nom,
      categoryId: int.tryParse(_selectedCategoryId!),
      date: _selectedDate,
    );

    final success = await context.read<ExpenseProvider>().createExpense(
      expense,
    );

    if (!mounted) return;

    if (success) {
      AppSnackbar.success(context, 'Dépense ajoutée avec succès 🎉');
      Navigator.pop(context, true);
    } else {
      final error = context.read<ExpenseProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? "La dépense n'a pas pu être ajoutée.")),
      );
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Ajouter une Dépense',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre / Libellé',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Titre requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Montant (FCFA)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || double.tryParse(v) == null
                      ? 'Montant invalide'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildCategoryField(),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/'
                    '${_selectedDate.month.toString().padLeft(2, '0')}/'
                    '${_selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _isSubmitting ? null : _pickDate,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
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
                      : const Text('AJOUTER LA DÉPENSE'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
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
        'Aucune catégorie disponible. Créez-en une avant d\'ajouter une dépense.',
        style: TextStyle(color: Colors.orange),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'Catégorie',
        border: OutlineInputBorder(),
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
}