import 'package:flutter/material.dart';
import '../models/fine_model.dart';
import '../core/enums/fine_status.dart';
import '../core/mock/mock_data.dart';
import '../repositories/fine_repository.dart';

/// Fine tracking, payment, and dues management state provider backed by FineRepository & Cloud Firestore
class FineProvider extends ChangeNotifier {
  final FineRepository _fineRepository;

  List<FineModel> _fines = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _filter = 'All'; // 'All', 'Unpaid', 'Paid', 'Waived'
  String _searchQuery = '';

  FineProvider({FineRepository? fineRepository})
      : _fineRepository = fineRepository ?? FineRepository() {
    _loadFines();
  }

  List<FineModel> get allFines => _fines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filter => _filter;
  String get searchQuery => _searchQuery;

  Future<void> _loadFines() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cloudFines = await _fineRepository.getFines();
      if (cloudFines.isNotEmpty) {
        _fines = cloudFines;
      } else {
        _fines = MockData.getInitialFines();
      }
    } catch (_) {
      _fines = MockData.getInitialFines();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadFines();
  }

  List<FineModel> get filteredFines {
    return _fines.where((f) {
      final matchesSearch = _searchQuery.isEmpty ||
          f.memberName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.borrowingId.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesStatus = true;
      if (_filter == 'Unpaid') {
        matchesStatus = f.status == FineStatus.unpaid;
      } else if (_filter == 'Paid') {
        matchesStatus = f.status == FineStatus.paid;
      } else if (_filter == 'Waived') {
        matchesStatus = f.status == FineStatus.waived;
      }

      return matchesSearch && matchesStatus;
    }).toList();
  }

  double get totalOutstandingFines => _fines
      .where((f) => f.status == FineStatus.unpaid)
      .fold(0.0, (sum, f) => sum + f.amount);

  double get totalCollectedFines => _fines
      .where((f) => f.status == FineStatus.paid)
      .fold(0.0, (sum, f) => sum + f.amount);

  int get unpaidFinesCount =>
      _fines.where((f) => f.status == FineStatus.unpaid).length;

  int get paidFinesCount =>
      _fines.where((f) => f.status == FineStatus.paid).length;

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<FineModel> getFinesByMember(String memberId) {
    return _fines.where((f) => f.memberId == memberId).toList();
  }

  Future<void> addFine({
    required String borrowingId,
    required String memberId,
    required String memberName,
    required double amount,
    required int daysOverdue,
  }) async {
    final fine = FineModel(
      id: 'fn_${DateTime.now().millisecondsSinceEpoch}',
      borrowingId: borrowingId,
      memberId: memberId,
      memberName: memberName,
      amount: amount,
      overdueDays: daysOverdue,
      status: FineStatus.unpaid,
      issuedAt: DateTime.now(),
    );
    _fines.insert(0, fine);
    notifyListeners();

    try {
      await _fineRepository.assessFine(fine);
    } catch (_) {}
  }

  Future<void> payFine(String id) async {
    final index = _fines.indexWhere((f) => f.id == id);
    if (index != -1) {
      final current = _fines[index];
      _fines[index] = current.copyWith(
        status: FineStatus.paid,
        paidAt: DateTime.now(),
      );
      notifyListeners();

      try {
        await _fineRepository.payFine(id);
      } catch (_) {}
    }
  }

  Future<void> waiveFine(String id) async {
    final index = _fines.indexWhere((f) => f.id == id);
    if (index != -1) {
      final current = _fines[index];
      _fines[index] = current.copyWith(
        status: FineStatus.waived,
        waivedAt: DateTime.now(),
      );
      notifyListeners();

      try {
        await _fineRepository.waiveFine(id);
      } catch (_) {}
    }
  }
}
