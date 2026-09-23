import 'package:cloud_firestore/cloud_firestore.dart';

/// Member entity model (Patron / Student) mapping to Firestore 'members' collection
class MemberModel {
  final String id;
  final String? userId;
  final String memberId;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String? profileImage;
  final DateTime? joinedAt;
  final String status; // 'active', 'suspended', 'expired'
  final int totalBorrowed;
  final int currentBorrowed;
  final double outstandingFine;
  final int maxBooksAllowed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MemberModel({
    required this.id,
    this.userId,
    String? memberId,
    String? membershipNumber,
    String? fullName,
    String? name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.profileImage,
    DateTime? joinedAt,
    DateTime? joinedDate,
    this.status = 'active',
    this.totalBorrowed = 0,
    this.currentBorrowed = 0,
    this.outstandingFine = 0.0,
    this.maxBooksAllowed = 3,
    this.createdAt,
    this.updatedAt,
  })  : memberId = memberId ?? membershipNumber ?? id,
        fullName = fullName ?? name ?? '',
        joinedAt = joinedAt ?? joinedDate ?? createdAt;

  // Backward compatibility getters
  String get name => fullName;
  String get membershipNumber => memberId;
  DateTime? get joinedDate => joinedAt;
  bool get isActive => status.toLowerCase() == 'active';
  int get activeLoansCount => currentBorrowed;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'memberId': memberId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'profileImage': profileImage,
      'joinedAt': joinedAt != null ? Timestamp.fromDate(joinedAt!) : FieldValue.serverTimestamp(),
      'status': status,
      'totalBorrowed': totalBorrowed,
      'currentBorrowed': currentBorrowed,
      'outstandingFine': outstandingFine,
      'maxBooksAllowed': maxBooksAllowed,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MemberModel(
      id: documentId.isNotEmpty ? documentId : (map['id'] ?? ''),
      userId: map['userId'],
      memberId: map['memberId'] ?? map['membershipNumber'] ?? documentId,
      fullName: map['fullName'] ?? map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      profileImage: map['profileImage'],
      joinedAt: _parseDateTime(map['joinedAt'] ?? map['joinedDate']),
      status: map['status'] ?? 'active',
      totalBorrowed: (map['totalBorrowed'] as num?)?.toInt() ?? 0,
      currentBorrowed: (map['currentBorrowed'] as num?)?.toInt() ?? 0,
      outstandingFine: (map['outstandingFine'] as num?)?.toDouble() ?? 0.0,
      maxBooksAllowed: (map['maxBooksAllowed'] as num?)?.toInt() ?? 3,
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

  MemberModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
    String? status,
    int? totalBorrowed,
    int? currentBorrowed,
    double? outstandingFine,
    int? maxBooksAllowed,
    DateTime? updatedAt,
  }) {
    return MemberModel(
      id: id,
      userId: userId,
      memberId: memberId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      joinedAt: joinedAt,
      status: status ?? this.status,
      totalBorrowed: totalBorrowed ?? this.totalBorrowed,
      currentBorrowed: currentBorrowed ?? this.currentBorrowed,
      outstandingFine: outstandingFine ?? this.outstandingFine,
      maxBooksAllowed: maxBooksAllowed ?? this.maxBooksAllowed,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
