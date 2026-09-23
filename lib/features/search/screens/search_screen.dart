import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../providers/book_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/borrowing_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../routing/route_names.dart';

/// Global Search Screen searching across books, members, and borrowings
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeCategory = 'All'; // 'All', 'Books', 'Members', 'Borrowings'
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final memberProvider = Provider.of<MemberProvider>(context);
    final borrowingProvider = Provider.of<BorrowingProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final canViewMembers = !auth.isStudent;

    final categories = [
      'All',
      'Books',
      if (canViewMembers) 'Members',
      'Borrowings',
    ];

    // Filter books
    final matchedBooks = _query.isEmpty
        ? []
        : bookProvider.allBooks.where((b) {
            final q = _query.toLowerCase();
            return b.title.toLowerCase().contains(q) ||
                b.author.toLowerCase().contains(q) ||
                b.isbn.toLowerCase().contains(q) ||
                b.category.toLowerCase().contains(q);
          }).toList();

    // Filter members
    final matchedMembers = (_query.isEmpty || !canViewMembers)
        ? []
        : memberProvider.allMembers.where((m) {
            final q = _query.toLowerCase();
            return m.name.toLowerCase().contains(q) ||
                m.email.toLowerCase().contains(q) ||
                m.phone.toLowerCase().contains(q) ||
                m.id.toLowerCase().contains(q);
          }).toList();

    // Filter borrowings
    final matchedBorrowings = _query.isEmpty
        ? []
        : borrowingProvider.allBorrowings.where((br) {
            final q = _query.toLowerCase();
            return br.bookTitle.toLowerCase().contains(q) ||
                br.memberName.toLowerCase().contains(q) ||
                br.id.toLowerCase().contains(q);
          }).toList();

    final totalResults = matchedBooks.length + matchedMembers.length + matchedBorrowings.length;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Global Search',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Search instantly across catalog books, registered members, and borrowing loans.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    // Search Input
                    TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search by title, author, ISBN, member name, email, loan ID...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => _query = val.trim());
                      },
                    ),
                    const SizedBox(height: 16),
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = _activeCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _activeCategory = cat);
                                }
                              },
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : null,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // When query is empty: show quick suggestions
            if (_query.isEmpty) ...[
              _buildSuggestionsSection(),
            ] else if (totalResults == 0) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0),
                  child: EmptyState(
                    title: 'No Matching Results',
                    message: 'We could not find anything matching "$_query". Try different keywords or check spelling.',
                    icon: Icons.search_off_rounded,
                  ),
                ),
              ),
            ] else ...[
              // Results Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search Results for "$_query"',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalResults found',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Books Results
              if ((_activeCategory == 'All' || _activeCategory == 'Books') && matchedBooks.isNotEmpty) ...[
                _buildSectionHeader('Books (${matchedBooks.length})', Icons.menu_book),
                const SizedBox(height: 8),
                ...matchedBooks.map((book) => _buildBookResultTile(book)),
                const SizedBox(height: 20),
              ],

              // Members Results
              if (canViewMembers && (_activeCategory == 'All' || _activeCategory == 'Members') && matchedMembers.isNotEmpty) ...[
                _buildSectionHeader('Members (${matchedMembers.length})', Icons.people),
                const SizedBox(height: 8),
                ...matchedMembers.map((member) => _buildMemberResultTile(member)),
                const SizedBox(height: 20),
              ],

              // Borrowings Results
              if ((_activeCategory == 'All' || _activeCategory == 'Borrowings') && matchedBorrowings.isNotEmpty) ...[
                _buildSectionHeader('Borrowings & Loans (${matchedBorrowings.length})', Icons.swap_horiz),
                const SizedBox(height: 8),
                ...matchedBorrowings.map((borrowing) => _buildBorrowingResultTile(borrowing)),
                const SizedBox(height: 20),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    final tags = ['Computer Science', 'Fiction', 'Algorithms', 'Science', 'Psychology', 'Design', 'Database'];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 20),
                SizedBox(width: 8),
                Text(
                  'Popular Search Topics',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                return ActionChip(
                  avatar: const Icon(Icons.search, size: 16),
                  label: Text(tag),
                  onPressed: () {
                    _searchController.text = tag;
                    setState(() => _query = tag);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 14),
            const Text(
              'Search Tips:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            const Text('• Enter an ISBN number (e.g. 978-0132350884) for exact book lookup.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            const Text('• Search member email or ID to quickly view account standing and loan history.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            const Text('• Switch tabs above to isolate results to Books, Members, or Loans.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBookResultTile(dynamic book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.menu_book, color: AppColors.primary),
        ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('By ${book.author} • ISBN: ${book.isbn}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    book.category,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${book.availableCopies} of ${book.totalCopies} copies available',
                  style: TextStyle(
                    fontSize: 11,
                    color: book.availableCopies > 0 ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w600,
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
  }

  Widget _buildMemberResultTile(dynamic member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.secondary.withOpacity(0.15),
          child: Text(
            member.name.isNotEmpty ? member.name[0] : 'M',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
          ),
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${member.email} • ${member.phone}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              '${member.activeLoansCount} active loans • Member ID: ${member.id}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pushNamed(context, RouteNames.memberDetails, arguments: member.id);
        },
      ),
    );
  }

  Widget _buildBorrowingResultTile(dynamic borrowing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.swap_horiz, color: AppColors.accent),
        ),
        title: Text(
          borrowing.bookTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Borrower: ${borrowing.memberName} • Loan ID: ${borrowing.id}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              'Due: ${borrowing.dueDate.year}-${borrowing.dueDate.month.toString().padLeft(2, '0')}-${borrowing.dueDate.day.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 11,
                color: borrowing.isOverdue ? AppColors.error : AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pushNamed(context, RouteNames.borrowing);
        },
      ),
    );
  }
}
