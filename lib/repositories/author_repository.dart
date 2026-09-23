import '../models/author_model.dart';
import '../core/errors/firebase_exception_handler.dart';
import '../services/firebase/firestore_service.dart';

/// Repository mediating author data access in Firestore authors collection
class AuthorRepository {
  final FirestoreService _firestoreService;

  AuthorRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<List<AuthorModel>> getAuthors() async {
    try {
      final snapshot = await _firestoreService.authorsCollection
          .orderBy('name', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => AuthorModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<AuthorModel?> getAuthorById(String id) async {
    try {
      final doc = await _firestoreService.getDocument(
        _firestoreService.authorsCollection,
        id,
      );
      if (doc.exists && doc.data() != null) {
        return AuthorModel.fromMap(doc.data()!, id);
      }
      return null;
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> addAuthor(AuthorModel author) async {
    try {
      final docRef = author.id.isNotEmpty
          ? _firestoreService.authorsCollection.doc(author.id)
          : _firestoreService.authorsCollection.doc();

      final toSave = AuthorModel(
        id: docRef.id,
        name: author.name,
        description: author.description,
        bookCount: author.bookCount,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(toSave.toMap());
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> updateAuthor(AuthorModel author) async {
    try {
      await _firestoreService.setDocument(
        _firestoreService.authorsCollection,
        author.id,
        author.toMap(),
      );
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> deleteAuthor(String id) async {
    try {
      await _firestoreService.deleteDocument(
        _firestoreService.authorsCollection,
        id,
      );
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }
}
