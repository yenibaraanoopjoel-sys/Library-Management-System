import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/fine_provider.dart';
import '../../../models/fine_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/enums/fine_status.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../routing/route_names.dart';

/// Fines and dues management screen with summary cards, status filters, and pay/waive actions
class FinesListScreen extends StatefulWidget {
  const FinesListScreen({super.key});

  @override
  State<FinesListScreen> createState() => _FinesListScreenState();
}

class _FinesListScreenState extends State<FinesListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final fineProv = Provider.of<FineProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= AppDimensions.tabletBreakpoint;

    // Filter fines (students only see their own)
    var fines = fineProv.filteredFines;
    if (auth.isStudent) {
      fines = fines.where((f) => f.memberId == 'mem_001').toList();
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.isStudent ? 'My Library Fines & Dues' : 'Fines & Dues Management',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.isStudent
                          ? 'Review any overdue fees assessed on your library membership'
                          : 'Monitor overdue dues, record payments, and manage fee waivers',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Summary Cards Row
            LayoutBuilder(
              builder: (context, constraints) {
                final count = constraints.maxWidth > 900 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: count,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.2,
                  children: [
                    _buildSummaryCard(
                      title: 'Total Outstanding',
                      value: '\$${fineProv.totalOutstandingFines.toStringAsFixed(2)}',
                      icon: Icons.pending_actions,
                      color: AppColors.error,
                    ),
                    _buildSummaryCard(
                      title: 'Total Collected',
                      value: '\$${fineProv.totalCollectedFines.toStringAsFixed(2)}',
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                    _buildSummaryCard(
                      title: 'Pending Fines',
                      value: '${fineProv.unpaidFinesCount}',
                      icon: Icons.receipt_long,
                      color: AppColors.warning,
                    ),
                    _buildSummaryCard(
                      title: 'Settled Payments',
                      value: '${fineProv.paidFinesCount}',
                      icon: Icons.payments,
                      color: AppColors.info,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Controls & Filters Bar
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
                        onChanged: (v) => fineProv.setSearchQuery(v),
                        decoration: InputDecoration(
                          hintText: 'Search by member name or loan ref...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    fineProv.setSearchQuery('');
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    // Filter Chips
                    Wrap(
                      spacing: 8,
                      children: ['All', 'Unpaid', 'Paid', 'Waived'].map((f) {
                        final isSelected = fineProv.filter == f;
                        return ChoiceChip(
                          label: Text(f),
                          selected: isSelected,
                          onSelected: (_) => fineProv.setFilter(f),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fines Table / Cards
            Expanded(
              child: fines.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_outlined, size: 56, color: AppColors.success),
                          const SizedBox(height: 16),
                          const Text('No fines recorded for this filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 6),
                          const Text('All accounts are in good standing.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : isDesktop
                      ? _buildDesktopTable(context, fines, fineProv, auth)
                      : _buildMobileCards(context, fines, fineProv, auth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable(
    BuildContext context,
    List<FineModel> fines,
    FineProvider fineProv,
    AuthProvider auth,
  ) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Member Name')),
                DataColumn(label: Text('Loan Reference')),
                DataColumn(label: Text('Overdue Days')),
                DataColumn(label: Text('Fine Amount')),
                DataColumn(label: Text('Assessed Date')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: fines.map((f) {
                return DataRow(
                  cells: [
                    DataCell(Text(f.memberName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    DataCell(Text('#${f.borrowingId}', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                    DataCell(Text('${f.daysOverdue} days', style: const TextStyle(fontSize: 13))),
                    DataCell(
                      Text(
                        '\$${f.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    DataCell(Text(f.assessedDate.toFormattedDate(), style: const TextStyle(fontSize: 12))),
                    DataCell(_buildStatusBadge(f.status)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'View Receipt & Details',
                            icon: const Icon(Icons.receipt_long, size: 18),
                            onPressed: () {
                              Navigator.pushNamed(context, RouteNames.fineDetails, arguments: f.id);
                            },
                          ),
                          const SizedBox(width: 4),
                          if (f.status == FineStatus.unpaid) ...[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                backgroundColor: AppColors.success,
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              onPressed: () async {
                                final confirm = await AppDialog.showConfirmationDialog(
                                  context: context,
                                  title: 'Collect Fine Payment',
                                  message: 'Confirm payment collection of \$${f.amount.toStringAsFixed(2)} from ${f.memberName}?',
                                  confirmText: 'Record Payment',
                                );
                                if (confirm == true) {
                                  fineProv.payFine(f.id);
                                  if (context.mounted) {
                                    AppSnackbar.showSuccess(context, 'Payment recorded successfully.');
                                  }
                                }
                              },
                              child: const Text('Pay Fine'),
                            ),
                            if (!auth.isStudent) ...[
                              const SizedBox(width: 8),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                onPressed: () async {
                                  final confirm = await AppDialog.showConfirmationDialog(
                                    context: context,
                                    title: 'Waive Fine',
                                    message: 'Are you sure you want to waive \$${f.amount.toStringAsFixed(2)} for ${f.memberName}?',
                                    confirmText: 'Waive Fee',
                                  );
                                  if (confirm == true) {
                                    fineProv.waiveFine(f.id);
                                    if (context.mounted) {
                                      AppSnackbar.showSuccess(context, 'Fine waived.');
                                    }
                                  }
                                },
                                child: const Text('Waive'),
                              ),
                            ],
                          ] else
                            Text(
                              f.status == FineStatus.paid
                                  ? 'Settled on ${f.paidDate?.toFormattedDate() ?? 'record'}'
                                  : 'Waived by Admin',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
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
    List<FineModel> fines,
    FineProvider fineProv,
    AuthProvider auth,
  ) {
    return ListView.builder(
      itemCount: fines.length,
      itemBuilder: (context, index) {
        final f = fines[index];
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
                    Text(f.memberName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    _buildStatusBadge(f.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Amount: \$${f.amount.toStringAsFixed(2)} • ${f.daysOverdue} days overdue', style: const TextStyle(fontSize: 13)),
                Text('Assessed: ${f.assessedDate.toFormattedDate()}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.receipt_long, size: 16),
                      label: const Text('Receipt', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        Navigator.pushNamed(context, RouteNames.fineDetails, arguments: f.id);
                      },
                    ),
                    if (f.status == FineStatus.unpaid) ...[
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        ),
                        onPressed: () {
                          fineProv.payFine(f.id);
                          AppSnackbar.showSuccess(context, 'Payment settled.');
                        },
                        child: const Text('Pay Now', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(FineStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case FineStatus.paid:
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      case FineStatus.unpaid:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        break;
      case FineStatus.waived:
        bg = const Color(0xFFF1F5F9);
        fg = Colors.grey;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
