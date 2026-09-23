import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/borrowing_provider.dart';
import '../../../models/member_model.dart';
import '../../../routing/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';

/// Member Directory Screen with search, status filtering, desktop table, and mobile cards
class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final memberProv = Provider.of<MemberProvider>(context);
    final borrowProv = Provider.of<BorrowingProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= AppDimensions.tabletBreakpoint;
    final members = memberProv.filteredMembers;

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
                      'Member Directory',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage registered students, faculty, and library patrons',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                if (!auth.isStudent)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, RouteNames.addMember),
                    icon: const Icon(Icons.person_add_alt_1, size: 18),
                    label: const Text('Add New Member'),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Controls Bar
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
                      width: 320,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => memberProv.setSearchQuery(v),
                        decoration: InputDecoration(
                          hintText: 'Search by name, email, or member card ID...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    memberProv.setSearchQuery('');
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    // Status Filter
                    DropdownButton<String>(
                      value: memberProv.statusFilter,
                      underline: const SizedBox(),
                      borderRadius: BorderRadius.circular(8),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Statuses', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'active', child: Text('Active Patrons', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'suspended', child: Text('Suspended', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'expired', child: Text('Expired Card', style: TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) {
                        if (v != null) memberProv.setStatusFilter(v);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Directory Table / List
            Expanded(
              child: members.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_off_outlined, size: 56, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No members found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {
                              _searchController.clear();
                              memberProv.setSearchQuery('');
                              memberProv.setStatusFilter('All');
                            },
                            child: const Text('Reset Search Filters'),
                          ),
                        ],
                      ),
                    )
                  : isDesktop
                      ? _buildDesktopTable(context, members, memberProv, borrowProv, auth)
                      : _buildMobileList(context, members, memberProv, borrowProv, auth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable(
    BuildContext context,
    List<MemberModel> members,
    MemberProvider memberProv,
    BorrowingProvider borrowProv,
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
                DataColumn(label: Text('Member Name & Card ID')),
                DataColumn(label: Text('Contact Email')),
                DataColumn(label: Text('Phone')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Active Loans')),
                DataColumn(label: Text('Joined Date')),
                DataColumn(label: Text('Actions')),
              ],
              rows: members.map((mem) {
                final loansCount = borrowProv.allBorrowings.where((b) => b.memberId == mem.id && b.status.name != 'returned').length;

                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryLight.withOpacity(0.15),
                            child: Text(
                              mem.name.isNotEmpty ? mem.name[0] : 'M',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(mem.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(mem.membershipNumber, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(mem.email, style: const TextStyle(fontSize: 13))),
                    DataCell(Text(mem.phone, style: const TextStyle(fontSize: 12))),
                    DataCell(_buildStatusBadge(mem.status)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: loansCount > 0 ? AppColors.infoLight : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$loansCount / ${mem.maxBooksAllowed}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: loansCount > 0 ? AppColors.info : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(mem.joinedDate?.toFormattedDate() ?? '—', style: const TextStyle(fontSize: 12))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'View Profile',
                            icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                            onPressed: () {
                              Navigator.pushNamed(context, RouteNames.memberDetails, arguments: mem.id);
                            },
                          ),
                          if (!auth.isStudent) ...[
                            IconButton(
                              tooltip: 'Edit Member',
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () {
                                Navigator.pushNamed(context, RouteNames.editMember, arguments: mem.id);
                              },
                            ),
                            IconButton(
                              tooltip: 'Delete Member',
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                              onPressed: () async {
                                final confirm = await AppDialog.showConfirmationDialog(
                                  context: context,
                                  title: 'Delete Member',
                                  message: 'Are you sure you want to remove ${mem.name} from the library system?',
                                  confirmText: 'Delete',
                                );
                                if (confirm == true) {
                                  memberProv.deleteMember(mem.id);
                                  if (context.mounted) {
                                    AppSnackbar.showSuccess(context, 'Member removed.');
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

  Widget _buildMobileList(
    BuildContext context,
    List<MemberModel> members,
    MemberProvider memberProv,
    BorrowingProvider borrowProv,
    AuthProvider auth,
  ) {
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final mem = members[index];
        final loansCount = borrowProv.allBorrowings.where((b) => b.memberId == mem.id && b.status.name != 'returned').length;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight.withOpacity(0.15),
              child: Text(
                mem.name.isNotEmpty ? mem.name[0] : 'M',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight),
              ),
            ),
            title: Text(mem.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${mem.membershipNumber} • $loansCount active loans'),
            trailing: _buildStatusBadge(mem.status),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.memberDetails, arguments: mem.id);
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'active':
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      case 'suspended':
        bg = AppColors.errorLight;
        fg = AppColors.error;
        break;
      case 'expired':
      default:
        bg = const Color(0xFFF1F5F9);
        fg = Colors.grey;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
