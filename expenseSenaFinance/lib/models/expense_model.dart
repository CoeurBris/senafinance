class ExpenseModel {
  final int? id;
  final String titre;
  final double montant;
  final String categorie;
  final int? categoryId;
  final DateTime date;
  final String? description;
  final int? budgetId;

  ExpenseModel({
    this.id,
    required this.titre,
    required this.montant,
    required this.categorie,
    this.categoryId,
    required this.date,
    this.description,
    this.budgetId,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    final categoryMap = map['category'];

    return ExpenseModel(
      id: _parseInt(map['id']),
      titre: map['title']?.toString() ?? '',
      montant: _parseDouble(map['amount']),
      categorie: categoryMap is Map
          ? (categoryMap['name']?.toString() ?? '')
          : (map['categoryName']?.toString() ?? 'Sans catégorie'),
      categoryId: _parseInt(
        map['categoryId'] ?? (categoryMap is Map ? categoryMap['id'] : null),
      ),
      date: _parseDate(map['date']) ?? DateTime.now(),
      description: map['description']?.toString(),
      budgetId: _parseInt(map['budgetId']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': titre,
      'amount': montant,
      'categoryId': categoryId,
      'date':
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}',
      if (description != null) 'description': description,
      if (budgetId != null) 'budgetId': budgetId,
    };
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}