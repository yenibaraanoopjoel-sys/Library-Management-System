import '../models/book_model.dart';
import '../core/errors/firebase_exception_handler.dart';
import '../services/firebase/firestore_service.dart';

/// Repository mediating book catalog data access in Firestore books collection
class BookRepository {
  final FirestoreService _firestoreService;

  BookRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<BookModel>> get booksStream {
    return _firestoreService.booksCollection
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<BookModel>> getBooks() async {
    try {
      final snapshot = await _firestoreService.booksCollection.get();
      return snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<BookModel?> getBookById(String id) async {
    try {
      final doc = await _firestoreService.getDocument(
        _firestoreService.booksCollection,
        id,
      );
      if (doc.exists && doc.data() != null) {
        return BookModel.fromMap(doc.data()!, id);
      }
      return null;
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> addBook(BookModel book) async {
    try {
      final docRef = book.id.isNotEmpty
          ? _firestoreService.booksCollection.doc(book.id)
          : _firestoreService.booksCollection.doc();

      final bookToSave = book.id.isEmpty
          ? BookModel(
              id: docRef.id,
              title: book.title,
              authorId: book.authorId,
              authorName: book.authorName,
              categoryId: book.categoryId,
              categoryName: book.categoryName,
              isbn: book.isbn,
              publisher: book.publisher,
              publicationYear: book.publicationYear,
              description: book.description,
              coverImage: book.coverImage,
              totalCopies: book.totalCopies,
              availableCopies: book.availableCopies,
              shelfLocation: book.shelfLocation,
              status: book.status,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          : book;

      await docRef.set(bookToSave.toMap());
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> updateBook(BookModel book) async {
    try {
      await _firestoreService.setDocument(
        _firestoreService.booksCollection,
        book.id,
        book.toMap(),
      );
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> deleteBook(String id) async {
    try {
      await _firestoreService.deleteDocument(
        _firestoreService.booksCollection,
        id,
      );
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<List<BookModel>> getBooksByCategory(String categoryName) async {
    try {
      final snapshot = await _firestoreService.booksCollection
          .where('categoryName', isEqualTo: categoryName)
          .get();
      return snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<List<BookModel>> searchBooks(String query) async {
    try {
      final cleanQuery = query.trim().toLowerCase();
      if (cleanQuery.isEmpty) return await getBooks();

      final all = await getBooks();
      return all.where((b) =>
          b.title.toLowerCase().contains(cleanQuery) ||
          b.authorName.toLowerCase().contains(cleanQuery) ||
          b.isbn.toLowerCase().contains(cleanQuery) ||
          b.categoryName.toLowerCase().contains(cleanQuery)).toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> updateAvailableCopies(String bookId, int delta) async {
    try {
      await _firestoreService.runTransaction((transaction) async {
        final docRef = _firestoreService.booksCollection.doc(bookId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Book not found: $bookId');
        }

        final data = snapshot.data()!;
        final total = (data['totalCopies'] as num?)?.toInt() ?? 1;
        final currentAvailable = (data['availableCopies'] as num?)?.toInt() ?? total;
        final newAvailable = (currentAvailable + delta).clamp(0, total);

        transaction.update(docRef, {
          'availableCopies': newAvailable,
          'status': newAvailable > 0 ? 'available' : 'borrowed',
          'updatedAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }
}
