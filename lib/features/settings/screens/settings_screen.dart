import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/auth_provider.dart';

/// Application and circulation settings screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Circulation settings state
  int _defaultLoanDays = 14;
  double _fineRatePerDay = 0.50;
  int _maxBooksPerPatron = 5;
  int _gracePeriodDays = 2;

  // Notification toggles
  bool _emailOverdueAlerts = true;
  bool _dueDateReminders = true;
  bool _newCatalogDigest = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final isAdminOrLibrarian = !auth.isStudent;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Theme & Appearance Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.palette_outlined, color: AppColors.primary),
                            SizedBox(width: 10),
                            Text(
                              'Appearance & Theme',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Customize the look and feel of the library interface.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 18),
                        SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.system,
                              label: Text('System Default'),
                              icon: Icon(Icons.brightness_auto),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text('Light Mode'),
                              icon: Icon(Icons.light_mode),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text('Dark Mode'),
                              icon: Icon(Icons.dark_mode),
                            ),
                          ],
                          selected: {themeProvider.themeMode},
                          onSelectionChanged: (newSelection) {
                            themeProvider.setThemeMode(newSelection.first);
                            AppSnackbar.showSuccess(
                              context,
                              'Theme switched to ${newSelection.first.name} mode.',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Circulation & Lending Policies (Admin/Librarian view)
                if (isAdminOrLibrarian) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.policy_outlined, color: AppColors.secondary),
                              SizedBox(width: 10),
                              Text(
                                'Circulation & Lending Rules',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Configure global circulation limits, loan periods, and overdue penalty calculations.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 20),

                          // Default Loan Duration
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Default Loan Duration'),
                            subtitle: Text('$_defaultLoanDays days from issue date'),
                            trailing: DropdownButton<int>(
                              value: _defaultLoanDays,
                              underline: const SizedBox(),
                              items: [7, 14, 21, 28, 30].map((days) {
                                return DropdownMenuItem(
                                  value: days,
                                  child: Text('$days Days'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _defaultLoanDays = val);
                                  AppSnackbar.showSuccess(context, 'Default loan duration set to $val days.');
                                }
                              },
                            ),
                          ),
                          const Divider(),

                          // Fine Rate Per Day
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Overdue Penalty Rate'),
                            subtitle: Text('\$${_fineRatePerDay.toStringAsFixed(2)} per calendar day overdue'),
                            trailing: DropdownButton<double>(
                              value: _fineRatePerDay,
                              underline: const SizedBox(),
                              items: [0.25, 0.50, 1.00, 1.50, 2.00].map((rate) {
                                return DropdownMenuItem(
                                  value: rate,
                                  child: Text('\$${rate.toStringAsFixed(2)}/day'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _fineRatePerDay = val);
                                  AppSnackbar.showSuccess(context, 'Fine rate updated to \$${val.toStringAsFixed(2)}/day.');
                                }
                              },
                            ),
                          ),
                          const Divider(),

                          // Max Books Per Patron
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Max Active Loans per Patron'),
                            subtitle: Text('$_maxBooksPerPatron maximum simultaneous book checkouts'),
                            trailing: DropdownButton<int>(
                              value: _maxBooksPerPatron,
                              underline: const SizedBox(),
                              items: [3, 5, 7, 10].map((count) {
                                return DropdownMenuItem(
                                  value: count,
                                  child: Text('$count Books'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _maxBooksPerPatron = val);
                                  AppSnackbar.showSuccess(context, 'Max simultaneous loans set to $val.');
                                }
                              },
                            ),
                          ),
                          const Divider(),

                          // Grace Period
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Overdue Grace Period'),
                            subtitle: Text('$_gracePeriodDays days before fines start accruing'),
                            trailing: DropdownButton<int>(
                              value: _gracePeriodDays,
                              underline: const SizedBox(),
                              items: [0, 1, 2, 3, 5].map((days) {
                                return DropdownMenuItem(
                                  value: days,
                                  child: Text('$days Days'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _gracePeriodDays = val);
                                  AppSnackbar.showSuccess(context, 'Grace period set to $val days.');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Notification Preferences
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.notifications_outlined, color: AppColors.accent),
                            SizedBox(width: 10),
                            Text(
                              'Notification Preferences',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Configure automated reminders and notification triggers.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Overdue Alerts'),
                          subtitle: const Text('Trigger high-priority alerts when a return passes its due date'),
                          value: _emailOverdueAlerts,
                          onChanged: (val) {
                            setState(() => _emailOverdueAlerts = val);
                          },
                        ),
                        const Divider(),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Due Date Reminders (48h Notice)'),
                          subtitle: const Text('Send reminder notice 2 days prior to scheduled due date'),
                          value: _dueDateReminders,
                          onChanged: (val) {
                            setState(() => _dueDateReminders = val);
                          },
                        ),
                        const Divider(),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('New Catalog Additions Digest'),
                          subtitle: const Text('Notify patrons when new titles in favorite categories are added'),
                          value: _newCatalogDigest,
                          onChanged: (val) {
                            setState(() => _newCatalogDigest = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // System & Data Backup
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.cloud_download_outlined, color: AppColors.primaryLight),
                            SizedBox(width: 10),
                            Text(
                              'Data & System Operations',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.file_download_outlined),
                                label: const Text('Export Catalog (CSV/JSON)'),
                                onPressed: () {
                                  AppSnackbar.showSuccess(
                                    context,
                                    'Catalog data archive exported successfully.',
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                ),
                                icon: const Icon(Icons.restart_alt),
                                label: const Text('Reset Demo Sandbox'),
                                onPressed: () {
                                  AppDialog.showConfirmation(
                                    context,
                                    title: 'Reset Demo Data',
                                    message: 'Are you sure you want to reset all mock records to default sample state?',
                                    confirmLabel: 'Reset All',
                                    confirmColor: AppColors.error,
                                    onConfirm: () {
                                      AppSnackbar.showInfo(
                                        context,
                                        'Demo dataset reset to default initial state.',
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // About Library System
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey),
                            SizedBox(width: 10),
                            Text(
                              'About Libra System',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Libra System • Integrated Library Management & Circulation Suite\nVersion 1.0.0 (Build 2026.09)\nEngineered with Flutter & Material 3 with full responsive desktop and web layout support.',
                          style: TextStyle(color: Colors.grey, height: 1.4, fontSize: 13),
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
}
