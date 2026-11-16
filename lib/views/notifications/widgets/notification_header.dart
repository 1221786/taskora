import 'package:flutter/material.dart';
import 'package:taskora/core/theme/app_colors.dart';

class NotificationHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onMarkAllAsRead;

  const NotificationHeader({
    super.key,
    required this.unreadCount,
    this.onMarkAllAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (unreadCount > 0)
                TextButton(
                  onPressed: onMarkAllAsRead,
                  child: const Text(
                    'Mark all as read',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            unreadCount == 0
                ? 'You are all caught up!'
                : 'You have $unreadCount unread '
                      '${unreadCount == 1 ? 'notification' : 'notifications'}.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
