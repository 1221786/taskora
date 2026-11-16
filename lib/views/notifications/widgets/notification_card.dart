import 'package:flutter/material.dart';

import '../models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.taskCreated:
      case NotificationType.taskUpdated:
      case NotificationType.taskCompleted:
      case NotificationType.taskDeleted:
      case NotificationType.taskReminder:
        return Icons.task_alt_rounded;

      case NotificationType.goalCreated:
      case NotificationType.goalUpdated:
      case NotificationType.goalCompleted:
      case NotificationType.goalReminder:
        return Icons.flag_rounded;

      case NotificationType.calendarReminder:
        return Icons.calendar_month_rounded;

      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor() {
    switch (notification.type) {
      case NotificationType.taskCreated:
      case NotificationType.taskUpdated:
        return Colors.blue;

      case NotificationType.taskCompleted:
      case NotificationType.goalCompleted:
        return Colors.green;

      case NotificationType.taskDeleted:
        return Colors.red;

      case NotificationType.taskReminder:
      case NotificationType.calendarReminder:
      case NotificationType.goalReminder:
        return Colors.orange;

      case NotificationType.goalCreated:
      case NotificationType.goalUpdated:
        return Colors.purple;

      case NotificationType.general:
        return Colors.blueGrey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60 && !difference.isNegative) {
      return 'Just now';
    }

    if (difference.inMinutes < 60 && !difference.isNegative) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24 && !difference.isNegative) {
      return '${difference.inHours} hours ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getNotificationColor();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead ? Colors.white : const Color(0xFFF0F0FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: notification.isRead
              ? Colors.grey.shade200
              : const Color(0xFF6C63FF).withValues(alpha: 0.25),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_getNotificationIcon(), color: color, size: 23),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: const Color(0xFF252542),
                            ),
                          ),
                        ),

                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6C63FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete notification',
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.grey.shade500,
                    size: 21,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
