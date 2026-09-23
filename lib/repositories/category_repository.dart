import '../models/category_model.dart';
import '../core/errors/firebase_exception_handler.dart';
import '../services/firebase/firestore_service.dart';

/// Repository mediating category data access in Firestore categories collection
class CategoryRepository {
  final FirestoreService _firestoreService;

  CategoryRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestoreService.categoriesCollection
          .orderBy('name', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final doc = await _firestoreService.getDocument(
        _firestoreService.categoriesCollection,
        id,
      );
      if (doc.exists && doc.data() != null) {
        return CategoryModel.fromMap(doc.data()!, id);
      }
      return null;
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      final docRef = category.id.isNotEmpty
          ? _firestoreService.categoriesCollection.doc(category.id)
          : _firestoreService.categoriesCollection.doc();

      final toSave = CategoryModel(
        id: docRef.id,
        name: category.name,
        description: category.description,
        bookCount: category.bookCount,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(toSave.toMap());
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _firestoreService.setDocument(
        _firestoreService.categoriesCollection,
        category.id,
        category.toMap(),
      );
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestoreService.deleteDocument(
        _firestoreService.categoriesCollection,
        id,
      );
    } catch (e) {
      throw FirebaseExceptionHandler.handle(e);
    }
  }
}
