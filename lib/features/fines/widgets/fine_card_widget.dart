import 'package:flutter/material.dart';
import '../../../models/fine_model.dart';

/// Fine item card displaying member name, amount, days overdue, and status
class FineCardWidget extends StatelessWidget {
  final FineModel fine;
  final VoidCallback? onPay;

  const FineCardWidget({
    super.key,
    required this.fine,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${fine.memberName} — \$${fine.amount.toStringAsFixed(2)}'),
        subtitle: Text('${fine.daysOverdue} days overdue • Status: ${fine.status.displayName}'),
        trailing: onPay != null
            ? ElevatedButton(onPressed: onPay, child: const Text('Pay'))
            : Chip(label: Text(fine.status.displayName)),
      ),
    );
  }
}
