import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/task_card.dart';
import '../tasks/models/task_model.dart';
import '../tasks/tasks_view.dart';

class TodayTasksSection extends StatelessWidget {
  final List<TaskModel> tasks;
  final bool isLoading;
  final void Function(TaskModel task) onToggle;
  final void Function(String taskId) onDelete;

  const TodayTasksSection({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.onToggle,
    required this.onDelete,
  });

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Tasks",
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
        else if (tasks.isEmpty)
          const _EmptyTasksMessage(message: 'No tasks scheduled for today.')
        else
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskCard(
                title: task.title,
                subject: task.subject,
                priority: task.priority,
                dueTime: _formatTime(task.dueDate),
                isCompleted: task.isCompleted,
                onCheckboxTap: () => onToggle(task),
                onDelete: () => onDelete(task.id),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyTasksMessage extends StatelessWidget {
  final String message;

  const _EmptyTasksMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}
