import 'package:flutter_test/flutter_test.dart';
import 'package:library_management_system/models/user_model.dart';
import 'package:library_management_system/models/book_model.dart';
import 'package:library_management_system/models/borrowing_model.dart';
import 'package:library_management_system/models/fine_model.dart';
import 'package:library_management_system/models/notification_model.dart';
import 'package:library_management_system/core/enums/user_role.dart';
import 'package:library_management_system/core/enums/borrowing_status.dart';
import 'package:library_management_system/core/enums/fine_status.dart';

void main() {
  group('Firestore Model Serialization Tests', () {
    test('UserModel: fromMap and toMap serialization', () {
      final now = DateTime.now();
      final user = UserModel(
        uid: 'user_123',
        fullName: 'Alexander Morgan',
        email: 'alex@library.com',
        phone: '+1 555-0192',
        role: UserRole.admin,
        memberId: 'MEM-001',
        createdAt: now,
      );

      final map = user.toMap();
      expect(map['uid'], 'user_123');
      expect(map['fullName'], 'Alexander Morgan');
      expect(map['role'], 'admin');

      final deserialized = UserModel.fromMap(map, 'user_123');
      expect(deserialized.uid, 'user_123');
      expect(deserialized.fullName, 'Alexander Morgan');
      expect(deserialized.name, 'Alexander Morgan'); // getter
      expect(deserialized.role, UserRole.admin);
    });

    test('BookModel: copy bounds and availability clamping', () {
      final book = BookModel(
        id: 'bk_999',
        title: 'Design Patterns',
        authorId: 'auth_1',
        authorName: 'Erich Gamma',
        categoryId: 'cat_cs',
        categoryName: 'Computer Science',
        isbn: '978-0201633610',
        publisher: 'Addison-Wesley',
        publicationYear: 1994,
        totalCopies: 5,
        availableCopies: 3,
        shelfLocation: 'A-12',
      );

      final map = book.toMap();
      expect(map['availableCopies'], 3);
      expect(map['status'], 'available');

      final deserialized = BookModel.fromMap(map, 'bk_999');
      expect(deserialized.id, 'bk_999');
      expect(deserialized.title, 'Design Patterns');
      expect(deserialized.availableCopies, 3);
      expect(deserialized.isAvailable, true);
    });

    test('BorrowingModel: dynamic overdue logic', () {
      final pastDue = DateTime.now().subtract(const Duration(days: 4));
      final borrowing = BorrowingModel(
        id: 'br_test',
        bookId: 'bk_1',
        bookTitle: 'Clean Code',
        memberId: 'mem_1',
        memberName: 'John Doe',
        issuedBy: 'Admin',
        issueDate: DateTime.now().subtract(const Duration(days: 18)),
        dueDate: pastDue,
        status: BorrowingStatus.active,
      );

      expect(borrowing.isOverdue, true);
      expect(borrowing.overdueDays >= 3, true);
      expect(borrowing.effectiveStatusString, 'OVERDUE');
    });

    test('FineModel: serialization and status translation', () {
      final fine = FineModel(
        id: 'fn_123',
        borrowingId: 'br_test',
        memberId: 'mem_1',
        memberName: 'John Doe',
        amount: 4.50,
        overdueDays: 9,
        status: FineStatus.unpaid,
        issuedAt: DateTime.now(),
      );

      final map = fine.toMap();
      expect(map['status'], 'PENDING');
      expect(map['amount'], 4.50);

      final deserialized = FineModel.fromMap(map, 'fn_123');
      expect(deserialized.id, 'fn_123');
      expect(deserialized.amount, 4.50);
      expect(deserialized.status, FineStatus.unpaid);
    });

    test('NotificationModel: serialization and copyWith', () {
      final notif = NotificationModel(
        id: 'notif_1',
        userId: 'user_1',
        title: 'Due Soon',
        message: 'Book due in 2 days',
        type: 'due_soon',
        isRead: false,
        createdAt: DateTime.now(),
      );

      final map = notif.toMap();
      expect(map['title'], 'Due Soon');
      expect(map['isRead'], false);

      final updated = notif.copyWith(isRead: true);
      expect(updated.isRead, true);
      expect(updated.id, 'notif_1');
    });
  });
}
