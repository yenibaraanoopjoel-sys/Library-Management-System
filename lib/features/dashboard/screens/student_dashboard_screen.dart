import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/book_provider.dart';
import '../../../providers/borrowing_provider.dart';
import '../../../providers/fine_provider.dart';
import '../../../routing/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/date_extensions.dart';

/// Student / Member personalized library portal view
class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final bookProv = Provider.of<BookProvider>(context);
    final borrowProv = Provider.of<BorrowingProvider>(context);
    final fineProv = Provider.of<FineProvider>(context);

    // Current student's loans (mem_001 Ethan Brown)
    final myLoans = borrowProv.allBorrowings.where((b) => b.memberId == 'mem_001').toList();
    final myActiveLoans = myLoans.where((b) => b.status.name != 'returned').toList();
    final myFines = fineProv.allFines.where((f) => f.memberId == 'mem_001' && f.status.name == 'unpaid').toList();
    final totalFineDue = myFines.fold<double>(0.0, (sum, f) => sum + f.amount);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Welcome Banner Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STUDENT BORROWING PORTAL',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome, ${auth.currentUser?.name ?? 'Ethan Brown'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Membership Card: LIB-2026-001 • Status: Active (Max 3 Books Allowed)',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, RouteNames.books),
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Browse Catalog'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Outstanding Fine Warning Banner (if any)
            if (totalFineDue > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Outstanding Fine Notice',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 14),
                          ),
                          Text(
                            'You have \$${totalFineDue.toStringAsFixed(2)} in pending overdue fines. Please clear dues at the circulation desk.',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, RouteNames.fines),
                      child: const Text('View Fines', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Currently Borrowed Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CURRENTLY BORROWED (${myActiveLoans.length}/3)',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, RouteNames.borrowing),
                  child: const Text('Borrowing History'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (myActiveLoans.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.menu_book, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('You have no active loans.', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Search the catalog to discover books and borrow them from the desk.', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, RouteNames.books),
                          child: const Text('Explore Catalog'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myActiveLoans.length,
                itemBuilder: (context, index) {
                  final loan = myActiveLoans[index];
                  final now = DateTime.now();
                  final daysRemaining = loan.dueDate.difference(now).inDays;
                  final isDueSoon = daysRemaining <= 3 && daysRemaining >= 0;
                  final isOverdue = loan.dueDate.isBefore(now);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.book, color: AppColors.primaryLight),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loan.bookTitle,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Borrowed: ${loan.borrowDate.toFormattedDate()} • Due: ${loan.dueDate.toFormattedDate()}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isOverdue
                                  ? AppColors.errorLight
                                  : isDueSoon
                                      ? AppColors.warningLight
                                      : AppColors.successLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isOverdue
                                  ? 'Overdue'
                                  : isDueSoon
                                      ? 'Due in $daysRemaining days'
                                      : '$daysRemaining days left',
                              style: TextStyle(
                                color: isOverdue
                                    ? AppColors.error
                                    : isDueSoon
                                        ? AppColors.warning
                                        : AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),

            // Recommended / Available Books Highlights
            const Text(
              'RECOMMENDED IN THE CATALOG',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 600 ? 2 : 1;
                final availableBooks = bookProv.allBooks.where((b) => b.availableCopies > 0).take(4).toList();

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: availableBooks.length,
                  itemBuilder: (context, i) {
                    final book = availableBooks[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    book.categoryName,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  book.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  book.authorName,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Shelf: ${book.shelfLocation}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                Text(
                                  '${book.availableCopies} available',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
