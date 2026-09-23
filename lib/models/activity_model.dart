import 'package:cloud_firestore/cloud_firestore.dart';

/// System audit log and recent activity record mapping to Firestore 'activities' collection
class ActivityModel {
  final String id;
  final String type; // e.g. BOOK_ADDED, BOOK_ISSUED, BOOK_RETURNED, etc.
  final String message;
  final String userId;
  final String userName;
  final String relatedId;
  final DateTime createdAt;

  ActivityModel({
    required this.id,
    String? type,
    String? action,
    String? entityType,
    this.message = '',
    String? userId,
    String? userName,
    String? relatedId,
    String? entityId,
    DateTime? createdAt,
    DateTime? timestamp,
  })  : type = type ?? action ?? entityType ?? 'SYSTEM_EVENT',
        userId = userId ?? 'system',
        userName = userName ?? 'System',
        relatedId = relatedId ?? entityId ?? '',
        createdAt = createdAt ?? timestamp ?? (createdAt ?? DateTime.now());

  // Backward compatibility getters
  String get action => type;
  String get entityType => type;
  String get entityId => relatedId;
  DateTime get timestamp => createdAt;
  String get title => type.replaceAll('_', ' ');
  String get subtitle => message;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'userId': userId,
      'userName': userName,
      'relatedId': relatedId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ActivityModel(
      id: documentId.isNotEmpty ? documentId : (map['id'] ?? ''),
      type: map['type'] ?? map['action'] ?? 'SYSTEM_EVENT',
      message: map['message'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      relatedId: map['relatedId'] ?? map['entityId'] ?? '',
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
}
