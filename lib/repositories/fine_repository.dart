import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fine_model.dart';
import '../core/errors/firebase_exception_handler.dart';
import '../services/firebase/firestore_service.dart';

/// Repository mediating fine assessments, payments, and waiving in Firestore fines collection
class FineRepository {
  final FirestoreService _firestoreService;

  FineRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<FineModel>> get finesStream {
    return _firestoreService.finesCollection
        .orderBy('issuedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FineModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<FineModel>> getFines() async {
    try {
      final snapshot = await _firestoreService.finesCollection
          .orderBy('issuedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FineModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<List<FineModel>> getFinesByMember(String memberId) async {
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

  Future<List<FineModel>> getAllPendingFines() async {
    try {
      final snapshot = await _firestoreService.finesCollection
          .where('status', isEqualTo: 'PENDING')
          .get();

      return snapshot.docs
          .map((doc) => FineModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<FineModel?> getFineById(String id) async {
    try {
      final doc = await _firestoreService.getDocument(
        _firestoreService.finesCollection,
        id,
      );
      if (doc.exists && doc.data() != null) {
        return FineModel.fromMap(doc.data()!, id);
      }
      return null;
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> assessFine(FineModel fine) async {
    try {
      final docRef = fine.id.isNotEmpty
          ? _firestoreService.finesCollection.doc(fine.id)
          : _firestoreService.finesCollection.doc();

      final fineToSave = fine.id.isEmpty
          ? fine.copyWith(updatedAt: DateTime.now())
          : fine;

      await docRef.set(fineToSave.toMap());
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  /// Mark fine as paid and deduct from member's outstanding balance
  Future<void> payFine(String fineId) async {
    try {
      await _firestoreService.runTransaction((transaction) async {
        final fineRef = _firestoreService.finesCollection.doc(fineId);
        final fineSnap = await transaction.get(fineRef);

        if (!fineSnap.exists || fineSnap.data() == null) {
          throw Exception('Fine record not found.');
        }

        final fineData = fineSnap.data()!;
        final memberId = fineData['memberId'] ?? '';
        final amount = (fineData['amount'] as num?)?.toDouble() ?? 0.0;
        final memberName = fineData['memberName'] ?? 'Member';

        // 1. Update fine document
        transaction.update(fineRef, {
          'status': 'PAID',
          'paidAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // 2. Reduce member outstandingFine
        if (memberId.isNotEmpty) {
          final memberRef = _firestoreService.membersCollection.doc(memberId);
          final memberSnap = await transaction.get(memberRef);
          if (memberSnap.exists && memberSnap.data() != null) {
            final currentFine = (memberSnap.data()!['outstandingFine'] as num?)?.toDouble() ?? 0.0;
            transaction.update(memberRef, {
              'outstandingFine': (currentFine - amount).clamp(0.0, 99999.0),
              'updatedAt': Timestamp.now(),
            });
          }
        }

        // 3. Log activity
        final actRef = _firestoreService.activitiesCollection.doc();
        transaction.set(actRef, {
          'id': actRef.id,
          'type': 'FINE_PAID',
          'message': 'Received payment of \$${amount.toStringAsFixed(2)} for fine #$fineId from $memberName',
          'userId': memberId,
          'userName': memberName,
          'relatedId': fineId,
          'createdAt': Timestamp.now(),
        });
      });
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  /// Waive fine with administrator audit log
  Future<void> waiveFine(String fineId) async {
    try {
      await _firestoreService.runTransaction((transaction) async {
        final fineRef = _firestoreService.finesCollection.doc(fineId);
        final fineSnap = await transaction.get(fineRef);

        if (!fineSnap.exists || fineSnap.data() == null) {
          throw Exception('Fine record not found.');
        }

        final fineData = fineSnap.data()!;
        final memberId = fineData['memberId'] ?? '';
        final amount = (fineData['amount'] as num?)?.toDouble() ?? 0.0;
        final memberName = fineData['memberName'] ?? 'Member';

        // 1. Update fine document
        transaction.update(fineRef, {
          'status': 'WAIVED',
          'waivedAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // 2. Reduce member outstandingFine
        if (memberId.isNotEmpty) {
          final memberRef = _firestoreService.membersCollection.doc(memberId);
          final memberSnap = await transaction.get(memberRef);
          if (memberSnap.exists && memberSnap.data() != null) {
            final currentFine = (memberSnap.data()!['outstandingFine'] as num?)?.toDouble() ?? 0.0;
            transaction.update(memberRef, {
              'outstandingFine': (currentFine - amount).clamp(0.0, 99999.0),
              'updatedAt': Timestamp.now(),
            });
          }
        }

        // 3. Log activity
        final actRef = _firestoreService.activitiesCollection.doc();
        transaction.set(actRef, {
          'id': actRef.id,
          'type': 'FINE_WAIVED',
          'message': 'Waived fine of \$${amount.toStringAsFixed(2)} for $memberName by library administration',
          'userId': memberId,
          'userName': memberName,
          'relatedId': fineId,
          'createdAt': Timestamp.now(),
        });
      });
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }
}
