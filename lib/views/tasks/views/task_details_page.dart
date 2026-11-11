import 'package:flutter/material.dart';

import '../models/task_model.dart';

class TaskDetailsPage extends StatelessWidget {
  final TaskModel task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final date = task.dueDate;
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Task Details',
          style: TextStyle(
            color: Color(0xFF1B2B4F),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B2B4F)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2B4F),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    task.description.isEmpty
                        ? 'No description provided.'
                        : task.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF687087),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Task Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2B4F),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Subject',
                    value: task.subject,
                    icon: Icons.book_outlined,
                  ),
                  _DetailRow(
                    label: 'Priority',
                    value: task.priority,
                    icon: Icons.flag_outlined,
                  ),
                  _DetailRow(
                    label: 'Due Date',
                    value: '${date.day}/${date.month}/${date.year}',
                    icon: Icons.calendar_today_outlined,
                  ),
                  _DetailRow(
                    label: 'Due Time',
                    value: '$hour:$minute $period',
                    icon: Icons.access_time,
                  ),
                  _DetailRow(
                    label: 'Estimated Duration',
                    value: '${task.estimatedDuration} minutes',
                    icon: Icons.hourglass_bottom,
                  ),
                  _DetailRow(
                    label: 'Reminder',
                    value: task.reminder,
                    icon: Icons.notifications_outlined,
                  ),
                  _DetailRow(
                    label: 'Status',
                    value: task.isCompleted ? 'Completed' : 'Incomplete',
                    icon: Icons.check_circle_outline,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6C63FF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF858B9C), fontSize: 13),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF1B2B4F),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
