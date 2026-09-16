import 'package:flutter/material.dart';
import 'add_category_screen.dart';
import 'edit_category_screen.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ['Alimentation', 'Transport', 'Abonnements', 'Santé', 'Loisirs'];

    return Scaffold(
      appBar: AppBar(title: const Text('Catégories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCategoryScreen())),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.category)),
              title: Text(categories[index]),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditCategoryScreen())),
              ),
            ),
          );
        },
      ),
    );
  }
}