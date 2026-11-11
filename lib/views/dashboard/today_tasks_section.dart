import 'package:flutter/material.dart';
import '../../widgets/task_card.dart';
import '../tasks/tasks_view.dart';

class TodayTasksSection extends StatelessWidget {
  const TodayTasksSection({super.key});

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
                color: Color(0xFF1B2B4F),
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
                style: TextStyle(fontSize: 12, color: Color(0xFF6C63FF)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        const TaskCard(
          title: 'Mobile Assignment',
          subject: 'Mobile Development',
          priority: 'High',
          dueTime: '06:00 PM',
        ),

        const SizedBox(height: 12),

        const TaskCard(
          title: 'Database Assignment',
          subject: 'Database',
          priority: 'Medium',
          dueTime: '08:00 PM',
        ),

        const SizedBox(height: 12),

        const TaskCard(
          title: 'Study Chapter 4',
          subject: 'Software Engineering',
          priority: 'Low',
          dueTime: '09:00 PM',
          isCompleted: true,
        ),

        const SizedBox(height: 12),

        const TaskCard(
          title: 'Flutter Practice',
          subject: 'Mobile Development',
          priority: 'Medium',
          dueTime: '10:00 PM',
          isCompleted: true,
        ),

        const SizedBox(height: 12),

        const TaskCard(
          title: 'Review Lecture Notes',
          subject: 'Computer Science',
          priority: 'Low',
          dueTime: '11:00 PM',
          isCompleted: true,
        ),

        const SizedBox(height: 12),

        const TaskCard(
          title: 'Prepare Presentation',
          subject: 'University Project',
          priority: 'High',
          dueTime: '11:30 PM',
          isCompleted: true,
        ),
      ],
    );
  }
}
