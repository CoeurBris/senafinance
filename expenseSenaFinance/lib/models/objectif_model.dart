class ObjectifModel {
  final int? id;
  final int? userId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ObjectifModel({
    this.id,
    this.userId,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    this.targetDate,
    this.description = '',
    this.createdAt,
    this.updatedAt,
  });

  double get montantRestant => targetAmount - currentAmount;

  double get pourcentage {
    if (targetAmount <= 0) return 0;
    return ((currentAmount / targetAmount) * 100).clamp(0, 100);
  }

  bool get estAtteint => currentAmount >= targetAmount;

  factory ObjectifModel.fromJson(Map<String, dynamic> json) {
    return ObjectifModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['userId']),
      title: json['title']?.toString() ?? '',
      targetAmount: _parseDouble(json['targetAmount']),
      currentAmount: _parseDouble(json['currentAmount']),
      targetDate: _parseDate(json['targetDate']),
      description: json['description']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      if (targetDate != null) 'targetDate': targetDate!.toIso8601String(),
      'description': description,
    };
  }

  ObjectifModel copyWith({
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? description,
  }) {
    return ObjectifModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}