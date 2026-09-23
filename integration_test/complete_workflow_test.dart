import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:library_management_system/models/book_model.dart';
import 'package:library_management_system/models/borrowing_model.dart';
import 'package:library_management_system/core/enums/borrowing_status.dart';
import 'package:library_management_system/core/utils/fine_calculator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Circulation End-to-End Workflow Integration Tests', () {
    test('Verify full lifecycle: Catalog -> Issue -> Return -> Fine Assessment', () async {
      // 1. Initial Book State
      var book = const BookModel(
        id: 'bk_integration_01',
        title: 'Modern Software Engineering',
        authorId: 'auth_01',
        authorName: 'David Farley',
        categoryId: 'cat_cs',
        categoryName: 'Computer Science',
        isbn: '978-0137314911',
        publisher: 'Pearson',
        publicationYear: 2021,
        totalCopies: 4,
        availableCopies: 4,
      );

      expect(book.isAvailable, true);
      expect(book.availableCopies, 4);

      // 2. Issue Book Transaction (Decrease copies by 1)
      book = book.copyWith(availableCopies: book.availableCopies - 1);
      expect(book.availableCopies, 3);

      final issueDate = DateTime(2026, 9, 1);
      final dueDate = DateTime(2026, 9, 15);

      var borrowing = BorrowingModel(
        id: 'br_integration_01',
        bookId: book.id,
        bookTitle: book.title,
        memberId: 'mem_integration_01',
        memberName: 'Alex Rivera',
        issuedBy: 'Sarah Jenkins (Librarian)',
        issueDate: issueDate,
        dueDate: dueDate,
        status: BorrowingStatus.active,
      );

      expect(borrowing.status, BorrowingStatus.active);

      // 3. Return Book Past Due (e.g. Returned on Sept 19 = 4 days overdue)
      final returnDate = DateTime(2026, 9, 19);
      final fineAmount = FineCalculator.calculateFine(
        dueDate: dueDate,
        returnDate: returnDate,
        dailyRate: 1.0,
      );

      expect(fineAmount, 4.0);

      // 4. Update Borrowing to RETURNED with assessed fine
      borrowing = borrowing.copyWith(
        returnDate: returnDate,
        status: BorrowingStatus.returned,
        fineAmount: fineAmount,
      );

      expect(borrowing.status, BorrowingStatus.returned);
      expect(borrowing.fineAmount, 4.0);

      // 5. Restore Book Available Copies
      book = book.copyWith(availableCopies: book.availableCopies + 1);
      expect(book.availableCopies, 4);
    });
  });
}
