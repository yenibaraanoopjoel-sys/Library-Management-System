import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/borrowing_provider.dart';
import '../../../providers/fine_provider.dart';
import '../../../routing/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';

/// Comprehensive Member Details Screen with borrowing history, fines, and account management
class MemberDetailsScreen extends StatelessWidget {
  final String memberId;

  const MemberDetailsScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final memberProv = Provider.of<MemberProvider>(context);
    final borrowProv = Provider.of<BorrowingProvider>(context);
    final fineProv = Provider.of<FineProvider>(context);

    final member = memberProv.getMemberById(memberId);

    if (member == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Member Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Member record not found in system.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Directory'),
              ),
            ],
          ),
        ),
      );
    }

    final activeLoans = borrowProv.allBorrowings.where((b) => b.memberId == member.id && b.status.name != 'returned').toList();
    final historyLoans = borrowProv.allBorrowings.where((b) => b.memberId == member.id && b.status.name == 'returned').toList();
    final memberFines = fineProv.allFines.where((f) => f.memberId == member.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        actions: [
          if (!auth.isStudent) ...[
            IconButton(
              tooltip: 'Edit Member',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.editMember, arguments: member.id);
              },
            ),
            IconButton(
              tooltip: 'Delete Member',
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () async {
                final confirm = await AppDialog.showConfirmationDialog(
                  context: context,
                  title: 'Delete Member',
                  message: 'Are you sure you want to remove ${member.name}?',
                  confirmText: 'Delete',
                );
                if (confirm == true) {
                  memberProv.deleteMember(member.id);
                  if (context.mounted) {
                    AppSnackbar.showSuccess(context, 'Member removed.');
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        member.name.isNotEmpty ? member.name[0] : 'M',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: member.status == 'active' ? AppColors.successLight : AppColors.errorLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  member.status.toUpperCase(),
                                  style: TextStyle(
                                    color: member.status == 'active' ? AppColors.success : AppColors.error,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Card ID: ${member.membershipNumber} • Joined: ${member.joinedDate?.toFormattedDate() ?? 'Recent'}',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 32,
                            runSpacing: 12,
                            children: [
                              _buildInfoItem(Icons.email_outlined, 'Email', member.email),
                              _buildInfoItem(Icons.phone_outlined, 'Phone', member.phone),
                              _buildInfoItem(Icons.home_outlined, 'Address', member.address),
                              _buildInfoItem(Icons.bookmark_outline, 'Borrow Limit', '${member.maxBooksAllowed} Books'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!auth.isStudent)
                      AppButton(
                        text: 'Issue Book to Member',
                        icon: Icons.add_circle_outline,
                        onPressed: () {
                          Navigator.pushNamed(context, RouteNames.issueBook);
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Active Loans Section
            Text(
              'CURRENTLY BORROWED BOOKS (${activeLoans.length}/${member.maxBooksAllowed})',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Card(
              child: activeLoans.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No active books checked out.')),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeLoans.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final loan = activeLoans[i];
                        final isOverdue = loan.dueDate.isBefore(DateTime.now());
                        return ListTile(
                          leading: const Icon(Icons.book, color: AppColors.primary),
                          title: Text(loan.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Borrowed: ${loan.borrowDate.toFormattedDate()} • Due: ${loan.dueDate.toFormattedDate()}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isOverdue)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(6)),
                                  child: const Text('OVERDUE', style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, RouteNames.returns),
                                child: const Text('Return Book'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 28),

            // Fines Record
            Text(
              'FINES & DUES (${memberFines.length})',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Card(
              child: memberFines.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No fine records on file for this member. Clean account! 👏')),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: memberFines.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final f = memberFines[i];
                        return ListTile(
                          title: Text('\$${f.amount.toStringAsFixed(2)} — ${f.daysOverdue} days overdue'),
                          subtitle: Text('Assessed: ${f.assessedDate.toFormattedDate()} • Loan ref: #${f.borrowingId}'),
                          trailing: Chip(label: Text(f.status.displayName)),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 28),

            // Borrowing History
            Text(
              'PAST BORROWING ARCHIVE (${historyLoans.length})',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Card(
              child: historyLoans.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No historical borrowing transactions recorded yet.')),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: historyLoans.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final loan = historyLoans[i];
                        return ListTile(
                          leading: const Icon(Icons.check_circle_outline, color: AppColors.success),
                          title: Text(loan.bookTitle),
                          subtitle: Text('Returned on: ${loan.returnDate?.toFormattedDate() ?? '—'} (Issued: ${loan.borrowDate.toFormattedDate()})'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
