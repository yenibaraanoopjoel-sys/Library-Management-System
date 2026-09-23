/// Date utility functions for borrowing periods and calendar math
class AppDateUtils {
  static DateTime calculateDueDate(DateTime borrowDate, {int durationDays = 14}) {
    return borrowDate.add(Duration(days: durationDays));
  }

  static int calculateDaysOverdue(DateTime dueDate, [DateTime? returnDate]) {
    final compareDate = returnDate ?? DateTime.now();
    if (compareDate.isBefore(dueDate)) return 0;
    return compareDate.difference(dueDate).inDays;
  }
}
