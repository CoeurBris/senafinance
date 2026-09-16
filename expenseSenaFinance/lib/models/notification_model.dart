class NotificationModel {
  final String? id;
  final String? userId;
  final String title;
  final String body;
  final String? type;
  final bool isRead;
  final String? relatedExpenseId;
  final DateTime createdAt;

  NotificationModel({
    this.id,
    this.userId,
    required this.title,
    required this.body,
    this.type,
    this.isRead = false,
    this.relatedExpenseId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'],
      isRead: json['isRead'] ?? false,
      relatedExpenseId: json['relatedExpenseId']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id, userId: userId, title: title, body: body, type: type,
      isRead: isRead ?? this.isRead, relatedExpenseId: relatedExpenseId,
      createdAt: createdAt,
    );
  }
}