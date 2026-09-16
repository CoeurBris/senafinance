import 'category_model.dart';

class BudgetModel {
  final int? id;
  final int? categoryId;
  final CategoryModel? category;
  final String? titre;
  final double montant;
  final double montantDepense;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String description;
  final bool actif;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BudgetModel({
    this.id,
    this.categoryId,
    this.category,
    this.titre,
    required this.montant,
    this.montantDepense = 0,
    this.dateDebut,
    this.dateFin,
    this.description = '',
    this.actif = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Le backend ne garantit pas toujours un titre : on retombe sur le nom
  /// de la catégorie, puis la description, puis un nom générique.
  String get nom {
    if (titre != null && titre!.isNotEmpty) return titre!;
    if (category != null && category!.nom.isNotEmpty) return category!.nom;
    if (description.isNotEmpty) return description;
    return 'Budget #${id ?? ''}';
  }

  double get montantRestant => montant - montantDepense;

  double get pourcentageUtilise {
    if (montant <= 0) return 0;
    return ((montantDepense / montant) * 100).clamp(0, 100);
  }

  bool get estDepasse => montantDepense > montant;

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: _parseInt(json['id']),
      categoryId: _parseInt(json['categoryId']),
      category: json['category'] is Map
          ? CategoryModel.fromJson(Map<String, dynamic>.from(json['category']))
          : null,
      titre: json['name']?.toString(),
      montant: _parseDouble(json['amountLimit'] ?? json['montant']),
      montantDepense: _parseDouble(json['montantDepense'] ?? json['amountSpent']),
      dateDebut: _parseDate(json['startDate'] ?? json['dateDebut']),
      dateFin: _parseDate(json['endDate'] ?? json['dateFin']),
      description: json['description']?.toString() ?? '',
      actif: json['actif'] is bool
          ? json['actif'] as bool
          : _computeActif(_parseDate(json['endDate'])),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': titre,
      'categoryId': categoryId,
      'amountLimit': montant,
      'description': description,
      if (dateDebut != null) 'startDate': dateDebut!.toIso8601String(),
      if (dateFin != null) 'endDate': dateFin!.toIso8601String(),
    };
  }

  BudgetModel copyWith({
    int? id,
    int? categoryId,
    CategoryModel? category,
    String? titre,
    double? montant,
    double? montantDepense,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? description,
    bool? actif,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      titre: titre ?? this.titre,
      montant: montant ?? this.montant,
      montantDepense: montantDepense ?? this.montantDepense,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      description: description ?? this.description,
      actif: actif ?? this.actif,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static bool _computeActif(DateTime? endDate) {
    if (endDate == null) return true;
    return endDate.isAfter(DateTime.now());
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