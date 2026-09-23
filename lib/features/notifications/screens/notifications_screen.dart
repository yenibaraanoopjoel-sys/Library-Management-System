import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../providers/notification_provider.dart';

/// Notifications center screen showing alerts, reminders, and due date notices
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _activeFilter = 'All'; // 'All', 'Unread', 'Due Notices', 'Fines', 'System'

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(context);
    final allNotifications = notifProvider.notifications;
    final unreadCount = notifProvider.unreadCount;

    final filtered = allNotifications.where((n) {
      if (_activeFilter == 'Unread') return !n.isRead;
      if (_activeFilter == 'Due Notices') return n.type == 'due_soon' || n.type == 'overdue';
      if (_activeFilter == 'Fines') return n.type == 'fine';
      if (_activeFilter == 'System') return n.type == 'system' || n.type == 'info';
      return true;
    }).toList();

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Action Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.notifications_active, color: AppColors.primary),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Notification Center',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '$unreadCount unread notices requiring attention',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (unreadCount > 0)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.done_all, size: 18),
                                label: const Text('Mark All Read'),
                                onPressed: () {
                                  notifProvider.markAllAsRead();
                                  AppSnackbar.showSuccess(context, 'All notifications marked as read.');
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Filter Pills
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['All', 'Unread', 'Due Notices', 'Fines', 'System'].map((filter) {
                              final isSelected = _activeFilter == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(
                                    filter == 'Unread' && unreadCount > 0
                                        ? 'Unread ($unreadCount)'
                                        : filter,
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() => _activeFilter = filter);
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

                const SizedBox(height: 20),

                // Notifications List or Empty State
                if (filtered.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48.0),
                    child: Center(
                      child: EmptyState(
                        title: 'No Notifications',
                        message: _activeFilter == 'Unread'
                            ? 'You are all caught up! There are no unread notifications.'
                            : 'No notification records match the selected filter "$_activeFilter".',
                        icon: Icons.notifications_off_outlined,
                      ),
                    ),
                  ),
                ] else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildNotificationCard(item, notifProvider);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(dynamic item, NotificationProvider provider) {
    final isUnread = !item.isRead;
    final color = _getNotificationColor(item.type);
    final icon = _getNotificationIcon(item.type);

    return Card(
      elevation: isUnread ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUnread
            ? BorderSide(color: color.withOpacity(0.4), width: 1.5)
            : BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isUnread) {
            provider.markAsRead(item.id);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimestamp(item.timestamp),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.85)
                            : Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (isUnread)
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.check, size: 14),
                            label: const Text('Mark as read', style: TextStyle(fontSize: 12)),
                            onPressed: () => provider.markAsRead(item.id),
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
    );
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'overdue':
        return AppColors.error;
      case 'due_soon':
      case 'warning':
        return AppColors.warning;
      case 'fine':
        return AppColors.accent;
      case 'success':
      case 'return':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'overdue':
        return Icons.error_outline;
      case 'due_soon':
      case 'warning':
        return Icons.alarm;
      case 'fine':
        return Icons.payment;
      case 'success':
      case 'return':
        return Icons.assignment_turned_in;
      default:
        return Icons.info_outline;
    }
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
    }
  }
}
