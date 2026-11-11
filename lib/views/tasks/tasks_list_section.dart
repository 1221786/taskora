import 'package:flutter/material.dart';

import '../../widgets/task_management_card.dart';
import '../../widgets/task_empty_state.dart';
import 'models/task_model.dart';

class TasksListSection extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final String title;

  final Future<void> Function(String, bool)? onComplete;
  final Future<void> Function(String)? onDelete;
  final ValueChanged<TaskModel>? onEdit;
  final ValueChanged<TaskModel>? onViewDetails;

  const TasksListSection({
    super.key,
    required this.tasks,
    required this.title,
    this.onComplete,
    this.onDelete,
    this.onEdit,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2B4F),
          ),
        ),

        const SizedBox(height: 14),

        if (tasks.isEmpty)
          const TaskEmptyState()
        else
          ...tasks.map((task) {
            final taskModel = task['task'] as TaskModel;

            return TaskManagementCard(
              title: task['title'] as String,
              description: task['description'] as String,
              subject: task['subject'] as String,
              priority: task['priority'] as String,
              dueDate: task['dueDate'] as String,
              dueTime: task['dueTime'] as String,
              duration: task['duration'] as String,
              isCompleted: task['isCompleted'] as bool,
              isOverdue: task['isOverdue'] as bool,

              // الضغط على البطاقة يفتح التفاصيل
              onTap: () {
                onViewDetails?.call(taskModel);
              },

              // تغيير حالة الإنجاز
              onComplete: () {
                onComplete?.call(taskModel.id, !taskModel.isCompleted);
              },

              // حذف المهمة
              onDelete: () {
                onDelete?.call(taskModel.id);
              },

              // تعديل المهمة
              onEdit: () {
                onEdit?.call(taskModel);
              },
            );
          }),
      ],
    );
  }
}
