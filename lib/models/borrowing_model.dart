import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums/borrowing_status.dart';

/// Borrowing transaction record model mapping to Firestore 'borrowings' collection
class BorrowingModel {
  final String id;
  final String bookId;
  final String bookTitle;
  final String memberId;
  final String memberName;
  final String issuedBy;
  final DateTime issueDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final BorrowingStatus status;
  final double fineAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BorrowingModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.memberId,
    required this.memberName,
    String? issuedBy,
    DateTime? issueDate,
    DateTime? borrowDate,
    required this.dueDate,
    this.returnDate,
    this.status = BorrowingStatus.active,
    this.fineAmount = 0.0,
    int? daysOverdue,
    this.createdAt,
    this.updatedAt,
  })  : issuedBy = issuedBy ?? 'librarian',
        issueDate = issueDate ?? borrowDate ?? dueDate;

  // Backward compatibility getters
  DateTime get borrowDate => issueDate;
  int get daysOverdue => overdueDays;

  /// Dynamic overdue determination
  bool get isOverdue {
    if (status == BorrowingStatus.returned) return false;
    return DateTime.now().isAfter(dueDate);
  }

  /// Dynamic overdue days calculation
  int get overdueDays {
    if (status == BorrowingStatus.returned) {
      if (returnDate != null && returnDate!.isAfter(dueDate)) {
        return returnDate!.difference(dueDate).inDays;
      }
      return 0;
    }
    final now = DateTime.now();
    if (now.isAfter(dueDate)) {
      return now.difference(dueDate).inDays;
    }
    return 0;
  }

  /// Dynamic display status (taking current time into account)
  String get effectiveStatusString {
    if (status == BorrowingStatus.returned) return 'RETURNED';
    if (isOverdue) return 'OVERDUE';
    final remainingDays = dueDate.difference(DateTime.now()).inDays;
    if (remainingDays <= 2) return 'DUE_SOON';
    return 'ACTIVE';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'memberId': memberId,
      'memberName': memberName,
      'issuedBy': issuedBy,
      'issueDate': Timestamp.fromDate(issueDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'returnDate': returnDate != null ? Timestamp.fromDate(returnDate!) : null,
      'status': status.name.toUpperCase(),
      'fineAmount': fineAmount,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory BorrowingModel.fromMap(Map<String, dynamic> map, String documentId) {
    final rawStatus = (map['status'] ?? 'active').toString().toLowerCase();
    BorrowingStatus parsedStatus;
    if (rawStatus == 'returned') {
      parsedStatus = BorrowingStatus.returned;
    } else if (rawStatus == 'overdue') {
      parsedStatus = BorrowingStatus.overdue;
    } else {
      parsedStatus = BorrowingStatus.active;
    }

    return BorrowingModel(
      id: documentId.isNotEmpty ? documentId : (map['id'] ?? ''),
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      issuedBy: map['issuedBy'] ?? '',
      issueDate: _parseDateTime(map['issueDate'] ?? map['borrowDate']) ?? DateTime.now(),
      dueDate: _parseDateTime(map['dueDate']) ?? DateTime.now().add(const Duration(days: 14)),
      returnDate: _parseDateTime(map['returnDate']),
      status: parsedStatus,
      fineAmount: (map['fineAmount'] as num?)?.toDouble() ?? 0.0,
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

  BorrowingModel copyWith({
    DateTime? returnDate,
    BorrowingStatus? status,
    double? fineAmount,
    DateTime? updatedAt,
  }) {
    return BorrowingModel(
      id: id,
      bookId: bookId,
      bookTitle: bookTitle,
      memberId: memberId,
      memberName: memberName,
      issuedBy: issuedBy,
      issueDate: issueDate,
      dueDate: dueDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      fineAmount: fineAmount ?? this.fineAmount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
