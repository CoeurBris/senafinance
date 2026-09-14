import 'package:app_expenses/core/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_expenses/models/budget_model.dart';
import 'package:app_expenses/providers/budget_provider.dart';
import 'package:app_expenses/providers/category_provider.dart';

/// Ouvre le formulaire d'ajout de budget en bottom sheet.
/// Retourne `true` (via Navigator.pop) si l'ajout a réussi.
Future<bool?> showAddBudgetSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _AddBudgetSheetContent(),
  );
}

class _AddBudgetSheetContent extends StatefulWidget {
  const _AddBudgetSheetContent();

  @override
  State<_AddBudgetSheetContent> createState() =>
      _AddBudgetSheetContentState();
}

class _AddBudgetSheetContentState extends State<_AddBudgetSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _selectedCategoryId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      AppSnackbar.error(context, 'Veuillez choisir une catégorie.');
      return;
    }

    setState(() => _submitting = true);

    final budget = BudgetModel(
      titre: _titleController.text.trim(),
      montant: double.parse(_amountController.text),
      categoryId: _selectedCategoryId,
      description: _descriptionController.text.trim(),
    );

    final ok = await context.read<BudgetProvider>().createBudget(budget);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      AppSnackbar.success(context, 'Budget ajouté avec succès 🎉');
      Navigator.pop(context, true);
    } else {
      final error = context.read<BudgetProvider>().error;
      AppSnackbar.error(context, error ?? "Le budget n'a pas pu être ajouté.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

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
                  'Ajouter un Budget',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre du budget',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
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
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optionnel)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                if (categories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  )
                else
                  DropdownButtonFormField<int>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(),
                    ),
                    items: categories
                        .map(
                          (c) =>
                              DropdownMenuItem(value: c.id, child: Text(c.nom)),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategoryId = val),
                    validator: (v) =>
                        v == null ? 'Choisissez une catégorie' : null,
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('ENREGISTRER'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}