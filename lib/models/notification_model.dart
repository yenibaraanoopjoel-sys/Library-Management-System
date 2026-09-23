import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification entity model mapping to Firestore 'notifications' collection
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'due_soon', 'overdue', 'fine', 'system', 'return'
  final bool isRead;
  final String relatedId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    String? userId,
    required this.title,
    required this.message,
    String? type,
    this.isRead = false,
    this.relatedId = '',
    DateTime? createdAt,
    DateTime? timestamp,
  })  : userId = userId ?? '',
        type = type ?? 'system',
        createdAt = createdAt ?? timestamp ?? (createdAt ?? DateTime.now());

  // Backward compatibility getters
  DateTime get timestamp => createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'relatedId': relatedId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NotificationModel(
      id: documentId.isNotEmpty ? documentId : (map['id'] ?? ''),
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'info',
      isRead: map['isRead'] ?? false,
      relatedId: map['relatedId'] ?? '',
      createdAt: _parseDateTime(map['createdAt'] ?? map['timestamp']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val);
    try {
      return (val as dynamic).toDate();
    } catch (_) {
      return null;
    }
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId,
      createdAt: createdAt,
    );
  }
}
