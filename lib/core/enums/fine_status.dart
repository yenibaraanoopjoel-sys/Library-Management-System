/// Fine payment and assessment statuses
enum FineStatus {
  unpaid,
  paid,
  waived;

  String get displayName {
    switch (this) {
      case FineStatus.unpaid:
        return 'Unpaid';
      case FineStatus.paid:
        return 'Paid';
      case FineStatus.waived:
        return 'Waived';
    }
  }

  static FineStatus fromString(String status) {
    return FineStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => FineStatus.unpaid,
    );
  }
}
