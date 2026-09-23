import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/borrowing_provider.dart';
import '../../../providers/fine_provider.dart';
import '../../../routing/route_names.dart';

/// User profile screen displaying account details, role, digital membership card, and statistics
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final borrowingProvider = Provider.of<BorrowingProvider>(context);
    final fineProvider = Provider.of<FineProvider>(context);

    final activeLoans = borrowingProvider.activeBorrowings.length;
    final totalFines = fineProvider.totalOutstandingFines;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Card with Avatar and Basic Info
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            user != null && user.name.isNotEmpty
                                ? user.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user?.name ?? 'Alexander Morgan',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildRoleBadge(auth.role),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user?.email ?? 'admin@library.com',
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'User ID: ${user?.id ?? 'usr_demo'} • Member since ${_formatDate(user?.createdAt ?? DateTime.now())}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit Profile'),
                          onPressed: () {
                            Navigator.pushNamed(context, '${RouteNames.profile}/edit');
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Digital Membership Card
                _buildDigitalLibraryCard(context, auth, user),

                const SizedBox(height: 24),

                // Patron Activity Summary Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        context,
                        title: 'Active Loans',
                        value: '$activeLoans',
                        icon: Icons.book_online,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatTile(
                        context,
                        title: 'Total Borrowed',
                        value: '${borrowingProvider.allBorrowings.length}',
                        icon: Icons.history,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatTile(
                        context,
                        title: 'Outstanding Fines',
                        value: '\$${totalFines.toStringAsFixed(2)}',
                        icon: Icons.payments_outlined,
                        color: totalFines > 0 ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Account Settings & Security Options
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account & Security',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.lock_reset, color: AppColors.primary),
                          title: const Text('Change Password'),
                          subtitle: const Text('Update your login password and credentials'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showChangePasswordDialog(context),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.switch_account, color: AppColors.secondary),
                          title: const Text('Role Switcher (Demo Sandbox)'),
                          subtitle: Text('Currently previewing: ${auth.role.displayName}'),
                          trailing: DropdownButton<UserRole>(
                            value: auth.role,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
                              DropdownMenuItem(value: UserRole.librarian, child: Text('Librarian')),
                              DropdownMenuItem(value: UserRole.member, child: Text('Student/Member')),
                            ],
                            onChanged: (role) {
                              if (role != null) {
                                auth.loginAsRole(role);
                                AppSnackbar.showSuccess(
                                  context,
                                  'Switched role to ${role.displayName}',
                                );
                              }
                            },
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.logout, color: AppColors.error),
                          title: const Text('Log Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Sign out of this workstation session'),
                          onTap: () {
                            AppDialog.showConfirmation(
                              context,
                              title: 'Log Out',
                              message: 'Are you sure you want to log out of your session?',
                              confirmLabel: 'Log Out',
                              confirmColor: AppColors.error,
                              onConfirm: () {
                                auth.logout();
                                Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (r) => false);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalLibraryCard(BuildContext context, AuthProvider auth, dynamic user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_library, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'LIBRA SYSTEM PASS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.nfc, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'DIGITAL PASS',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CARDHOLDER NAME',
                    style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (user?.name ?? 'Alexander Morgan').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'MEMBERSHIP ID',
                    style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.id ?? 'LIB-2026-0891',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'monospace',
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.qr_code_2, color: Colors.white70, size: 56),
                  const SizedBox(height: 4),
                  Text(
                    'VALID THRU: 12/2028',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    Color color;
    switch (role) {
      case UserRole.admin:
        color = AppColors.primary;
        break;
      case UserRole.librarian:
        color = AppColors.secondary;
        break;
      case UserRole.member:
        color = AppColors.accent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        role.displayName,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'Current Password',
                  hint: 'Enter your current password',
                  obscureText: true,
                  controller: currentPwController,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'New Password',
                  hint: 'Enter new strong password',
                  obscureText: true,
                  controller: newPwController,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Confirm New Password',
                  hint: 'Re-enter new password',
                  obscureText: true,
                  controller: confirmPwController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (newPwController.text.length < 6) {
                  AppSnackbar.showError(dialogCtx, 'Password must be at least 6 characters.');
                  return;
                }
                if (newPwController.text != confirmPwController.text) {
                  AppSnackbar.showError(dialogCtx, 'New passwords do not match.');
                  return;
                }
                Navigator.pop(dialogCtx);
                AppSnackbar.showSuccess(context, 'Password updated successfully!');
              },
              child: const Text('Update Password'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
