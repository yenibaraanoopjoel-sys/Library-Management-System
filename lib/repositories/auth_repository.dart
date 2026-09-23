import 'dart:async';
import '../models/user_model.dart';
import '../core/enums/user_role.dart';
import '../core/errors/firebase_exception_handler.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../services/firebase/firestore_service.dart';

/// Repository mediating authentication data access with Firebase Auth and Firestore
class AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    FirebaseAuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? FirebaseAuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  Stream<UserModel?> get userStream {
    return _authService.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      try {
        final doc = await _firestoreService.getDocument(
          _firestoreService.usersCollection,
          user.uid,
        );
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!, user.uid);
        }
      } catch (_) {}
      return UserModel(
        uid: user.uid,
        fullName: user.displayName ?? user.email?.split('@').first ?? 'User',
        email: user.email ?? '',
        role: UserRole.member,
      );
    });
  }

  Future<UserModel> login({required String email, required String password}) async {
    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final doc = await _firestoreService.getDocument(
        _firestoreService.usersCollection,
        uid,
      );

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }

      // If document doesn't exist yet, construct and persist initial document
      final user = UserModel(
        uid: uid,
        fullName: credential.user?.displayName ?? email.split('@').first,
        email: email,
        role: UserRole.member,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.setDocument(
        _firestoreService.usersCollection,
        uid,
        user.toMap(),
      );

      return user;
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.member,
  }) async {
    try {
      final credential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      await _authService.updateDisplayName(name);

      final memberId = role == UserRole.member ? 'MEM-${uid.substring(0, 6).toUpperCase()}' : null;

      final user = UserModel(
        uid: uid,
        fullName: name,
        email: email,
        role: role,
        memberId: memberId,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 1. Create users/{uid}
      await _firestoreService.setDocument(
        _firestoreService.usersCollection,
        uid,
        user.toMap(),
      );

      // 2. If student/member, create members/{memberId}
      if (role == UserRole.member && memberId != null) {
        await _firestoreService.setDocument(
          _firestoreService.membersCollection,
          memberId,
          {
            'id': memberId,
            'userId': uid,
            'memberId': memberId,
            'fullName': name,
            'email': email,
            'phone': '',
            'address': '',
            'profileImage': null,
            'joinedAt': DateTime.now().toIso8601String(),
            'status': 'active',
            'totalBorrowed': 0,
            'currentBorrowed': 0,
            'outstandingFine': 0.0,
            'maxBooksAllowed': 3,
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );
      }

      return user;
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _authService.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestoreService.getDocument(
        _firestoreService.usersCollection,
        user.uid,
      );
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, user.uid);
      }
    } catch (_) {}

    return UserModel(
      uid: user.uid,
      fullName: user.displayName ?? user.email?.split('@').first ?? 'User',
      email: user.email ?? '',
      role: UserRole.member,
    );
  }
}
