import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums/user_role.dart';

/// User entity model representing a system account in Firestore users/{uid}
class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final String? profileImage;
  final String? memberId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    String? uid,
    String? id,
    String? fullName,
    String? name,
    required this.email,
    this.phone = '',
    required this.role,
    String? profileImage,
    String? photoUrl,
    this.memberId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  })  : uid = uid ?? id ?? '',
        fullName = fullName ?? name ?? '',
        profileImage = profileImage ?? photoUrl;

  // Backward compatibility getters
  String get id => uid;
  String get name => fullName;
  String? get photoUrl => profileImage;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'profileImage': profileImage,
      'memberId': memberId,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId.isNotEmpty ? documentId : (map['uid'] ?? ''),
      fullName: map['fullName'] ?? map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.fromString(map['role'] ?? 'member'),
      profileImage: map['profileImage'] ?? map['photoUrl'],
      memberId: map['memberId'],
      isActive: map['isActive'] ?? true,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
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

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    String? profileImage,
    String? memberId,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      memberId: memberId ?? this.memberId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
