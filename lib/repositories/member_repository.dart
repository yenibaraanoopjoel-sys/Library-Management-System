import '../models/member_model.dart';
import '../models/borrowing_model.dart';
import '../models/fine_model.dart';
import '../core/errors/firebase_exception_handler.dart';
import '../services/firebase/firestore_service.dart';

/// Repository mediating library members data access in Firestore members collection
class MemberRepository {
  final FirestoreService _firestoreService;

  MemberRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<MemberModel>> get membersStream {
    return _firestoreService.membersCollection
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MemberModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<MemberModel>> getMembers() async {
    try {
      final snapshot = await _firestoreService.membersCollection.get();
      return snapshot.docs
          .map((doc) => MemberModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<MemberModel?> getMemberById(String id) async {
    try {
      final doc = await _firestoreService.getDocument(
        _firestoreService.membersCollection,
        id,
      );
      if (doc.exists && doc.data() != null) {
        return MemberModel.fromMap(doc.data()!, id);
      }
      return null;
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<MemberModel?> getMemberByUserId(String userId) async {
    try {
      final snapshot = await _firestoreService.membersCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return MemberModel.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> addMember(MemberModel member) async {
    try {
      final docRef = member.id.isNotEmpty
          ? _firestoreService.membersCollection.doc(member.id)
          : _firestoreService.membersCollection.doc();

      final memberToSave = member.id.isEmpty
          ? member.copyWith(
              updatedAt: DateTime.now(),
            )
          : member;

      await docRef.set(memberToSave.toMap());
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> updateMember(MemberModel member) async {
    try {
      await _firestoreService.setDocument(
        _firestoreService.membersCollection,
        member.id,
        member.toMap(),
      );
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> deleteMember(String id) async {
    try {
      // Soft delete: mark as inactive/suspended or remove
      await _firestoreService.updateDocument(
        _firestoreService.membersCollection,
        id,
        {'status': 'suspended', 'updatedAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<List<MemberModel>> searchMembers(String query) async {
    try {
      final cleanQuery = query.trim().toLowerCase();
      if (cleanQuery.isEmpty) return await getMembers();

      final all = await getMembers();
      return all.where((m) =>
          m.fullName.toLowerCase().contains(cleanQuery) ||
          m.email.toLowerCase().contains(cleanQuery) ||
          m.phone.toLowerCase().contains(cleanQuery) ||
          m.memberId.toLowerCase().contains(cleanQuery)).toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<List<BorrowingModel>> getMemberBorrowingHistory(String memberId) async {
    try {
      final snapshot = await _firestoreService.borrowingsCollection
          .where('memberId', isEqualTo: memberId)
          .orderBy('issueDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BorrowingModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<List<FineModel>> getMemberFines(String memberId) async {
    try {
      final snapshot = await _firestoreService.finesCollection
          .where('memberId', isEqualTo: memberId)
          .orderBy('issuedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FineModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }
}
