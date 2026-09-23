import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/book_provider.dart';
import '../../../providers/borrowing_provider.dart';
import '../../../routing/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/extensions/date_extensions.dart';

/// Comprehensive Book Details Screen showing complete metadata, stock meter, and circulation actions
class BookDetailsScreen extends StatelessWidget {
  final String bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final bookProv = Provider.of<BookProvider>(context);
    final borrowProv = Provider.of<BorrowingProvider>(context);

    final book = bookProv.getBookById(bookId);

    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Not Found')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('The requested book does not exist in the catalog.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Return to Catalog'),
              ),
            ],
          ),
        ),
      );
    }

    final isAvailable = book.availableCopies > 0;
    final activeLoans = borrowProv.allBorrowings.where((b) => b.bookId == book.id && b.status.name != 'returned').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (!auth.isStudent) ...[
            IconButton(
              tooltip: 'Edit Book',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.editBook, arguments: book.id);
              },
            ),
            IconButton(
              tooltip: 'Delete Book',
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () async {
                final confirm = await AppDialog.showConfirmationDialog(
                  context: context,
                  title: 'Delete Book',
                  message: 'Are you sure you want to permanently delete "${book.title}"?',
                  confirmText: 'Delete',
                );
                if (confirm == true) {
                  bookProv.deleteBook(book.id);
                  if (context.mounted) {
                    AppSnackbar.showSuccess(context, 'Book deleted.');
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
            // Top Hero Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Cover Placeholder
                    Container(
                      width: 140,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.book, size: 56, color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text(
                            book.categoryName,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Details Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAvailable ? AppColors.successLight : AppColors.errorLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isAvailable ? 'AVAILABLE FOR BORROWING' : 'CURRENTLY OUT OF STOCK',
                              style: TextStyle(
                                color: isAvailable ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            book.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'By ${book.authorName}',
                            style: const TextStyle(fontSize: 16, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          // Stock meter
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: book.totalCopies > 0 ? book.availableCopies / book.totalCopies : 0,
                                    minHeight: 10,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isAvailable ? AppColors.success : AppColors.error,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${book.availableCopies} of ${book.totalCopies} copies in library',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Action Buttons
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              if (isAvailable && !auth.isStudent)
                                AppButton(
                                  text: 'Issue Book to Member',
                                  icon: Icons.assignment_turned_in_outlined,
                                  onPressed: () {
                                    Navigator.pushNamed(context, RouteNames.issueBook);
                                  },
                                ),
                              if (auth.isStudent && isAvailable)
                                AppButton(
                                  text: 'Reserve / Request Copy',
                                  icon: Icons.bookmark_border,
                                  onPressed: () {
                                    AppSnackbar.showSuccess(context, 'Reservation placed. Please collect from circulation desk.');
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Metadata & Specs Grid
            Text(
              'CATALOG SPECIFICATIONS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 40,
                  runSpacing: 20,
                  children: [
                    _buildSpecItem('ISBN', book.isbn),
                    _buildSpecItem('Category', book.categoryName),
                    _buildSpecItem('Publisher', book.publisher),
                    _buildSpecItem('Year Published', '${book.publishedYear}'),
                    _buildSpecItem('Shelf Location', book.shelfLocation),
                    _buildSpecItem('Catalog Status', book.status.displayName),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Active Loans of this Title
            if (!auth.isStudent) ...[
              Text(
                'ACTIVE BORROWERS FOR THIS TITLE (${activeLoans.length})',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Card(
                child: activeLoans.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('No copies are currently checked out.')),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activeLoans.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final loan = activeLoans[i];
                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person, size: 18)),
                            title: Text(loan.memberName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Borrowed: ${loan.borrowDate.toFormattedDate()} • Due: ${loan.dueDate.toFormattedDate()}'),
                            trailing: TextButton(
                              onPressed: () => Navigator.pushNamed(context, RouteNames.returns),
                              child: const Text('Process Return'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
