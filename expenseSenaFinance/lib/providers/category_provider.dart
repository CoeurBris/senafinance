
import 'package:flutter/foundation.dart';
import 'package:senafinance/models/category_model.dart';
import 'package:senafinance/repositories/category_repository.dart';


class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryProvider({
    CategoryRepository? repository,
  }) : _repository = repository ?? CategoryRepository();

  List<CategoryModel> _categories = [];

  bool _isLoading = false;

  String? _error;

  CategoryModel? _selectedCategory;

  List<CategoryModel> get categories =>
      List.unmodifiable(_categories);

  bool get isLoading => _isLoading;

  String? get error => _error;

  CategoryModel? get selectedCategory =>
      _selectedCategory;

  /// Charger toutes les catégories
  Future<void> loadCategories() async {
    _setLoading(true);
    _error = null;

    try {
      _categories =
          await _repository.getCategories();
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );
    } finally {
      _setLoading(false);
    }
  }

  /// Récupérer une catégorie
  Future<CategoryModel?> loadCategoryById(
    int id,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final category =
          await _repository.getCategoryById(id);

      _selectedCategory = category;

      return category;
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Créer une catégorie
  Future<bool> createCategory(
    CategoryModel category,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final createdCategory =
          await _repository.createCategory(
        category,
      );

      _categories.add(createdCategory);

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Modifier une catégorie
  Future<bool> updateCategory(
    CategoryModel category,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedCategory =
          await _repository.updateCategory(
        category,
      );

      final index = _categories.indexWhere(
        (item) => item.id == updatedCategory.id,
      );

      if (index != -1) {
        _categories[index] = updatedCategory;
      }

      if (_selectedCategory?.id ==
          updatedCategory.id) {
        _selectedCategory = updatedCategory;
      }

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Supprimer une catégorie
  Future<bool> deleteCategory(
    int id,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.deleteCategory(id);

      _categories.removeWhere(
        (category) => category.id == id,
      );

      if (_selectedCategory?.id == id) {
        _selectedCategory = null;
      }

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sélectionner une catégorie
  void selectCategory(
    CategoryModel? category,
  ) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}