import 'package:cloud_firestore/cloud_firestore.dart';

/// Low-level wrapper service for Cloud Firestore operations with transaction and batch support
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;

  // Collection references
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get membersCollection =>
      _firestore.collection('members');

  CollectionReference<Map<String, dynamic>> get booksCollection =>
      _firestore.collection('books');

  CollectionReference<Map<String, dynamic>> get authorsCollection =>
      _firestore.collection('authors');

  CollectionReference<Map<String, dynamic>> get categoriesCollection =>
      _firestore.collection('categories');

  CollectionReference<Map<String, dynamic>> get borrowingsCollection =>
      _firestore.collection('borrowings');

  CollectionReference<Map<String, dynamic>> get finesCollection =>
      _firestore.collection('fines');

  CollectionReference<Map<String, dynamic>> get activitiesCollection =>
      _firestore.collection('activities');

  CollectionReference<Map<String, dynamic>> get notificationsCollection =>
      _firestore.collection('notifications');

  // Generic document operations
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    CollectionReference<Map<String, dynamic>> collection,
    String documentId,
  ) async {
    return await collection.doc(documentId).get();
  }

  Future<void> setDocument(
    CollectionReference<Map<String, dynamic>> collection,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    await collection.doc(documentId).set(data, SetOptions(merge: merge));
  }

  Future<void> updateDocument(
    CollectionReference<Map<String, dynamic>> collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    await collection.doc(documentId).update(data);
  }

  Future<void> deleteDocument(
    CollectionReference<Map<String, dynamic>> collection,
    String documentId,
  ) async {
    await collection.doc(documentId).delete();
  }

  // Atomic transaction execution
  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    return await _firestore.runTransaction(
      transactionHandler,
      timeout: timeout,
    );
  }

  // Batch operations
  WriteBatch batch() {
    return _firestore.batch();
  }
}
