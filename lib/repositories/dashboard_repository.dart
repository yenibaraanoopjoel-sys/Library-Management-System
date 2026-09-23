import '../models/dashboard_model.dart';
import '../models/activity_model.dart';
import '../models/borrowing_model.dart';
import '../core/errors/firebase_exception_handler.dart';
import '../services/firebase/firestore_service.dart';

/// Repository computing real dashboard metrics and aggregating circulation telemetry from Firestore
class DashboardRepository {
  final FirestoreService _firestoreService;

  DashboardRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<DashboardModel> getAdminDashboardMetrics() async {
    try {
      // 1. Books stats
      final booksSnap = await _firestoreService.booksCollection.get();
      int totalBooks = booksSnap.docs.length;
      int availableCopiesSum = 0;
      int totalCopiesSum = 0;

      for (var doc in booksSnap.docs) {
        final d = doc.data();
        final tot = (d['totalCopies'] as num?)?.toInt() ?? 1;
        final avail = (d['availableCopies'] as num?)?.toInt() ?? tot;
        totalCopiesSum += tot;
        availableCopiesSum += avail;
      }
      int borrowedCopies = totalCopiesSum - availableCopiesSum;

      // 2. Members stats
      final membersSnap = await _firestoreService.membersCollection.get();
      int totalMembers = membersSnap.docs.length;
      int activeMembers = membersSnap.docs.where((d) => (d.data()['status'] ?? 'active') == 'active').length;

      // 3. Borrowing stats
      final activeBorrowingsSnap = await _firestoreService.borrowingsCollection
          .where('status', isEqualTo: 'ACTIVE')
          .get();

      int overdueCount = 0;
      for (var doc in activeBorrowingsSnap.docs) {
        final b = BorrowingModel.fromMap(doc.data(), doc.id);
        if (b.isOverdue) overdueCount++;
      }

      // 4. Fines stats
      final finesSnap = await _firestoreService.finesCollection.get();
      double totalPending = 0.0;
      double totalCollected = 0.0;

      for (var doc in finesSnap.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final status = (data['status'] ?? '').toString().toUpperCase();
        if (status == 'PAID') {
          totalCollected += amount;
        } else if (status == 'PENDING' || status == 'UNPAID') {
          totalPending += amount;
        }
      }

      return DashboardModel(
        totalBooks: totalBooks,
        availableBooks: availableCopiesSum,
        borrowedBooks: borrowedCopies,
        totalMembers: totalMembers,
        activeMembers: activeMembers,
        overdueBorrowings: overdueCount,
        totalFinesPending: totalPending,
        totalFinesCollected: totalCollected,
      );
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<DashboardModel> getLibrarianDashboardMetrics() async {
    return await getAdminDashboardMetrics();
  }

  Future<DashboardModel> getStudentDashboardMetrics(String memberId) async {
    try {
      final borrowings = await _firestoreService.borrowingsCollection
          .where('memberId', isEqualTo: memberId)
          .where('status', isEqualTo: 'ACTIVE')
          .get();

      final overdueCount = borrowings.docs
          .map((d) => BorrowingModel.fromMap(d.data(), d.id))
          .where((b) => b.isOverdue)
          .length;

      final fines = await _firestoreService.finesCollection
          .where('memberId', isEqualTo: memberId)
          .get();

      double pending = 0.0;
      double paid = 0.0;
      for (var doc in fines.docs) {
        final d = doc.data();
        final amount = (d['amount'] as num?)?.toDouble() ?? 0.0;
        final status = (d['status'] ?? '').toString().toUpperCase();
        if (status == 'PAID') {
          paid += amount;
        } else if (status == 'PENDING' || status == 'UNPAID') {
          pending += amount;
        }
      }

      return DashboardModel(
        borrowedBooks: borrowings.docs.length,
        overdueBorrowings: overdueCount,
        totalFinesPending: pending,
        totalFinesCollected: paid,
      );
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<List<ActivityModel>> getRecentActivities({int limit = 10}) async {
    try {
      final snapshot = await _firestoreService.activitiesCollection
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ActivityModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }
}
