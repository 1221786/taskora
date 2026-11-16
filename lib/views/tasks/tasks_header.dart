import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TasksHeader extends StatelessWidget {
  final VoidCallback onOpenCalendar;

  const TasksHeader({super.key, required this.onOpenCalendar});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Tasks',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Manage your daily tasks',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),

        // Calendar Button
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            onPressed: onOpenCalendar,
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primary,
              size: 23,
            ),
            tooltip: 'Calendar',
          ),
        ),
      ],
    );
  }
}
