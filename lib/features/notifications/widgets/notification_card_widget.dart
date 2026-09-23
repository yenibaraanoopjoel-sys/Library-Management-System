import 'package:flutter/material.dart';

/// Notification item card displaying icon, title, message, and timestamp
class NotificationCardWidget extends StatelessWidget {
  final String title;
  final String message;
  final String timeAgo;
  final bool isRead;
  final VoidCallback? onTap;

  const NotificationCardWidget({
    super.key,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          isRead ? Icons.notifications_none : Icons.notifications_active,
          color: isRead ? Colors.grey : Colors.blue,
        ),
        title: Text(title),
        subtitle: Text(message),
        trailing: Text(timeAgo, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}
