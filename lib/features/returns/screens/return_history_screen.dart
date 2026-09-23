import 'package:flutter/material.dart';
import '../../borrowing/screens/borrowing_history_screen.dart';

/// Screen displaying return transaction archive (delegates to the comprehensive borrowing history view)
class ReturnHistoryScreen extends StatelessWidget {
  const ReturnHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BorrowingHistoryScreen();
  }
}
