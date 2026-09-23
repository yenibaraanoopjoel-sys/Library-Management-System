import '../../models/book_model.dart';
import '../../models/member_model.dart';
import '../../models/borrowing_model.dart';
import '../firebase/firestore_service.dart';

/// Global search service querying across books, members, and borrowings in Firestore
class SearchService {
  final FirestoreService _firestoreService;

  SearchService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<List<BookModel>> searchBooks(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final snapshot = await _firestoreService.booksCollection.limit(100).get();
    return snapshot.docs
        .map((doc) => BookModel.fromMap(doc.data(), doc.id))
        .where((b) =>
            b.title.toLowerCase().contains(cleanQuery) ||
            b.authorName.toLowerCase().contains(cleanQuery) ||
            b.isbn.toLowerCase().contains(cleanQuery) ||
            b.categoryName.toLowerCase().contains(cleanQuery))
        .toList();
  }

  Future<List<MemberModel>> searchMembers(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final snapshot = await _firestoreService.membersCollection.limit(100).get();
    return snapshot.docs
        .map((doc) => MemberModel.fromMap(doc.data(), doc.id))
        .where((m) =>
            m.fullName.toLowerCase().contains(cleanQuery) ||
            m.email.toLowerCase().contains(cleanQuery) ||
            m.phone.toLowerCase().contains(cleanQuery) ||
            m.memberId.toLowerCase().contains(cleanQuery))
        .toList();
  }

  Future<List<BorrowingModel>> searchBorrowings(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final snapshot = await _firestoreService.borrowingsCollection.limit(100).get();
    return snapshot.docs
        .map((doc) => BorrowingModel.fromMap(doc.data(), doc.id))
        .where((br) =>
            br.bookTitle.toLowerCase().contains(cleanQuery) ||
            br.memberName.toLowerCase().contains(cleanQuery) ||
            br.id.toLowerCase().contains(cleanQuery))
        .toList();
  }
}
