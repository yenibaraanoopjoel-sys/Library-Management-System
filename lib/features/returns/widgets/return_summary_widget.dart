import 'package:flutter/material.dart';

/// Summary card displaying details of a processed return and any associated fines
class ReturnSummaryWidget extends StatelessWidget {
  final String bookTitle;
  final String memberName;
  final double fineAssessed;

  const ReturnSummaryWidget({
    super.key,
    required this.bookTitle,
    required this.memberName,
    this.fineAssessed = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Book: $bookTitle'),
            Text('Member: $memberName'),
            if (fineAssessed > 0)
              Text('Fine: \$${fineAssessed.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
