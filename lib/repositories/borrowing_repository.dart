import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/borrowing_model.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/firebase_exception_handler.dart';
import '../services/firebase/firestore_service.dart';

/// Repository mediating borrowing workflows with atomic Firestore transactions
class BorrowingRepository {
  final FirestoreService _firestoreService;

  BorrowingRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<BorrowingModel>> get borrowingsStream {
    return _firestoreService.borrowingsCollection
        .orderBy('issueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BorrowingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<BorrowingModel>> getActiveBorrowings() async {
    try {
      final snapshot = await _firestoreService.borrowingsCollection
          .where('status', isEqualTo: 'ACTIVE')
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => BorrowingModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<List<BorrowingModel>> getBorrowingHistory(String memberId) async {
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

  Future<List<BorrowingModel>> getBookBorrowingHistory(String bookId) async {
    try {
      final snapshot = await _firestoreService.borrowingsCollection
          .where('bookId', isEqualTo: bookId)
          .orderBy('issueDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BorrowingModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<List<BorrowingModel>> getOverdueBorrowings() async {
    try {
      final active = await getActiveBorrowings();
      return active.where((b) => b.isOverdue).toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<BorrowingModel?> getBorrowingDetails(String id) async {
    try {
      final doc = await _firestoreService.getDocument(
        _firestoreService.borrowingsCollection,
        id,
      );
      if (doc.exists && doc.data() != null) {
        return BorrowingModel.fromMap(doc.data()!, id);
      }
      return null;
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  /// ATOMIC TRANSACTION: Issue book with stock validation and audit tracking
  Future<String> issueBook({
    required String bookId,
    required String memberId,
    required String issuedBy,
    required DateTime dueDate,
  }) async {
    try {
      return await _firestoreService.runTransaction<String>((transaction) async {
        final bookRef = _firestoreService.booksCollection.doc(bookId);
        final memberRef = _firestoreService.membersCollection.doc(memberId);

        final bookSnap = await transaction.get(bookRef);
        if (!bookSnap.exists || bookSnap.data() == null) {
          throw Exception('Book not found in library catalog.');
        }

        final memberSnap = await transaction.get(memberRef);
        if (!memberSnap.exists || memberSnap.data() == null) {
          throw Exception('Member record not found.');
        }

        final bookData = bookSnap.data()!;
        final memberData = memberSnap.data()!;

        // 1. Check member status
        final memberStatus = (memberData['status'] ?? 'active').toString().toLowerCase();
        if (memberStatus != 'active') {
          throw Exception('Member account is $memberStatus and cannot borrow books.');
        }

        // 2. Check book available copies
        final availableCopies = (bookData['availableCopies'] as num?)?.toInt() ?? 0;
        if (availableCopies <= 0) {
          throw Exception('No copies of "${bookData['title']}" are currently available.');
        }

        // 3. Decrement availableCopies
        final newAvailable = availableCopies - 1;
        transaction.update(bookRef, {
          'availableCopies': newAvailable,
          'status': newAvailable > 0 ? 'available' : 'borrowed',
          'updatedAt': Timestamp.now(),
        });

        // 4. Update member's borrowed count
        final currentBorrowed = (memberData['currentBorrowed'] as num?)?.toInt() ?? 0;
        final totalBorrowed = (memberData['totalBorrowed'] as num?)?.toInt() ?? 0;
        transaction.update(memberRef, {
          'currentBorrowed': currentBorrowed + 1,
          'totalBorrowed': totalBorrowed + 1,
          'updatedAt': Timestamp.now(),
        });

        // 5. Create borrowing document
        final borrowingRef = _firestoreService.borrowingsCollection.doc();
        final borrowingId = borrowingRef.id;
        final bookTitle = bookData['title'] ?? 'Untitled Book';
        final memberName = memberData['fullName'] ?? memberData['name'] ?? 'Member';

        transaction.set(borrowingRef, {
          'id': borrowingId,
          'bookId': bookId,
          'bookTitle': bookTitle,
          'memberId': memberId,
          'memberName': memberName,
          'issuedBy': issuedBy,
          'issueDate': Timestamp.now(),
          'dueDate': Timestamp.fromDate(dueDate),
          'returnDate': null,
          'status': 'ACTIVE',
          'fineAmount': 0.0,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // 6. Create activity log
        final activityRef = _firestoreService.activitiesCollection.doc();
        transaction.set(activityRef, {
          'id': activityRef.id,
          'type': 'BOOK_ISSUED',
          'message': 'Issued "$bookTitle" to $memberName (Due: ${dueDate.toIso8601String().split('T').first})',
          'userId': issuedBy,
          'userName': issuedBy,
          'relatedId': borrowingId,
          'createdAt': Timestamp.now(),
        });

        // 7. Create notification for member
        final notifRef = _firestoreService.notificationsCollection.doc();
        transaction.set(notifRef, {
          'id': notifRef.id,
          'userId': memberData['userId'] ?? memberId,
          'title': 'Book Issued Successfully',
          'message': 'You have borrowed "$bookTitle". Due date is ${dueDate.toIso8601String().split('T').first}.',
          'type': 'due_soon',
          'isRead': false,
          'relatedId': borrowingId,
          'createdAt': Timestamp.now(),
        });

        return borrowingId;
      });
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  /// ATOMIC TRANSACTION: Return book with copy restoration, fine assessment, and notification
  Future<Map<String, dynamic>> returnBook({
    required String borrowingId,
    required DateTime returnDate,
    double dailyFineRate = CoreConstants.fineRatePerDay,
  }) async {
    try {
      return await _firestoreService.runTransaction<Map<String, dynamic>>((transaction) async {
        final borrowingRef = _firestoreService.borrowingsCollection.doc(borrowingId);
        final borrowingSnap = await transaction.get(borrowingRef);

        if (!borrowingSnap.exists || borrowingSnap.data() == null) {
          throw Exception('Borrowing record #$borrowingId not found.');
        }

        final bData = borrowingSnap.data()!;
        if ((bData['status'] ?? '').toString().toUpperCase() == 'RETURNED') {
          throw Exception('This borrowing loan has already been settled and returned.');
        }

        final bookId = bData['bookId'] ?? '';
        final memberId = bData['memberId'] ?? '';
        final bookTitle = bData['bookTitle'] ?? 'Book';
        final memberName = bData['memberName'] ?? 'Member';

        DateTime dueDate;
        final rawDueDate = bData['dueDate'];
        if (rawDueDate is Timestamp) {
          dueDate = rawDueDate.toDate();
        } else if (rawDueDate is String) {
          dueDate = DateTime.tryParse(rawDueDate) ?? returnDate;
        } else {
          dueDate = returnDate;
        }

        // Calculate overdue days and fine
        int overdueDays = 0;
        double fineAmount = 0.0;
        if (returnDate.isAfter(dueDate)) {
          overdueDays = returnDate.difference(dueDate).inDays;
          if (overdueDays > 0) {
            fineAmount = overdueDays * dailyFineRate;
          }
        }

        // 1. Update borrowing record
        transaction.update(borrowingRef, {
          'returnDate': Timestamp.fromDate(returnDate),
          'status': 'RETURNED',
          'fineAmount': fineAmount,
          'updatedAt': Timestamp.now(),
        });

        // 2. Restore book copy
        final bookRef = _firestoreService.booksCollection.doc(bookId);
        final bookSnap = await transaction.get(bookRef);
        if (bookSnap.exists && bookSnap.data() != null) {
          final total = (bookSnap.data()!['totalCopies'] as num?)?.toInt() ?? 1;
          final currentAvailable = (bookSnap.data()!['availableCopies'] as num?)?.toInt() ?? 0;
          final newAvailable = (currentAvailable + 1).clamp(0, total);

          transaction.update(bookRef, {
            'availableCopies': newAvailable,
            'status': 'available',
            'updatedAt': Timestamp.now(),
          });
        }

        // 3. Decrement member currentBorrowed and add to outstandingFine if fine incurred
        final memberRef = _firestoreService.membersCollection.doc(memberId);
        final memberSnap = await transaction.get(memberRef);
        String? memberUserId;
        if (memberSnap.exists && memberSnap.data() != null) {
          final mData = memberSnap.data()!;
          memberUserId = mData['userId'];
          final currentBorrowed = (mData['currentBorrowed'] as num?)?.toInt() ?? 1;
          final currentFine = (mData['outstandingFine'] as num?)?.toDouble() ?? 0.0;

          transaction.update(memberRef, {
            'currentBorrowed': (currentBorrowed - 1).clamp(0, 999),
            if (fineAmount > 0) 'outstandingFine': currentFine + fineAmount,
            'updatedAt': Timestamp.now(),
          });
        }

        // 4. Create fine record if overdue
        String? fineId;
        if (fineAmount > 0) {
          final fineRef = _firestoreService.finesCollection.doc();
          fineId = fineRef.id;

          transaction.set(fineRef, {
            'id': fineId,
            'borrowingId': borrowingId,
            'memberId': memberId,
            'memberName': memberName,
            'bookId': bookId,
            'amount': fineAmount,
            'overdueDays': overdueDays,
            'status': 'PENDING',
            'issuedAt': Timestamp.fromDate(returnDate),
            'paidAt': null,
            'waivedAt': null,
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });

          // Log FINE_CREATED activity
          final fineActRef = _firestoreService.activitiesCollection.doc();
          transaction.set(fineActRef, {
            'id': fineActRef.id,
            'type': 'FINE_CREATED',
            'message': 'Assessed overdue fine of \$${fineAmount.toStringAsFixed(2)} ($overdueDays days) for $memberName',
            'userId': memberId,
            'userName': memberName,
            'relatedId': fineId,
            'createdAt': Timestamp.now(),
          });
        }

        // 5. Create activity record for return
        final returnActRef = _firestoreService.activitiesCollection.doc();
        transaction.set(returnActRef, {
          'id': returnActRef.id,
          'type': 'BOOK_RETURNED',
          'message': 'Returned "$bookTitle" by $memberName${fineAmount > 0 ? ' (Fee: \$${fineAmount.toStringAsFixed(2)})' : ''}',
          'userId': memberId,
          'userName': memberName,
          'relatedId': borrowingId,
          'createdAt': Timestamp.now(),
        });

        // 6. Create notification
        final notifRef = _firestoreService.notificationsCollection.doc();
        transaction.set(notifRef, {
          'id': notifRef.id,
          'userId': memberUserId ?? memberId,
          'title': fineAmount > 0 ? 'Book Returned with Overdue Fee' : 'Book Returned Successfully',
          'message': fineAmount > 0
              ? '"$bookTitle" has been returned. An overdue fee of \$${fineAmount.toStringAsFixed(2)} has been assessed.'
              : '"$bookTitle" was successfully returned. Thank you for returning on time!',
          'type': fineAmount > 0 ? 'fine' : 'return',
          'isRead': false,
          'relatedId': borrowingId,
          'createdAt': Timestamp.now(),
        });

        return {
          'borrowingId': borrowingId,
          'fineAmount': fineAmount,
          'overdueDays': overdueDays,
          'fineId': fineId,
        };
      });
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }
}
