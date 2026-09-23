import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/borrowing_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/borrowing_status.dart';
import '../../../core/extensions/date_extensions.dart';

/// Historical archive of completed and returned borrowing transactions
class BorrowingHistoryScreen extends StatefulWidget {
  final String? memberId;

  const BorrowingHistoryScreen({super.key, this.memberId});

  @override
  State<BorrowingHistoryScreen> createState() => _BorrowingHistoryScreenState();
}

class _BorrowingHistoryScreenState extends State<BorrowingHistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borrowProv = Provider.of<BorrowingProvider>(context);

    // Filter returned loans
    var history = borrowProv.allBorrowings.where((b) {
      final isMemberMatch = widget.memberId == null || b.memberId == widget.memberId;
      final isReturned = b.status == BorrowingStatus.returned;
      final matchesSearch = _searchQuery.isEmpty ||
          b.bookTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.memberName.toLowerCase().contains(_searchQuery.toLowerCase());
      return isMemberMatch && isReturned && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrowing History Archive'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Circulation Archive',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Audit record of all successfully returned book loans',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search archive...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history_toggle_off, size: 56, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No historical loan records found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 6),
                          const Text('Returned books will automatically appear in this archive.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : Card(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SingleChildScrollView(
                          child: SizedBox(
                            width: double.infinity,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Book Title')),
                                DataColumn(label: Text('Patron / Member')),
                                DataColumn(label: Text('Borrowed On')),
                                DataColumn(label: Text('Due Date')),
                                DataColumn(label: Text('Returned On')),
                                DataColumn(label: Text('Issued By')),
                              ],
                              rows: history.map((loan) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.book, size: 16, color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Text(loan.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text(loan.memberName, style: const TextStyle(fontSize: 13))),
                                    DataCell(Text(loan.borrowDate.toFormattedDate(), style: const TextStyle(fontSize: 12))),
                                    DataCell(Text(loan.dueDate.toFormattedDate(), style: const TextStyle(fontSize: 12))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.successLight,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          loan.returnDate?.toFormattedDate() ?? 'Completed',
                                          style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(loan.issuedBy, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
