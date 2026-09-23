import 'package:flutter/foundation.dart';
import '../firebase/firestore_service.dart';
import '../../core/mock/mock_data.dart';

/// Safe development seeding utility populating initial library dataset into Cloud Firestore
class SeedService {
  final FirestoreService _firestoreService;

  SeedService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<bool> isDatabaseEmpty() async {
    try {
      final booksSnapshot = await _firestoreService.booksCollection.limit(1).get();
      return booksSnapshot.docs.isEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Populates initial books, members, categories, and activities if Firestore is empty
  Future<void> seedInitialDataIfEmpty() async {
    final empty = await isDatabaseEmpty();
    if (empty) {
      if (kDebugMode) {
        print('🌱 Firestore is empty. Seeding initial library catalog & demo accounts...');
      }
      await seedAll();
    }
  }

  Future<void> seedAll() async {
    try {
      // 1. Seed demo users
      for (final user in MockData.demoUsers) {
        await _firestoreService.setDocument(
          _firestoreService.usersCollection,
          user.id,
          user.toMap(),
        );
      }

      // 2. Seed books
      final batchBooks = _firestoreService.batch();
      for (final book in MockData.getInitialBooks()) {
        final docRef = _firestoreService.booksCollection.doc(book.id);
        batchBooks.set(docRef, book.toMap());
      }
      await batchBooks.commit();

      // 3. Seed members
      final batchMembers = _firestoreService.batch();
      for (final member in MockData.getInitialMembers()) {
        final docRef = _firestoreService.membersCollection.doc(member.id);
        batchMembers.set(docRef, member.toMap());
      }
      await batchMembers.commit();

      // 4. Seed categories
      final categories = [
        {'id': 'cat_cs', 'name': 'Computer Science', 'description': 'Algorithms, software engineering, databases'},
        {'id': 'cat_fiction', 'name': 'Fiction & Literature', 'description': 'Classics, modern fiction, drama'},
        {'id': 'cat_science', 'name': 'Natural Sciences', 'description': 'Physics, biology, astronomy'},
        {'id': 'cat_psychology', 'name': 'Psychology', 'description': 'Human behavior, cognition, mental wellness'},
        {'id': 'cat_business', 'name': 'Business & Economics', 'description': 'Leadership, startups, finance'},
      ];
      final batchCat = _firestoreService.batch();
      for (final cat in categories) {
        final docRef = _firestoreService.categoriesCollection.doc(cat['id']!);
        batchCat.set(docRef, cat);
      }
      await batchCat.commit();

      // 5. Seed borrowings
      final batchBorrow = _firestoreService.batch();
      for (final br in MockData.getInitialBorrowings()) {
        final docRef = _firestoreService.borrowingsCollection.doc(br.id);
        batchBorrow.set(docRef, br.toMap());
      }
      await batchBorrow.commit();

      // 6. Seed fines
      final batchFines = _firestoreService.batch();
      for (final fn in MockData.getInitialFines()) {
        final docRef = _firestoreService.finesCollection.doc(fn.id);
        batchFines.set(docRef, fn.toMap());
      }
      await batchFines.commit();

      if (kDebugMode) {
        print('✅ Initial Firestore seeding completed successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Seeding error (likely rules/offline): $e');
      }
    }
  }
}
