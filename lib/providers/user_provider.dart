import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../core/mock/mock_data.dart';

/// User profile and account management state provider backed by UserRepository & Firestore
class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserProvider({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository() {
    loadUsers();
  }

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cloudUsers = await _userRepository.getAllUsers();
      if (cloudUsers.isNotEmpty) {
        _users = cloudUsers;
      } else {
        _users = MockData.demoUsers;
      }
    } catch (_) {
      _users = MockData.demoUsers;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(UserModel user) async {
    final index = _users.indexWhere((u) => u.uid == user.uid);
    if (index != -1) {
      _users[index] = user;
      notifyListeners();

      try {
        await _userRepository.updateUser(user);
      } catch (_) {}
    }
  }

  Future<void> updateActiveStatus(String uid, bool isActive) async {
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isActive: isActive);
      notifyListeners();

      try {
        await _userRepository.updateActiveStatus(uid, isActive);
      } catch (_) {}
    }
  }

  Future<void> deleteUser(String id) async {
    _users.removeWhere((u) => u.uid == id);
    notifyListeners();

    try {
      await _userRepository.deleteUser(id);
    } catch (_) {}
  }
}
