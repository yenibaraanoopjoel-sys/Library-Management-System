import 'package:flutter/material.dart';
import '../models/member_model.dart';
import '../core/mock/mock_data.dart';
import '../repositories/member_repository.dart';

/// Member management state provider backed by MemberRepository & Cloud Firestore
class MemberProvider extends ChangeNotifier {
  final MemberRepository _memberRepository;

  List<MemberModel> _members = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'active', 'suspended', 'expired'

  MemberProvider({MemberRepository? memberRepository})
      : _memberRepository = memberRepository ?? MemberRepository() {
    _loadMembers();
  }

  List<MemberModel> get allMembers => _members;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  Future<void> _loadMembers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cloudMembers = await _memberRepository.getMembers();
      if (cloudMembers.isNotEmpty) {
        _members = cloudMembers;
      } else {
        _members = MockData.getInitialMembers();
      }
    } catch (_) {
      _members = MockData.getInitialMembers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadMembers();
  }

  List<MemberModel> get filteredMembers {
    return _members.where((m) {
      final matchesSearch = _searchQuery.isEmpty ||
          m.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.phone.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.memberId.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _statusFilter == 'All' ||
          m.status.toLowerCase() == _statusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  MemberModel? getMemberById(String id) {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addMember(MemberModel member) async {
    _members.insert(0, member);
    notifyListeners();

    try {
      await _memberRepository.addMember(member);
    } catch (_) {}
  }

  Future<void> updateMember(MemberModel member) async {
    final index = _members.indexWhere((m) => m.id == member.id);
    if (index != -1) {
      _members[index] = member;
      notifyListeners();

      try {
        await _memberRepository.updateMember(member);
      } catch (_) {}
    }
  }

  Future<void> deleteMember(String id) async {
    final index = _members.indexWhere((m) => m.id == id);
    if (index != -1) {
      _members[index] = _members[index].copyWith(status: 'suspended');
      notifyListeners();

      try {
        await _memberRepository.deleteMember(id);
      } catch (_) {}
    }
  }

  void incrementCurrentBorrowed(String memberId) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final cur = _members[index];
      _members[index] = cur.copyWith(
        currentBorrowed: cur.currentBorrowed + 1,
        totalBorrowed: cur.totalBorrowed + 1,
      );
      notifyListeners();
    }
  }

  void decrementCurrentBorrowed(String memberId, {double fineAdded = 0.0}) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final cur = _members[index];
      _members[index] = cur.copyWith(
        currentBorrowed: (cur.currentBorrowed - 1).clamp(0, 999),
        outstandingFine: cur.outstandingFine + fineAdded,
      );
      notifyListeners();
    }
  }
}
