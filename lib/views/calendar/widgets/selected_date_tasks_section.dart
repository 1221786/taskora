import 'package:flutter/material.dart';

import '../../tasks/models/task_model.dart';

class SelectedDateTasksSection extends StatelessWidget {
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? errorMessage;

  const SelectedDateTasksSection({
    super.key,
    required this.tasks,
    required this.isLoading,
    this.errorMessage,
  });

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFE85D5D);
      case 'medium':
        return const Color(0xFFE5A93D);
      case 'low':
        return const Color(0xFF45B77A);
      default:
        return const Color(0xFF9297A5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Tasks",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2B4F),
            ),
          ),

          const SizedBox(height: 15),

          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
              ),
            )
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else if (tasks.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E8EF)),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 35,
                    color: Color(0xFF9297A5),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No tasks for this date',
                    style: TextStyle(fontSize: 14, color: Color(0xFF9297A5)),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E8EF)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 55,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(5),
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
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1B2B4F),
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            task.subject,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9297A5),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Color(0xFF9297A5),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _formatTime(task.dueDate),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9297A5),
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

                        const SizedBox(height: 10),

                        Icon(
                          task.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: task.isCompleted
                              ? const Color(0xFF45B77A)
                              : const Color(0xFF9297A5),
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
