/// Book availability statuses
enum BookStatus {
  available,
  borrowed,
  reserved,
  lost,
  maintenance;

  String get displayName {
    switch (this) {
      case BookStatus.available:
        return 'Available';
      case BookStatus.borrowed:
        return 'Borrowed';
      case BookStatus.reserved:
        return 'Reserved';
      case BookStatus.lost:
        return 'Lost';
      case BookStatus.maintenance:
        return 'Under Maintenance';
    }
  }

  static BookStatus fromString(String status) {
    return BookStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => BookStatus.available,
    );
  }
}
