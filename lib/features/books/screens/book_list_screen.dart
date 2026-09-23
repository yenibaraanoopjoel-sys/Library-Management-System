import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/book_provider.dart';
import '../../../models/book_model.dart';
import '../../../routing/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';

/// Comprehensive Book Catalog Screen with search, category filtering, availability filtering, sorting, and responsive Table/Card views
class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final bookProv = Provider.of<BookProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= AppDimensions.tabletBreakpoint;
    final books = bookProv.filteredBooks;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and Add Book button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book Catalog',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Showing ${books.length} of ${bookProv.allBooks.length} cataloged titles',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                if (!auth.isStudent)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, RouteNames.addBook),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add New Book'),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Controls Bar: Search, Category Filter, Availability Filter, Sort
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Search Input
                    SizedBox(
                      width: 280,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => bookProv.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Search title, author, ISBN...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    bookProv.setSearchQuery('');
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    // Category Dropdown
                    DropdownButton<String>(
                      value: bookProv.selectedCategory,
                      underline: const SizedBox(),
                      borderRadius: BorderRadius.circular(8),
                      items: ['All', ...MockData.categories].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) bookProv.setCategory(v);
                      },
                    ),
                    // Availability Filter
                    DropdownButton<String>(
                      value: bookProv.selectedAvailability,
                      underline: const SizedBox(),
                      borderRadius: BorderRadius.circular(8),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Availability', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'Available', child: Text('In Stock Only', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'Out of Stock', child: Text('Borrowed Out', style: TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) {
                        if (v != null) bookProv.setAvailability(v);
                      },
                    ),
                    // Sort By
                    DropdownButton<String>(
                      value: bookProv.sortBy,
                      underline: const SizedBox(),
                      borderRadius: BorderRadius.circular(8),
                      items: const [
                        DropdownMenuItem(value: 'Title', child: Text('Sort: Title A-Z', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'Year', child: Text('Sort: Newest First', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'Availability', child: Text('Sort: Available Copies', style: TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) {
                        if (v != null) bookProv.setSortBy(v);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content Area: DataTable on Desktop, Cards on Mobile
            Expanded(
              child: books.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off, size: 56, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No books match your criteria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 6),
                          const Text('Try resetting your filters or search terms.', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              _searchController.clear();
                              bookProv.setSearchQuery('');
                              bookProv.setCategory('All');
                              bookProv.setAvailability('All');
                            },
                            child: const Text('Clear All Filters'),
                          ),
                        ],
                      ),
                    )
                  : isDesktop
                      ? _buildDesktopTable(context, books, auth, bookProv)
                      : _buildMobileCards(context, books, auth, bookProv),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable(
    BuildContext context,
    List<BookModel> books,
    AuthProvider auth,
    BookProvider bookProv,
  ) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Book Title & ISBN')),
                DataColumn(label: Text('Author')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Shelf')),
                DataColumn(label: Text('Copies')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: books.map((book) {
                final isAvailable = book.availableCopies > 0;
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.book, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 240),
                                child: Text(
                                  book.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text('ISBN: ${book.isbn}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(book.authorName, style: const TextStyle(fontSize: 13))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(book.categoryName, style: const TextStyle(fontSize: 11, color: Color(0xFF334155))),
                      ),
                    ),
                    DataCell(Text(book.shelfLocation, style: const TextStyle(fontSize: 12))),
                    DataCell(
                      Text(
                        '${book.availableCopies} / ${book.totalCopies}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isAvailable ? AppColors.successLight : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : 'Borrowed',
                          style: TextStyle(
                            color: isAvailable ? AppColors.success : AppColors.error,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'View Details',
                            icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                            onPressed: () {
                              Navigator.pushNamed(context, RouteNames.bookDetails, arguments: book.id);
                            },
                          ),
                          if (!auth.isStudent) ...[
                            IconButton(
                              tooltip: 'Edit Book',
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () {
                                Navigator.pushNamed(context, RouteNames.editBook, arguments: book.id);
                              },
                            ),
                            IconButton(
                              tooltip: 'Delete Book',
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                              onPressed: () async {
                                final confirm = await AppDialog.showConfirmationDialog(
                                  context: context,
                                  title: 'Delete Book',
                                  message: 'Are you sure you want to remove "${book.title}" from the catalog?',
                                  confirmText: 'Delete',
                                );
                                if (confirm == true) {
                                  bookProv.deleteBook(book.id);
                                  if (context.mounted) {
                                    AppSnackbar.showSuccess(context, 'Book removed successfully.');
                                  }
                                }
                              },
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildMobileCards(
    BuildContext context,
    List<BookModel> books,
    AuthProvider auth,
    BookProvider bookProv,
  ) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final isAvailable = book.availableCopies > 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 44,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.book, color: AppColors.primary),
            ),
            title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${book.authorName} • ${book.categoryName}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Shelf: ${book.shelfLocation} • ', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(
                      '${book.availableCopies}/${book.totalCopies} Available',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.bookDetails, arguments: book.id);
            },
          ),
        );
      },
    );
  }
}
