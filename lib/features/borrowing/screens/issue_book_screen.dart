import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/book_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/borrowing_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_snackbar.dart';

/// Guided step-by-step book checkout / issuance screen
class IssueBookScreen extends StatefulWidget {
  const IssueBookScreen({super.key});

  @override
  State<IssueBookScreen> createState() => _IssueBookScreenState();
}

class _IssueBookScreenState extends State<IssueBookScreen> {
  String? _selectedMemberId;
  String? _selectedBookId;
  DateTime _borrowDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final bookProv = Provider.of<BookProvider>(context);
    final memberProv = Provider.of<MemberProvider>(context);
    final borrowProv = Provider.of<BorrowingProvider>(context);

    // Available books only
    final availableBooks = bookProv.allBooks.where((b) => b.availableCopies > 0).toList();
    final activeMembers = memberProv.allMembers.where((m) => m.status == 'active').toList();

    final selectedMember = _selectedMemberId != null ? memberProv.getMemberById(_selectedMemberId!) : null;
    final selectedBook = _selectedBookId != null ? bookProv.getBookById(_selectedBookId!) : null;

    final memberCurrentLoans = selectedMember != null
        ? borrowProv.allBorrowings.where((b) => b.memberId == selectedMember.id && b.status.name != 'returned').length
        : 0;

    final canBorrow = selectedMember == null || memberCurrentLoans < selectedMember.maxBooksAllowed;

    return Scaffold(
      appBar: AppBar(title: const Text('Issue Book to Patron')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.assignment_turned_in_outlined, size: 28, color: AppColors.primary),
                        SizedBox(width: 12),
                        Text(
                          'Checkout Circulation Form',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Follow the 4 steps below to issue a title to an enrolled patron.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const Divider(height: 32),

                    // STEP 1: Select Member
                    _buildStepHeader('1', 'SELECT MEMBER / PATRON'),
                    const SizedBox(height: 10),
                    AppDropdown<String>(
                      label: 'Select Registered Member',
                      value: _selectedMemberId,
                      items: activeMembers.map((m) {
                        return DropdownMenuItem(
                          value: m.id,
                          child: Text('${m.name} (${m.membershipNumber})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedMemberId = val);
                      },
                    ),
                    if (selectedMember != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: canBorrow ? AppColors.infoLight : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(canBorrow ? Icons.check_circle : Icons.error, color: canBorrow ? AppColors.info : AppColors.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                canBorrow
                                    ? 'Member has $memberCurrentLoans of ${selectedMember.maxBooksAllowed} books checked out. Eligible to borrow.'
                                    : 'Borrow limit reached ($memberCurrentLoans/${selectedMember.maxBooksAllowed} books checked out). Cannot issue another copy until a book is returned.',
                                style: TextStyle(
                                  color: canBorrow ? AppColors.info : AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // STEP 2: Select Book
                    _buildStepHeader('2', 'SELECT BOOK TITLE'),
                    const SizedBox(height: 10),
                    AppDropdown<String>(
                      label: 'Select Book Title (Available in stock)',
                      value: _selectedBookId,
                      items: availableBooks.map((b) {
                        return DropdownMenuItem(
                          value: b.id,
                          child: Text('${b.title} (${b.availableCopies} available)'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedBookId = val);
                      },
                    ),
                    if (selectedBook != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('Shelf Location: ${selectedBook.shelfLocation}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text('${selectedBook.availableCopies} / ${selectedBook.totalCopies} Copies available', style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // STEP 3: Issue and Due Dates
                    _buildStepHeader('3', 'SPECIFY CIRCULATION PERIOD'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _borrowDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (picked != null) {
                                setState(() {
                                  _borrowDate = picked;
                                  _dueDate = picked.add(const Duration(days: 14));
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Issue Date',
                                prefixIcon: Icon(Icons.calendar_today_outlined),
                              ),
                              child: Text(_borrowDate.toFormattedDate()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dueDate,
                                firstDate: _borrowDate,
                                lastDate: _borrowDate.add(const Duration(days: 60)),
                              );
                              if (picked != null) {
                                setState(() => _dueDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Due Date',
                                prefixIcon: Icon(Icons.event_available_outlined),
                              ),
                              child: Text(_dueDate.toFormattedDate()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // STEP 4: Summary Confirmation Card
                    if (selectedMember != null && selectedBook != null) ...[
                      _buildStepHeader('4', 'CONFIRM LOAN SUMMARY'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow('Book Title:', selectedBook.title),
                            const SizedBox(height: 6),
                            _buildSummaryRow('Borrower:', '${selectedMember.name} (${selectedMember.membershipNumber})'),
                            const SizedBox(height: 6),
                            _buildSummaryRow('Issued By:', auth.currentUser?.name ?? 'Sarah Jenkins'),
                            const SizedBox(height: 6),
                            _buildSummaryRow('Circulation Duration:', '${_dueDate.difference(_borrowDate).inDays} Days (Due: ${_dueDate.toFormattedDate()})'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        AppButton(
                          text: 'Confirm & Issue Book',
                          isLoading: _isLoading,
                          onPressed: (selectedMember != null && selectedBook != null && canBorrow)
                              ? () async {
                                  setState(() => _isLoading = true);
                                  await Future.delayed(const Duration(milliseconds: 400));

                                  // 1. Add Borrowing
                                  borrowProv.issueBook(
                                    bookId: selectedBook.id,
                                    bookTitle: selectedBook.title,
                                    memberId: selectedMember.id,
                                    memberName: selectedMember.name,
                                    issuedBy: auth.currentUser?.name ?? 'Sarah Jenkins',
                                    borrowDate: _borrowDate,
                                    dueDate: _dueDate,
                                  );

                                  // 2. Decrement available copies
                                  bookProv.adjustBookCopies(selectedBook.id, -1);

                                  // 3. Log activity
                                  final dashProv = Provider.of<DashboardProvider>(context, listen: false);
                                  dashProv.addActivity(
                                    action: 'Issued "${selectedBook.title}" to ${selectedMember.name}',
                                    entityType: 'borrowing',
                                    entityId: selectedBook.id,
                                    userName: auth.currentUser?.name ?? 'Sarah Jenkins',
                                  );

                                  // 4. Send notification
                                  final notifProv = Provider.of<NotificationProvider>(context, listen: false);
                                  notifProv.addNotification(
                                    title: 'Book Issued: ${selectedBook.title}',
                                    message: 'You checked out "${selectedBook.title}". Due on ${_dueDate.toFormattedDate()}.',
                                    type: 'general',
                                    userId: selectedMember.userId ?? 'usr_student',
                                  );

                                  setState(() => _isLoading = false);

                                  if (mounted) {
                                    AppSnackbar.showSuccess(context, 'Book issued to ${selectedMember.name} successfully!');
                                    Navigator.pop(context);
                                  }
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

  Widget _buildStepHeader(String stepNum, String title) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: Center(
            child: Text(
              stepNum,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
