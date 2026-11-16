import 'package:flutter/material.dart';
import 'package:taskora/core/theme/app_colors.dart';

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
        return AppColors.secondary;

      case NotificationType.taskCompleted:
      case NotificationType.goalCompleted:
        return AppColors.success;

      case NotificationType.taskDeleted:
        return AppColors.danger;

      case NotificationType.taskReminder:
      case NotificationType.calendarReminder:
      case NotificationType.goalReminder:
        return AppColors.warning;

      case NotificationType.goalCreated:
      case NotificationType.goalUpdated:
        return AppColors.primary;

      case NotificationType.general:
        return AppColors.primaryDark;
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
      color: notification.isRead
          ? AppColors.cardBackground
          : AppColors.accent.withValues(alpha: 0.09),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: notification.isRead
              ? AppColors.border
              : AppColors.accent.withValues(alpha: 0.4),
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
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),

                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      notification.body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      _formatDate(notification.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),

              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete notification',
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.mutedText,
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
