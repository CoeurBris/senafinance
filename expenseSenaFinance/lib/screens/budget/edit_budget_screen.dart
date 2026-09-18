import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senafinance/core/widgets/app_snackbar.dart';
import 'package:senafinance/models/budget_model.dart';
import 'package:senafinance/providers/budget_provider.dart';
import 'package:senafinance/providers/category_provider.dart';



class EditBudgetScreen extends StatefulWidget {
  final BudgetModel budget;
  const EditBudgetScreen({super.key, required this.budget});

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  int? _selectedCategoryId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.budget.nom);
    _amountController = TextEditingController(text: widget.budget.montant.toString());
    _selectedCategoryId = widget.budget.categoryId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final updated = widget.budget.copyWith(
      titre: _titleController.text.trim(),
      montant: double.parse(_amountController.text),
      categoryId: _selectedCategoryId,
    );

    final ok = await context.read<BudgetProvider>().updateBudget(updated);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      AppSnackbar.success(context, 'Budget modifié avec succès 🎉');
      Navigator.pop(context, true);
    } else {
      final error = context.read<BudgetProvider>().error;
      AppSnackbar.error(context, error ?? "Le budget n'a pas pu être modifié.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le Budget')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du budget',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant (FCFA)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || double.tryParse(v) == null ? 'Montant invalide' : null,
              ),
              const SizedBox(height: 16),
              if (categories.isNotEmpty)
                DropdownButtonFormField<int>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nom)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Mettre à jour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}