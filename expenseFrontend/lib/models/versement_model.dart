class VersementModel {
  final int? id;
  final int objectifId;
  final double montant;
  final DateTime? createdAt;

  VersementModel({
    this.id,
    required this.objectifId,
    required this.montant,
    this.createdAt,
  });

  factory VersementModel.fromJson(Map<String, dynamic> json) {
    return VersementModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      objectifId: json['objectifId'] is int
          ? json['objectifId']
          : int.tryParse(json['objectifId'].toString()) ?? 0,
      montant: json['montant'] is num
          ? (json['montant'] as num).toDouble()
          : double.tryParse(json['montant'].toString()) ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}