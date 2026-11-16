import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../tasks/models/task_model.dart';

class LinkedTasksSection extends StatelessWidget {
  final List<TaskModel> tasks;
  final bool isUpdating;
  final ValueChanged<String> onRemoveTask;
  final void Function(String taskId, bool isCompleted) onToggleTask;

  const LinkedTasksSection({
    super.key,
    required this.tasks,
    required this.onRemoveTask,
    required this.onToggleTask,
    this.isUpdating = false,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      case 'low':
        return AppColors.priorityLow;
      default:
        return AppColors.mutedText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Linked Tasks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 15),

        if (tasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.task_outlined, size: 35, color: AppColors.mutedText),
                SizedBox(height: 10),
                Text(
                  'No tasks linked to this goal yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.mutedText),
                ),
              ],
            ),
          )
        else
          ...tasks.map((task) {
            final priorityColor = _priorityColor(task.priority);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  // Toggle task completion
                  InkWell(
                    onTap: isUpdating
                        ? null
                        : () => onToggleTask(task.id, !task.isCompleted),
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: task.isCompleted
                            ? AppColors.success
                            : AppColors.mutedText,
                        size: 21,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          task.subject,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: AppColors.mutedText,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _formatDate(task.dueDate),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedText,
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
                      Text(
                        task.priority.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: priorityColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        onPressed: isUpdating
                            ? null
                            : () => onRemoveTask(task.id),
                        tooltip: 'Remove from goal',
                        icon: const Icon(
                          Icons.link_off,
                          size: 19,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
