import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class UpcomingTaskCard extends StatelessWidget {
  final String title;
  final String subject;
  final String dueDate;
  final String priority;
  final bool isOverdue;
  final VoidCallback? onTap;

  const UpcomingTaskCard({
    super.key,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.priority,
    this.isOverdue = false,
    this.onTap,
  });

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      default:
        return AppColors.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: isOverdue ? AppColors.overdueBorder : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: isOverdue
                    ? AppColors.overdueBackground
                    : AppColors.primaryLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isOverdue
                    ? Icons.warning_amber_rounded
                    : Icons.calendar_today_rounded,
                color: isOverdue ? AppColors.danger : AppColors.primary,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.mutedText,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 12,
                        color: isOverdue
                            ? AppColors.danger
                            : AppColors.mutedText,
                      ),

                      const SizedBox(width: 4),

                      Flexible(
                        child: Text(
                          dueDate,
                          style: TextStyle(
                            fontSize: 10,
                            color: isOverdue
                                ? AppColors.danger
                                : AppColors.mutedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                if (isOverdue)
                  const Text(
                    'Overdue',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
