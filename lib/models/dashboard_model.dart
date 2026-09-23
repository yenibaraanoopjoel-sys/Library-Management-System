/// Aggregated metrics and statistics for dashboard views
class DashboardModel {
  final int totalBooks;
  final int availableBooks;
  final int borrowedBooks;
  final int totalMembers;
  final int activeMembers;
  final int overdueBorrowings;
  final double totalFinesPending;
  final double totalFinesCollected;

  const DashboardModel({
    this.totalBooks = 0,
    this.availableBooks = 0,
    this.borrowedBooks = 0,
    this.totalMembers = 0,
    this.activeMembers = 0,
    this.overdueBorrowings = 0,
    this.totalFinesPending = 0.0,
    this.totalFinesCollected = 0.0,
  });

  factory DashboardModel.fromMap(Map<String, dynamic> map) {
    return DashboardModel(
      totalBooks: map['totalBooks'] ?? 0,
      availableBooks: map['availableBooks'] ?? 0,
      borrowedBooks: map['borrowedBooks'] ?? 0,
      totalMembers: map['totalMembers'] ?? 0,
      activeMembers: map['activeMembers'] ?? 0,
      overdueBorrowings: map['overdueBorrowings'] ?? 0,
      totalFinesPending: (map['totalFinesPending'] as num?)?.toDouble() ?? 0.0,
      totalFinesCollected: (map['totalFinesCollected'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
