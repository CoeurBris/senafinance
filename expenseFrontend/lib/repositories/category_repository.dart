import 'package:app_expenses/models/category_model.dart';
import 'package:app_expenses/services/category_service.dart';

class CategoryRepository {
  final CategoryService _categoryService;

  CategoryRepository({CategoryService? categoryService})
      : _categoryService = categoryService ?? CategoryService();

  Future<List<CategoryModel>> getCategories() async {
    final data = await _categoryService.getCategories();
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<CategoryModel> getCategoryById(int id) async {
    final data = await _categoryService.getCategoryById(id.toString());
    return CategoryModel.fromJson(data);
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    final data = await _categoryService.createCategory(category.toJson());
    return CategoryModel.fromJson(data);
  }

  Future<CategoryModel> updateCategory(CategoryModel category) async {
    if (category.id == null) {
      throw Exception('Impossible de modifier une catégorie sans identifiant.');
    }
    final data = await _categoryService.updateCategory(category.id.toString(), category.toJson());
    return CategoryModel.fromJson(data);
  }

  Future<void> deleteCategory(int id) async {
    await _categoryService.deleteCategory(id.toString());
  }
}