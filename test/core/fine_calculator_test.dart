import 'package:flutter_test/flutter_test.dart';
import 'package:library_management_system/core/utils/fine_calculator.dart';

void main() {
  group('FineCalculator Unit Tests', () {
    test('Returns 0.0 fine when book is returned on or before due date', () {
      final dueDate = DateTime.now().add(const Duration(days: 3));
      final returnDate = DateTime.now();

      final fine = FineCalculator.calculateFine(
        dueDate: dueDate,
        returnDate: returnDate,
      );

      expect(fine, 0.0);
    });

    test('Calculates fine correctly for overdue return', () {
      final dueDate = DateTime(2026, 9, 1);
      final returnDate = DateTime(2026, 9, 6); // 5 days late

      final fine = FineCalculator.calculateFine(
        dueDate: dueDate,
        returnDate: returnDate,
        dailyRate: 1.0,
      );

      expect(fine, 5.0);
    });

    test('Applies custom daily fine rate accurately', () {
      final dueDate = DateTime(2026, 9, 1);
      final returnDate = DateTime(2026, 9, 11); // 10 days late

      final fine = FineCalculator.calculateFine(
        dueDate: dueDate,
        returnDate: returnDate,
        dailyRate: 0.50,
      );

      expect(fine, 5.0);
    });
  });
}
