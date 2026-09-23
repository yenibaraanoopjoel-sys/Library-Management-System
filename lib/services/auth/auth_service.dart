import '../../models/user_model.dart';
import '../../core/enums/user_role.dart';
import '../firebase/firebase_auth_service.dart';
import '../firebase/firestore_service.dart';

/// Concrete implementation of authentication service backed by Firebase Auth & Firestore
class AuthService {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthService({
    FirebaseAuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? FirebaseAuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final userDoc = await _firestoreService.getDocument(
      _firestoreService.usersCollection,
      uid,
    );

    if (userDoc.exists && userDoc.data() != null) {
      return UserModel.fromMap(userDoc.data()!, uid);
    }

    // Fallback: If document does not exist yet, create it
    final newUser = UserModel(
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
      newUser.toMap(),
    );

    return newUser;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.member,
    String phone = '',
  }) async {
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
      phone: phone,
      role: role,
      memberId: memberId,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to users/{uid}
    await _firestoreService.setDocument(
      _firestoreService.usersCollection,
      uid,
      user.toMap(),
    );

    // If student/member, create corresponding members document
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
          'phone': phone,
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
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final user = _authService.currentUser;
    if (user == null) return null;

    final doc = await _firestoreService.getDocument(
      _firestoreService.usersCollection,
      user.uid,
    );

    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, user.uid);
    }
    return null;
  }
}
