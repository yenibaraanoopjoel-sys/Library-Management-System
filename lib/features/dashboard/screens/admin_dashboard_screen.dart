import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/book_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/borrowing_provider.dart';
import '../../../providers/fine_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../routing/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/borrowing_status.dart';
import '../../../core/extensions/date_extensions.dart';

/// Admin and Librarian Management Dashboard with live statistics, quick actions, and recent activity
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final bookProv = Provider.of<BookProvider>(context);
    final memberProv = Provider.of<MemberProvider>(context);
    final borrowProv = Provider.of<BorrowingProvider>(context);
    final fineProv = Provider.of<FineProvider>(context);
    final dashProv = Provider.of<DashboardProvider>(context);

    final totalBooks = bookProv.allBooks.fold<int>(0, (sum, b) => sum + b.totalCopies);
    final availableBooks = bookProv.allBooks.fold<int>(0, (sum, b) => sum + b.availableCopies);
    final issuedBooks = totalBooks - availableBooks;
    final totalMembers = memberProv.allMembers.length;
    final overdueCount = borrowProv.overdueBorrowings.length;
    final outstandingFines = fineProv.totalOutstandingFines;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with greeting & quick role badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, ${auth.currentUser?.name ?? 'Administrator'} 👋',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here is your library operations summary for today.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                // Today date pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.primaryLight),
                      const SizedBox(width: 8),
                      Text(
                        DateTime.now().toFormattedDate(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions Row
            Text(
              'QUICK ACTIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickActionButton(
                  context,
                  label: 'Issue Book',
                  icon: Icons.add_circle_outline,
                  color: AppColors.primary,
                  onTap: () => Navigator.pushNamed(context, RouteNames.issueBook),
                ),
                _buildQuickActionButton(
                  context,
                  label: 'Process Return',
                  icon: Icons.assignment_return_outlined,
                  color: AppColors.secondary,
                  onTap: () => Navigator.pushNamed(context, RouteNames.returns),
                ),
                if (auth.isAdmin || auth.isLibrarian) ...[
                  _buildQuickActionButton(
                    context,
                    label: 'Add New Book',
                    icon: Icons.bookmark_add_outlined,
                    color: const Color(0xFF6366F1),
                    onTap: () => Navigator.pushNamed(context, RouteNames.addBook),
                  ),
                  _buildQuickActionButton(
                    context,
                    label: 'Add Member',
                    icon: Icons.person_add_outlined,
                    color: const Color(0xFF0EA5E9),
                    onTap: () => Navigator.pushNamed(context, RouteNames.addMember),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 28),

            // Statistics Grid (6 Cards)
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1100
                    ? 6
                    : constraints.maxWidth > 800
                        ? 3
                        : 2;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard(
                      context,
                      title: 'Total Books',
                      value: '$totalBooks',
                      subtitle: '${bookProv.allBooks.length} distinct titles',
                      icon: Icons.menu_book,
                      color: AppColors.primaryLight,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Available Books',
                      value: '$availableBooks',
                      subtitle: 'Ready to circulate',
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Issued Books',
                      value: '$issuedBooks',
                      subtitle: '${borrowProv.activeBorrowings.length} active loans',
                      icon: Icons.swap_horiz,
                      color: AppColors.secondary,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Total Members',
                      value: '$totalMembers',
                      subtitle: 'Registered patrons',
                      icon: Icons.people_outline,
                      color: const Color(0xFF8B5CF6),
                    ),
                    _buildStatCard(
                      context,
                      title: 'Overdue Loans',
                      value: '$overdueCount',
                      subtitle: 'Exceeded due date',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.error,
                      isAlert: overdueCount > 0,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Outstanding Fines',
                      value: '\$${outstandingFines.toStringAsFixed(2)}',
                      subtitle: '${fineProv.unpaidFinesCount} pending fines',
                      icon: Icons.payments_outlined,
                      color: AppColors.warning,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Middle Section: Overdue Alerts & Category Breakdown
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overdue Books Alert Section
                Expanded(
                  flex: 6,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.alarm, color: AppColors.error, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Overdue Loans Requiring Follow-Up',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, RouteNames.borrowing),
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const Divider(),
                          if (borrowProv.overdueBorrowings.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(
                                child: Text('No overdue loans currently. All books returned on time! 🎉'),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: borrowProv.overdueBorrowings.take(4).length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final loan = borrowProv.overdueBorrowings[i];
                                final daysOver = DateTime.now().difference(loan.dueDate).inDays;
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(loan.bookTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  subtitle: Text('Borrower: ${loan.memberName} • Due: ${loan.dueDate.toFormattedDate()}'),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$daysOver days late',
                                      style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Recent Activity Feed
                Expanded(
                  flex: 5,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.history, color: AppColors.primaryLight, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Recent System Activity',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const Divider(),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dashProv.recentActivities.take(5).length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final act = dashProv.recentActivities[i];
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primaryLight.withOpacity(0.15),
                                  child: Icon(_getActivityIcon(act.entityType), size: 14, color: AppColors.primaryLight),
                                ),
                                title: Text(act.action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                subtitle: Text('${act.userName} • ${act.timestamp.toFormattedDateTime()}', style: const TextStyle(fontSize: 11)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Borrowings Section Table
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Circulation Transactions',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, RouteNames.borrowing),
                          child: const Text('View All Borrowings'),
                        ),
                      ],
                    ),
                    const Divider(),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Book Title')),
                          DataColumn(label: Text('Member')),
                          DataColumn(label: Text('Borrowed Date')),
                          DataColumn(label: Text('Due Date')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: borrowProv.allBorrowings.take(5).map((loan) {
                          return DataRow(
                            cells: [
                              DataCell(Text(loan.bookTitle, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(loan.memberName)),
                              DataCell(Text(loan.borrowDate.toFormattedDate())),
                              DataCell(Text(loan.dueDate.toFormattedDate())),
                              DataCell(_buildBorrowStatusBadge(loan.status)),
                              DataCell(
                                loan.status != BorrowingStatus.returned
                                    ? TextButton(
                                        child: const Text('Return Book'),
                                        onPressed: () {
                                          Navigator.pushNamed(context, RouteNames.returns);
                                        },
                                      )
                                    : const Text('—', style: TextStyle(color: Colors.grey)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isAlert = false,
  }) {
    return Card(
      color: isAlert ? AppColors.errorLight : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isAlert ? AppColors.error : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isAlert ? AppColors.error : null,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isAlert ? AppColors.error : Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorrowStatusBadge(BorrowingStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case BorrowingStatus.active:
        bg = AppColors.infoLight;
        fg = AppColors.info;
        break;
      case BorrowingStatus.returned:
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      case BorrowingStatus.overdue:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        status.displayName,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  IconData _getActivityIcon(String entityType) {
    switch (entityType) {
      case 'book':
        return Icons.menu_book;
      case 'member':
        return Icons.person;
      case 'borrowing':
        return Icons.swap_horiz;
      case 'fine':
        return Icons.payments;
      default:
        return Icons.info_outline;
    }
  }
}
