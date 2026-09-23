import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/enums/user_role.dart';
import '../../models/user_model.dart';
import '../firebase/firebase_auth_service.dart';
import '../firebase/firestore_service.dart';

/// Tracks current authenticated user session, role state, and Firebase Auth state changes
class AuthStateService {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  UserModel? _currentUser;
  StreamSubscription<User?>? _authSubscription;

  AuthStateService({
    FirebaseAuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? FirebaseAuthService(),
        _firestoreService = firestoreService ?? FirestoreService() {
    _initListener();
  }

  void _initListener() {
    _authSubscription = _authService.authStateChanges.listen((user) async {
      if (user != null) {
        try {
          final doc = await _firestoreService.getDocument(
            _firestoreService.usersCollection,
            user.uid,
          );
          if (doc.exists && doc.data() != null) {
            _currentUser = UserModel.fromMap(doc.data()!, user.uid);
          }
        } catch (_) {
          // Ignore transient network errors
        }
      } else {
        _currentUser = null;
      }
    });
  }

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null || _authService.currentUser != null;
  UserRole get currentRole => _currentUser?.role ?? UserRole.member;

  void updateUser(UserModel? user) {
    _currentUser = user;
  }

  void dispose() {
    _authSubscription?.cancel();
  }
}
