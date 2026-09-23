import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/borrowing_provider.dart';
import '../../../providers/book_provider.dart';
import '../../../providers/fine_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../models/borrowing_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';

/// Screen for processing book check-in and returns with automated fine calculation
class ReturnBookScreen extends StatefulWidget {
  const ReturnBookScreen({super.key});

  @override
  State<ReturnBookScreen> createState() => _ReturnBookScreenState();
}

class _ReturnBookScreenState extends State<ReturnBookScreen> {
  String? _selectedBorrowingId;
  DateTime _returnDate = DateTime.now();
  String _bookCondition = 'Good Condition';
  bool _isLoading = false;
  bool _returnCompleted = false;
  double _assessedFine = 0.0;
  BorrowingModel? _completedBorrowing;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final borrowProv = Provider.of<BorrowingProvider>(context);
    final bookProv = Provider.of<BookProvider>(context);
    final fineProv = Provider.of<FineProvider>(context);
    final dashProv = Provider.of<DashboardProvider>(context);

    final activeLoans = borrowProv.activeBorrowings;
    final selectedLoan = _selectedBorrowingId != null
        ? borrowProv.getBorrowingById(_selectedBorrowingId!)
        : null;

    final daysOverdue = selectedLoan != null
        ? (_returnDate.isAfter(selectedLoan.dueDate)
            ? _returnDate.difference(selectedLoan.dueDate).inDays
            : 0)
        : 0;

    final calculatedFine = daysOverdue * 1.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Process Book Return')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _returnCompleted && _completedBorrowing != null
                ? _buildSuccessReceipt(context)
                : Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.assignment_return_outlined, size: 28, color: AppColors.secondary),
                              SizedBox(width: 12),
                              Text(
                                'Check-In Return Processing',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Select an active checkout loan to check in book copies and assess dues.',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          const Divider(height: 32),

                          // Select Loan Dropdown
                          const Text(
                            'SELECT ACTIVE LOAN RECORD',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 10),
                          AppDropdown<String>(
                            label: 'Active Borrowing Transaction',
                            value: _selectedBorrowingId,
                            items: activeLoans.map((loan) {
                              final isOver = loan.dueDate.isBefore(DateTime.now());
                              return DropdownMenuItem(
                                value: loan.id,
                                child: Text(
                                  '${loan.bookTitle} — ${loan.memberName} ${isOver ? '(OVERDUE)' : ''}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (id) {
                              setState(() => _selectedBorrowingId = id);
                            },
                          ),
                          const SizedBox(height: 24),

                          // Loan Details & Overdue Assessment
                          if (selectedLoan != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: daysOverdue > 0 ? AppColors.errorLight : AppColors.infoLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: daysOverdue > 0
                                      ? AppColors.error.withOpacity(0.3)
                                      : AppColors.info.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        daysOverdue > 0 ? Icons.alarm_on : Icons.check_circle_outline,
                                        color: daysOverdue > 0 ? AppColors.error : AppColors.info,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        daysOverdue > 0
                                            ? 'Book is $daysOverdue days overdue (Fine: \$${calculatedFine.toStringAsFixed(2)})'
                                            : 'Book returned on or before due date. No fine assessed.',
                                        style: TextStyle(
                                          color: daysOverdue > 0 ? AppColors.error : AppColors.info,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  _buildInfoRow('Book Title:', selectedLoan.bookTitle),
                                  _buildInfoRow('Borrower:', selectedLoan.memberName),
                                  _buildInfoRow('Issued On:', selectedLoan.borrowDate.toFormattedDate()),
                                  _buildInfoRow('Scheduled Due Date:', selectedLoan.dueDate.toFormattedDate()),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Return Date & Condition
                            const Text(
                              'CHECK-IN PARAMETERS',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _returnDate,
                                        firstDate: selectedLoan.borrowDate,
                                        lastDate: DateTime.now().add(const Duration(days: 1)),
                                      );
                                      if (picked != null) {
                                        setState(() => _returnDate = picked);
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Actual Return Date',
                                        prefixIcon: Icon(Icons.calendar_today_outlined),
                                      ),
                                      child: Text(_returnDate.toFormattedDate()),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: AppDropdown<String>(
                                    label: 'Physical Condition',
                                    value: _bookCondition,
                                    items: const [
                                      DropdownMenuItem(value: 'Good Condition', child: Text('Good / Normal Wear')),
                                      DropdownMenuItem(value: 'Minor Damage', child: Text('Minor Damage')),
                                      DropdownMenuItem(value: 'Major Damage', child: Text('Major Damage')),
                                      DropdownMenuItem(value: 'Lost Copy', child: Text('Lost Copy Reported')),
                                    ],
                                    onChanged: (c) {
                                      if (c != null) setState(() => _bookCondition = c);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 12),
                              AppButton(
                                text: 'Complete Check-In',
                                isLoading: _isLoading,
                                onPressed: selectedLoan != null
                                    ? () async {
                                        setState(() => _isLoading = true);
                                        await Future.delayed(const Duration(milliseconds: 400));

                                        // 1. Process return in BorrowingProvider
                                        final returnResult = await borrowProv.returnBook(
                                          borrowingId: selectedLoan.id,
                                          returnDate: _returnDate,
                                        );
                                        final fine = (returnResult['fineAmount'] as num?)?.toDouble() ?? 0.0;

                                        // 2. Increment book stock availability
                                        bookProv.adjustBookCopies(selectedLoan.bookId, 1);

                                        // 3. If fine assessed, record in FineProvider
                                        if (fine > 0) {
                                          fineProv.addFine(
                                            borrowingId: selectedLoan.id,
                                            memberId: selectedLoan.memberId,
                                            memberName: selectedLoan.memberName,
                                            amount: fine,
                                            daysOverdue: daysOverdue,
                                          );
                                        }

                                        // 4. Log activity in DashboardProvider
                                        dashProv.addActivity(
                                          action: 'Checked in "${selectedLoan.bookTitle}" from ${selectedLoan.memberName}',
                                          entityType: 'borrowing',
                                          entityId: selectedLoan.id,
                                          userName: auth.currentUser?.name ?? 'Sarah Jenkins',
                                        );

                                        setState(() {
                                          _isLoading = false;
                                          _assessedFine = fine;
                                          _completedBorrowing = selectedLoan;
                                          _returnCompleted = true;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessReceipt(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 64, color: AppColors.success),
            const SizedBox(height: 16),
            const Text(
              'Book Return Processed Successfully!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Copy restored to catalog shelf. Inventory updated.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const Divider(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('Book Title:', _completedBorrowing!.bookTitle),
                  const SizedBox(height: 6),
                  _buildReceiptRow('Returned By:', _completedBorrowing!.memberName),
                  const SizedBox(height: 6),
                  _buildReceiptRow('Return Date:', _returnDate.toFormattedDate()),
                  const SizedBox(height: 6),
                  _buildReceiptRow('Condition:', _bookCondition),
                  const Divider(height: 16),
                  _buildReceiptRow(
                    'Overdue Fine:',
                    _assessedFine > 0 ? '\$${_assessedFine.toStringAsFixed(2)} (Assessed)' : '\$0.00 (No Dues)',
                    isHighlighted: _assessedFine > 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _returnCompleted = false;
                      _selectedBorrowingId = null;
                      _completedBorrowing = null;
                    });
                  },
                  child: const Text('Process Another Return'),
                ),
                const SizedBox(width: 16),
                AppButton(
                  text: 'Return to Dashboard',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? AppColors.error : null,
          ),
        ),
      ],
    );
  }
}
