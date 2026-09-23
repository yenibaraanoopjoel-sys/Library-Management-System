import 'date_utils.dart';

/// Fine calculation utility based on overdue days and daily rate
class FineCalculator {
  static const double defaultDailyRate = 1.0;

  static double calculateFine({
    required DateTime dueDate,
    DateTime? returnDate,
    double dailyRate = defaultDailyRate,
  }) {
    final daysOverdue = AppDateUtils.calculateDaysOverdue(dueDate, returnDate);
    if (daysOverdue <= 0) return 0.0;
    return daysOverdue * dailyRate;
  }
}
