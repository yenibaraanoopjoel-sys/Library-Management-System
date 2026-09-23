import '../models/user_model.dart';
import '../core/enums/user_role.dart';
import '../core/errors/firebase_exception_handler.dart';
import '../services/firebase/firestore_service.dart';

/// Repository mediating user profile and role management in Firestore users collection
class UserRepository {
  final FirestoreService _firestoreService;

  UserRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<UserModel?> getUserById(String id) async {
    try {
      final doc = await _firestoreService.getDocument(
        _firestoreService.usersCollection,
        id,
      );
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, id);
      }
      return null;
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestoreService.setDocument(
        _firestoreService.usersCollection,
        user.uid,
        user.toMap(),
      );
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> updateProfile({
    required String uid,
    required String fullName,
    String? phone,
    String? profileImage,
  }) async {
    try {
      final data = <String, dynamic>{
        'fullName': fullName,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      if (phone != null) data['phone'] = phone;
      if (profileImage != null) data['profileImage'] = profileImage;

      await _firestoreService.updateDocument(
        _firestoreService.usersCollection,
        uid,
        data,
      );
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> updateActiveStatus(String uid, bool isActive) async {
    try {
      await _firestoreService.updateDocument(
        _firestoreService.usersCollection,
        uid,
        {'isActive': isActive, 'updatedAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestoreService.usersCollection.get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      final snapshot = await _firestoreService.usersCollection
          .where('role', isEqualTo: role.name)
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _firestoreService.deleteDocument(
        _firestoreService.usersCollection,
        id,
      );
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }
}
