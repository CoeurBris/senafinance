class TransactionModel {
  final int id;
  final String title;
  final String category;
  final double amount;
  final String type; // 'Dépense' ou 'Revenu'
  final DateTime date;
  final String? paymentMethod; // ex: 'Carte', 'Espèces'
  final String? note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    this.paymentMethod,
    this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? 'Sans titre',
      category:
          (json['category'] is Map
              ? json['category']['name']?.toString()
              : json['category']?.toString()) ??
          'Général',
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      // amount: (json['amount'] as num?)?.toDouble() ??
      //     double.tryParse(json['amount']?.toString() ?? '') ??
      //     0,
      type: json['type']?.toString() ?? 'Dépense',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      paymentMethod: json['payment_method']?.toString(),
      note: json['note']?.toString(),
    );
  }

  /// Payload envoyé à l'API pour créer/modifier une transaction.
  /// `id` n'est volontairement pas inclus : le backend l'attribue à la
  /// création, et il est déjà dans l'URL pour une mise à jour.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      // if (paymentMethod != null) 'payment_method': paymentMethod,
      if (note != null) 'note': note,
    };
  }

  TransactionModel copyWith({
    int? id,
    String? title,
    String? category,
    double? amount,
    String? type,
    DateTime? date,
    String? paymentMethod,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
    );
  }

  bool get isExpense => type.toLowerCase() == 'dépense';
  bool get isIncome => type.toLowerCase() == 'revenu';

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
