/// Borrowing lifecycle statuses
enum BorrowingStatus {
  active,
  returned,
  overdue;

  String get displayName {
    switch (this) {
      case BorrowingStatus.active:
        return 'Active';
      case BorrowingStatus.returned:
        return 'Returned';
      case BorrowingStatus.overdue:
        return 'Overdue';
    }
  }

  static BorrowingStatus fromString(String status) {
    return BorrowingStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => BorrowingStatus.active,
    );
  }
}
