import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/goal_model.dart';
import 'goal_progress_indicator.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;
  final double progress;
  final int completedTasks;
  final int totalTasks;
  final String status;

  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddTask;

  final bool isSelectionMode;
  final VoidCallback? onSelect;

  const GoalCard({
    super.key,
    required this.goal,
    required this.progress,
    required this.completedTasks,
    required this.totalTasks,
    required this.status,
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
    required this.onAddTask,
    this.isSelectionMode = false,
    this.onSelect,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _statusColor() {
    switch (status) {
      case 'Completed':
        return AppColors.success;
      case 'Overdue':
        return AppColors.danger;
      case 'In Progress':
        return AppColors.primary;
      default:
        return AppColors.mutedText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return InkWell(
      onTap: isSelectionMode ? onSelect : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            if (goal.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                goal.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _DateInfo(
                    label: 'Start Date',
                    date: _formatDate(goal.startDate),
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
                Expanded(
                  child: _DateInfo(
                    label: 'Target Date',
                    date: _formatDate(goal.targetDate),
                    icon: Icons.flag_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 9),

            GoalProgressIndicator(progress: progress, showPercentage: false),

            const SizedBox(height: 10),

            Text(
              '$completedTasks/$totalTasks Tasks Completed',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 18),

            const Divider(color: AppColors.border),

            const SizedBox(height: 8),

            if (isSelectionMode)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSelect,
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Select This Goal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ActionButton(
                    label: 'Details',
                    icon: Icons.visibility_outlined,
                    onTap: onViewDetails,
                  ),
                  _ActionButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    onTap: onEdit,
                  ),
                  _ActionButton(
                    label: 'Add Task',
                    icon: Icons.add_task,
                    onTap: onAddTask,
                  ),
                  _ActionButton(
                    label: 'Delete',
                    icon: Icons.delete_outline,
                    color: AppColors.danger,
                    onTap: onDelete,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final String date;
  final IconData icon;

  const _DateInfo({
    required this.label,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
