class CategoryModel {
  final int? id;
  final String nom;
  final String? icone;
  final String? couleur;
  final String? description;

  CategoryModel({
    this.id,
    required this.nom,
    this.icone,
    this.couleur,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      nom: (json['name'] ?? json['nom'] ?? '').toString(),
      icone: json['icon']?.toString(),
      couleur: json['color']?.toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': nom,
      if (description != null) 'description': description,
    };
  }

  void operator [](String other) {}
}