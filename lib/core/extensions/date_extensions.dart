import 'package:intl/intl.dart';

/// Extension helpers for DateTime formatting and comparison
extension DateExtensions on DateTime {
  String toFormattedDate() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  String toFormattedDateTime() {
    return DateFormat('dd MMM yyyy, hh:mm a').format(this);
  }

  bool get isPastDue => isBefore(DateTime.now());

  int daysBetween(DateTime other) {
    return difference(other).inDays.abs();
  }
}
