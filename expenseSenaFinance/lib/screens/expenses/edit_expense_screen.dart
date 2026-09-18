
import 'package:flutter/material.dart';
import 'package:senafinance/core/widgets/app_snackbar.dart';
import 'package:senafinance/models/category_model.dart';
import 'package:senafinance/repositories/category_repository.dart';
import 'package:senafinance/services/expense_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final Map<String, dynamic> expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  final ExpenseService _expenseService = ExpenseService();
  final CategoryRepository _categoryRepository = CategoryRepository();

  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;

  late DateTime _selectedDate;

  bool _isLoadingCategories = true;
  bool _isSubmitting = false;
  String? _categoriesError;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.expense['title']?.toString() ?? '',
    );

    final rawAmount = widget.expense['amount'];
    final parsedAmount = rawAmount != null
        ? double.tryParse(rawAmount.toString())
        : null;
    _amountController = TextEditingController(
      text: parsedAmount?.toString() ?? '',
    );

    // La catégorie peut arriver soit en categoryId direct,
    // soit imbriquée dans category: { id, name }
    _selectedCategoryId =
        widget.expense['categoryId']?.toString() ??
        (widget.expense['category'] is Map
            ? widget.expense['category']['id']?.toString()
            : null);

    final rawDate = widget.expense['date']?.toString();
    _selectedDate = rawDate != null
        ? (DateTime.tryParse(rawDate) ?? DateTime.now())
        : DateTime.now();

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
        // On ne réécrase le choix que si l'id sélectionné n'existe plus
        // dans la liste (catégorie supprimée entre-temps par ex.)
        final stillExists = categories.any(
          (c) => c.id?.toString() == _selectedCategoryId,
        );
        if (!stillExists) {
          _selectedCategoryId = categories.isNotEmpty
              ? categories.first.id?.toString()
              : null;
        }
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

    final id = widget.expense['id'];
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Identifiant de la dépense manquant.')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une catégorie.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _expenseService.updateExpense(id.toString(), {
        'title': _titleController.text.trim(),
        'amount': double.parse(_amountController.text),
        'categoryId': _selectedCategoryId,
        'date':
            '${_selectedDate.year.toString().padLeft(4, '0')}-'
            '${_selectedDate.month.toString().padLeft(2, '0')}-'
            '${_selectedDate.day.toString().padLeft(2, '0')}',
      });

      if (!mounted) return;
      AppSnackbar.success(context, 'Dépense modifiée avec succès 🎉');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier la Dépense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      )
                    : const Text('Mettre à jour'),
              ),
            ],
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
        'Aucune catégorie disponible.',
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