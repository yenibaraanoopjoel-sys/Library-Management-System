import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/fine_status.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../providers/fine_provider.dart';
import '../../../providers/auth_provider.dart';

/// Screen displaying details of a specific fine with receipt view and payment actions
class FineDetailsScreen extends StatelessWidget {
  final String fineId;

  const FineDetailsScreen({super.key, required this.fineId});

  @override
  Widget build(BuildContext context) {
    final fineProvider = Provider.of<FineProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final canManageFines = !authProvider.isStudent;

    final fine = fineProvider.allFines.cast<dynamic>().firstWhere(
          (f) => f.id == fineId,
          orElse: () => null,
        );

    if (fine == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fine Details')),
        body: Center(
          child: EmptyState(
            title: 'Fine Not Found',
            message: 'No fine record found matching ID: $fineId',
            icon: Icons.receipt_long_outlined,
            actionLabel: 'Back to Fines',
            onAction: () => Navigator.pop(context),
          ),
        ),
      );
    }

    final isPaid = fine.status == FineStatus.paid;
    final isWaived = fine.status == FineStatus.waived;
    final isUnpaid = fine.status == FineStatus.unpaid;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Fine Details & Receipt'),
        actions: [
          IconButton(
            tooltip: 'Print / Download Receipt',
            icon: const Icon(Icons.print_outlined),
            onPressed: () {
              AppSnackbar.showSuccess(
                context,
                'Receipt #${fine.id.toUpperCase()} generated and downloaded successfully.',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Digital Invoice Receipt Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Receipt Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.receipt_long,
                                color: AppColors.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'LIBRA SYSTEM OFFICIAL RECEIPT',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      fontSize: 13,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Fine Reference: ${fine.id.toUpperCase()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(fine.status),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 20),

                        // Two column receipt metadata
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabelValue('Billed To', fine.memberName, isBold: true),
                                  const SizedBox(height: 12),
                                  _buildLabelValue('Member ID', fine.memberId),
                                  const SizedBox(height: 12),
                                  _buildLabelValue('Borrowing Ref', fine.borrowingId.toUpperCase()),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabelValue(
                                    'Date Assessed',
                                    _formatDate(fine.assessedDate),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildLabelValue(
                                    'Days Overdue',
                                    '${fine.daysOverdue} days',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildLabelValue(
                                    'Payment Date',
                                    fine.paidDate != null ? _formatDate(fine.paidDate!) : 'Pending',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Itemized Table
                        const Text(
                          'FEE BREAKDOWN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.04)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Late Return Penalty (${fine.daysOverdue} days @ \$0.50/day)',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '\$${fine.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Assessed Fee',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '\$${fine.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: isPaid
                                          ? AppColors.success
                                          : isWaived
                                              ? Colors.grey
                                              : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (isPaid) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.success.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.success, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Paid in Full on ${_formatDate(fine.paidDate ?? DateTime.now())}. No balance remaining.',
                                    style: const TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (isWaived) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.grey, size: 22),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'This fine has been formally waived by library administration.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Bar
                if (isUnpaid) ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Process Payment (\$${fine.amount.toStringAsFixed(2)})',
                          icon: Icons.credit_card,
                          onPressed: () {
                            AppDialog.showConfirmation(
                              context,
                              title: 'Confirm Payment',
                              message:
                                  'Confirm payment of \$${fine.amount.toStringAsFixed(2)} for ${fine.memberName}?',
                              confirmLabel: 'Confirm & Pay',
                              onConfirm: () {
                                fineProvider.payFine(fine.id);
                                AppSnackbar.showSuccess(
                                  context,
                                  'Fine payment of \$${fine.amount.toStringAsFixed(2)} processed successfully!',
                                );
                              },
                            );
                          },
                        ),
                      ),
                      if (canManageFines) ...[
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: const BorderSide(color: AppColors.warning),
                            foregroundColor: AppColors.warning,
                          ),
                          icon: const Icon(Icons.handshake_outlined),
                          label: const Text('Waive Fine'),
                          onPressed: () {
                            AppDialog.showConfirmation(
                              context,
                              title: 'Waive Fine',
                              message:
                                  'Are you sure you want to waive the \$${fine.amount.toStringAsFixed(2)} penalty for ${fine.memberName}?',
                              confirmLabel: 'Waive Fine',
                              onConfirm: () {
                                fineProvider.waiveFine(fine.id);
                                AppSnackbar.showInfo(
                                  context,
                                  'Fine of \$${fine.amount.toStringAsFixed(2)} has been waived.',
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Fines List'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelValue(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(FineStatus status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case FineStatus.paid:
        bg = AppColors.success.withOpacity(0.15);
        fg = AppColors.success;
        text = 'PAID';
        break;
      case FineStatus.unpaid:
        bg = AppColors.error.withOpacity(0.15);
        fg = AppColors.error;
        text = 'UNPAID';
        break;
      case FineStatus.waived:
        bg = Colors.grey.withOpacity(0.15);
        fg = Colors.grey.shade700;
        text = 'WAIVED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
