import 'package:flutter/material.dart';
import '../../../models/borrowing_model.dart';
import '../../../core/extensions/date_extensions.dart';

/// Borrowing transaction card displaying book, member, due date, and status
class BorrowingCardWidget extends StatelessWidget {
  final BorrowingModel borrowing;
  final VoidCallback? onReturn;

  const BorrowingCardWidget({
    super.key,
    required this.borrowing,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(borrowing.bookTitle),
        subtitle: Text('Member: ${borrowing.memberName} • Due: ${borrowing.dueDate.toFormattedDate()}'),
        trailing: onReturn != null
            ? TextButton(onPressed: onReturn, child: const Text('Return'))
            : Chip(label: Text(borrowing.status.displayName)),
      ),
    );
  }
}
