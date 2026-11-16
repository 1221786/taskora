import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/upcoming_task_card.dart';
import '../tasks/models/task_model.dart';
import '../tasks/tasks_view.dart';

class UpcomingTasksSection extends StatelessWidget {
  final List<TaskModel> tasks;
  final bool isLoading;

  const UpcomingTasksSection({
    super.key,
    required this.tasks,
    required this.isLoading,
  });

  String _formatDate(DateTime date, bool isOverdue) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    final difference = taskDate.difference(today).inDays;

    String dateLabel;

    if (difference == -1) {
      dateLabel = 'Yesterday';
    } else if (difference == 1) {
      dateLabel = 'Tomorrow';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      dateLabel = '${months[date.month - 1]} ${date.day}, ${date.year}';
    }

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    final time = '$hour:$minute $period';

    return isOverdue ? 'Overdue · $dateLabel · $time' : '$dateLabel · $time';
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final displayedTasks = tasks.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Tasks',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TasksView()),
                );
              },
              child: const Text(
                'See All →',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (displayedTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'No upcoming tasks.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          )
        else
          ...displayedTasks.map((task) {
            final overdue = _isOverdue(task.dueDate);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: UpcomingTaskCard(
                title: task.title,
                subject: task.subject,
                dueDate: _formatDate(task.dueDate, overdue),
                priority: task.priority,
                isOverdue: overdue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TasksView()),
                  );
                },
              ),
            );
          }),
      ],
    );
  }
}
