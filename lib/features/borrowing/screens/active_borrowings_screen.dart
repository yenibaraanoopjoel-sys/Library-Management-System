import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/borrowing_provider.dart';
import '../../../models/borrowing_model.dart';
import '../../../routing/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/enums/borrowing_status.dart';
import '../../../core/extensions/date_extensions.dart';

/// Active circulation loan tracking screen with countdowns, status filters, and quick return actions
class ActiveBorrowingsScreen extends StatefulWidget {
  const ActiveBorrowingsScreen({super.key});

  @override
  State<ActiveBorrowingsScreen> createState() => _ActiveBorrowingsScreenState();
}

class _ActiveBorrowingsScreenState extends State<ActiveBorrowingsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final borrowProv = Provider.of<BorrowingProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= AppDimensions.tabletBreakpoint;

    // If student, only show student's own borrowings
    List<BorrowingModel> loans = borrowProv.filteredBorrowings;
    if (auth.isStudent) {
      loans = loans.where((b) => b.memberId == 'mem_001').toList();
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.isStudent ? 'My Borrowed Books' : 'Circulation & Borrowings',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.isStudent
                          ? 'Track your active loans, due dates, and circulation history.'
                          : 'Manage active book loans, track overdue items, and monitor due dates.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                if (!auth.isStudent)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, RouteNames.issueBook),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Issue New Book'),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Controls & Filter Tabs
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Search
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => borrowProv.setSearchQuery(v),
                        decoration: InputDecoration(
                          hintText: 'Search book title or member name...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    borrowProv.setSearchQuery('');
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    // Status Filter Chips
                    Wrap(
                      spacing: 8,
                      children: ['All', 'Active', 'Due Soon', 'Overdue', 'Returned'].map((tab) {
                        final isSelected = borrowProv.filter == tab;
                        return ChoiceChip(
                          label: Text(tab),
                          selected: isSelected,
                          onSelected: (_) => borrowProv.setFilter(tab),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content Table or Cards
            Expanded(
              child: loans.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.swap_horiz, size: 56, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No borrowings match this filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 6),
                          const Text('Try adjusting your search or switching filter tabs.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : isDesktop
                      ? _buildDesktopTable(context, loans, auth)
                      : _buildMobileCards(context, loans, auth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<BorrowingModel> loans, AuthProvider auth) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Book Title')),
                DataColumn(label: Text('Member / Patron')),
                DataColumn(label: Text('Issued Date')),
                DataColumn(label: Text('Due Date')),
                DataColumn(label: Text('Time Remaining')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: loans.map((loan) {
                final now = DateTime.now();
                final daysRemaining = loan.dueDate.difference(now).inDays;
                final isOverdue = loan.dueDate.isBefore(now) && loan.status != BorrowingStatus.returned;

                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.book, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 240),
                            child: Text(
                              loan.bookTitle,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(loan.memberName, style: const TextStyle(fontSize: 13))),
                    DataCell(Text(loan.borrowDate.toFormattedDate(), style: const TextStyle(fontSize: 12))),
                    DataCell(Text(loan.dueDate.toFormattedDate(), style: const TextStyle(fontSize: 12))),
                    DataCell(
                      loan.status == BorrowingStatus.returned
                          ? const Text('Returned', style: TextStyle(color: Colors.grey, fontSize: 12))
                          : Text(
                              isOverdue ? '$daysRemaining days late' : '$daysRemaining days left',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isOverdue ? AppColors.error : AppColors.success,
                              ),
                            ),
                    ),
                    DataCell(_buildStatusBadge(loan.status, isOverdue)),
                    DataCell(
                      loan.status != BorrowingStatus.returned && !auth.isStudent
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, RouteNames.returns);
                              },
                              child: const Text('Process Return'),
                            )
                          : const Text('—', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCards(BuildContext context, List<BorrowingModel> loans, AuthProvider auth) {
    return ListView.builder(
      itemCount: loans.length,
      itemBuilder: (context, index) {
        final loan = loans[index];
        final now = DateTime.now();
        final daysRemaining = loan.dueDate.difference(now).inDays;
        final isOverdue = loan.dueDate.isBefore(now) && loan.status != BorrowingStatus.returned;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        loan.bookTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    _buildStatusBadge(loan.status, isOverdue),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Borrower: ${loan.memberName}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Due: ${loan.dueDate.toFormattedDate()}', style: const TextStyle(fontSize: 12)),
                    if (loan.status != BorrowingStatus.returned)
                      Text(
                        isOverdue ? '$daysRemaining days overdue' : '$daysRemaining days left',
                        style: TextStyle(
                          color: isOverdue ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                if (loan.status != BorrowingStatus.returned && !auth.isStudent) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, RouteNames.returns),
                      icon: const Icon(Icons.assignment_return, size: 16),
                      label: const Text('Process Return'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(BorrowingStatus status, bool isOverdue) {
    if (status == BorrowingStatus.returned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6)),
        child: const Text('RETURNED', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
      );
    }
    if (isOverdue || status == BorrowingStatus.overdue) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(6)),
        child: const Text('OVERDUE', style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(6)),
      child: const Text('ACTIVE', style: TextStyle(color: AppColors.info, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
