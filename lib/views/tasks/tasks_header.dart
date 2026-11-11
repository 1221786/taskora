import 'package:flutter/material.dart';

class TasksHeader extends StatelessWidget {
  final VoidCallback onAddTask;
  final VoidCallback onOpenCalendar;

  const TasksHeader({
    super.key,
    required this.onAddTask,
    required this.onOpenCalendar,
  });

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
                color: Color(0xFF1B2B4F),
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Manage your daily tasks',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),

        Row(
          children: [
            // Calendar Button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                onPressed: onOpenCalendar,
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFF6C63FF),
                  size: 23,
                ),
                tooltip: 'Calendar',
              ),
            ),

            const SizedBox(width: 8),

            // Add Task Button
            ElevatedButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add, size: 19),
              label: const Text('Add Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
