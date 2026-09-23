import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums/fine_status.dart';

/// Fine assessment and payment model mapping to Firestore 'fines' collection
class FineModel {
  final String id;
  final String borrowingId;
  final String memberId;
  final String memberName;
  final String bookId;
  final double amount;
  final int overdueDays;
  final FineStatus status;
  final DateTime issuedAt;
  final DateTime? paidAt;
  final DateTime? waivedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FineModel({
    required this.id,
    required this.borrowingId,
    required this.memberId,
    this.memberName = '',
    this.bookId = '',
    required this.amount,
    int? overdueDays,
    int? daysOverdue,
    this.status = FineStatus.unpaid,
    DateTime? issuedAt,
    DateTime? assessedDate,
    DateTime? paidAt,
    DateTime? paidDate,
    this.waivedAt,
    this.createdAt,
    this.updatedAt,
  })  : overdueDays = overdueDays ?? daysOverdue ?? 0,
        issuedAt = issuedAt ?? assessedDate ?? (createdAt ?? DateTime.now()),
        paidAt = paidAt ?? paidDate;

  // Backward compatibility getters
  DateTime get assessedDate => issuedAt;
  DateTime? get paidDate => paidAt;
  int get daysOverdue => overdueDays;
  bool get isPaid => status == FineStatus.paid;
  bool get isWaived => status == FineStatus.waived;

  Map<String, dynamic> toMap() {
    String statusStr;
    switch (status) {
      case FineStatus.paid:
        statusStr = 'PAID';
        break;
      case FineStatus.waived:
        statusStr = 'WAIVED';
        break;
      case FineStatus.unpaid:
        statusStr = 'PENDING';
        break;
    }

    return {
      'id': id,
      'borrowingId': borrowingId,
      'memberId': memberId,
      'memberName': memberName,
      'bookId': bookId,
      'amount': amount,
      'overdueDays': overdueDays,
      'status': statusStr,
      'issuedAt': Timestamp.fromDate(issuedAt),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'waivedAt': waivedAt != null ? Timestamp.fromDate(waivedAt!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory FineModel.fromMap(Map<String, dynamic> map, String documentId) {
    final statusStr = (map['status'] ?? 'unpaid').toString().toUpperCase();
    FineStatus parsedStatus;
    if (statusStr == 'PAID') {
      parsedStatus = FineStatus.paid;
    } else if (statusStr == 'WAIVED') {
      parsedStatus = FineStatus.waived;
    } else {
      parsedStatus = FineStatus.unpaid;
    }

    return FineModel(
      id: documentId.isNotEmpty ? documentId : (map['id'] ?? ''),
      borrowingId: map['borrowingId'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      bookId: map['bookId'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      overdueDays: (map['overdueDays'] ?? map['daysOverdue'] as num?)?.toInt() ?? 0,
      status: parsedStatus,
      issuedAt: _parseDateTime(map['issuedAt'] ?? map['assessedDate']) ?? DateTime.now(),
      paidAt: _parseDateTime(map['paidAt'] ?? map['paidDate']),
      waivedAt: _parseDateTime(map['waivedAt']),
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

  FineModel copyWith({
    FineStatus? status,
    DateTime? paidAt,
    DateTime? waivedAt,
    DateTime? updatedAt,
  }) {
    return FineModel(
      id: id,
      borrowingId: borrowingId,
      memberId: memberId,
      memberName: memberName,
      bookId: bookId,
      amount: amount,
      overdueDays: overdueDays,
      status: status ?? this.status,
      issuedAt: issuedAt,
      paidAt: paidAt ?? this.paidAt,
      waivedAt: waivedAt ?? this.waivedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
