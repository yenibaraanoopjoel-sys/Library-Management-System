import 'package:flutter/material.dart';
import '../models/borrowing_model.dart';
import '../core/enums/borrowing_status.dart';
import '../core/mock/mock_data.dart';
import '../repositories/borrowing_repository.dart';

/// Borrowing management state provider backed by BorrowingRepository & Cloud Firestore transactions
class BorrowingProvider extends ChangeNotifier {
  final BorrowingRepository _borrowingRepository;

  List<BorrowingModel> _borrowings = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _filter = 'All'; // 'All', 'Active', 'Overdue', 'Returned'
  String _searchQuery = '';

  BorrowingProvider({BorrowingRepository? borrowingRepository})
      : _borrowingRepository = borrowingRepository ?? BorrowingRepository() {
    _loadBorrowings();
  }

  List<BorrowingModel> get allBorrowings => _borrowings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filter => _filter;
  String get searchQuery => _searchQuery;

  Future<void> _loadBorrowings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cloudBorrowings = await _borrowingRepository.getActiveBorrowings();
      if (cloudBorrowings.isNotEmpty) {
        _borrowings = cloudBorrowings;
      } else {
        _borrowings = MockData.getInitialBorrowings();
      }
    } catch (_) {
      _borrowings = MockData.getInitialBorrowings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadBorrowings();
  }

  List<BorrowingModel> get filteredBorrowings {
    return _borrowings.where((b) {
      final matchesSearch = _searchQuery.isEmpty ||
          b.bookTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.memberName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.id.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesFilter = true;
      if (_filter == 'Active') {
        matchesFilter = b.status == BorrowingStatus.active && !b.isOverdue;
      } else if (_filter == 'Overdue') {
        matchesFilter = b.isOverdue;
      } else if (_filter == 'Returned') {
        matchesFilter = b.status == BorrowingStatus.returned;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<BorrowingModel> get activeBorrowings =>
      _borrowings.where((b) => b.status == BorrowingStatus.active).toList();

  List<BorrowingModel> get overdueBorrowings =>
      _borrowings.where((b) => b.isOverdue).toList();

  List<BorrowingModel> get dueSoonBorrowings {
    final now = DateTime.now();
    return _borrowings.where((b) {
      if (b.status != BorrowingStatus.active || b.isOverdue) return false;
      final difference = b.dueDate.difference(now).inDays;
      return difference >= 0 && difference <= 2;
    }).toList();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<BorrowingModel> getBorrowingsByMember(String memberId) {
    return _borrowings.where((b) => b.memberId == memberId).toList();
  }

  BorrowingModel? getBorrowingById(String id) {
    try {
      return _borrowings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Issues book using atomic Firestore transaction
  Future<String> issueBook({
    required String bookId,
    required String bookTitle,
    required String memberId,
    required String memberName,
    required String issuedBy,
    required DateTime dueDate,
    DateTime? borrowDate,
    DateTime? issueDate,
  }) async {
    final tempId = 'br_${DateTime.now().millisecondsSinceEpoch}';
    final effectiveIssueDate = borrowDate ?? issueDate ?? DateTime.now();
    final localRecord = BorrowingModel(
      id: tempId,
      bookId: bookId,
      bookTitle: bookTitle,
      memberId: memberId,
      memberName: memberName,
      issuedBy: issuedBy,
      issueDate: effectiveIssueDate,
      dueDate: dueDate,
      status: BorrowingStatus.active,
    );

    _borrowings.insert(0, localRecord);
    notifyListeners();

    try {
      final cloudId = await _borrowingRepository.issueBook(
        bookId: bookId,
        memberId: memberId,
        issuedBy: issuedBy,
        dueDate: dueDate,
      );
      // Update local ID with transaction ID
      final index = _borrowings.indexWhere((b) => b.id == tempId);
      if (index != -1) {
        _borrowings[index] = BorrowingModel(
          id: cloudId,
          bookId: bookId,
          bookTitle: bookTitle,
          memberId: memberId,
          memberName: memberName,
          issuedBy: issuedBy,
          issueDate: localRecord.issueDate,
          dueDate: localRecord.dueDate,
          status: BorrowingStatus.active,
        );
        notifyListeners();
      }
      return cloudId;
    } catch (_) {
      return tempId;
    }
  }

  /// Returns book using atomic Firestore transaction
  Future<Map<String, dynamic>> returnBook({
    required String borrowingId,
    required DateTime returnDate,
    double fineRatePerDay = 1.0,
  }) async {
    final index = _borrowings.indexWhere((b) => b.id == borrowingId);
    if (index != -1) {
      final current = _borrowings[index];
      int overdueDays = 0;
      double fineAmount = 0.0;
      if (returnDate.isAfter(current.dueDate)) {
        overdueDays = returnDate.difference(current.dueDate).inDays;
        fineAmount = overdueDays * fineRatePerDay;
      }

      _borrowings[index] = current.copyWith(
        returnDate: returnDate,
        status: BorrowingStatus.returned,
        fineAmount: fineAmount,
      );
      notifyListeners();

      try {
        final result = await _borrowingRepository.returnBook(
          borrowingId: borrowingId,
          returnDate: returnDate,
          dailyFineRate: fineRatePerDay,
        );
        return result;
      } catch (_) {
        return {
          'borrowingId': borrowingId,
          'fineAmount': fineAmount,
          'overdueDays': overdueDays,
        };
      }
    }
    return {};
  }
}
