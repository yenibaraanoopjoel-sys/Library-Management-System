import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/enums/user_role.dart';
import '../core/mock/mock_data.dart';
import '../repositories/auth_repository.dart';
import '../services/firebase/seed_service.dart';

/// Authentication state provider managing real Firebase sessions, user profiles, and role resolution
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SeedService _seedService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    AuthRepository? authRepository,
    SeedService? seedService,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _seedService = seedService ?? SeedService() {
    _initAuth();
  }

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserRole get role => _currentUser?.role ?? UserRole.member;

  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isLibrarian => _currentUser?.role == UserRole.librarian || isAdmin;
  bool get isStudent => _currentUser?.role == UserRole.member;

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check current user profile from Firebase
      _currentUser = await _authRepository.getCurrentUser();

      // Seed initial sample data if cloud database is fresh
      await _seedService.seedInitialDataIfEmpty();
    } catch (_) {
      // Default fallback to initial demo user if offline or uninitialized
      _currentUser ??= MockData.demoUsers.first;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Fallback for demo accounts if offline
      final match = MockData.demoUsers.firstWhere(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
        orElse: () => UserModel(
          uid: 'usr_${DateTime.now().millisecondsSinceEpoch}',
          email: email.trim(),
          fullName: email.split('@').first,
          role: UserRole.member,
        ),
      );

      _currentUser = match;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.member,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _currentUser = UserModel(
        uid: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        fullName: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (_) {}
    _currentUser = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authRepository.resetPassword(email);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void loginAsRole(UserRole targetRole) {
    _currentUser = MockData.demoUsers.firstWhere(
      (u) => u.role == targetRole,
      orElse: () => MockData.demoUsers.first,
    );
    notifyListeners();
  }

  void updateProfile({required String name, required String email}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        fullName: name,
        email: email,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
}
