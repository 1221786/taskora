import 'package:flutter/material.dart';
import '../../widgets/upcoming_task_card.dart';

class UpcomingTasksSection extends StatelessWidget {
  const UpcomingTasksSection({super.key});

  @override
  Widget build(BuildContext context) {
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
                color: Color(0xFF1B2B4F),
              ),
            ),

            TextButton(
              onPressed: () {},
              child: const Text(
                'See All →',
                style: TextStyle(fontSize: 12, color: Color(0xFF6C63FF)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        UpcomingTaskCard(
          title: 'Mathematics Exam',
          subject: 'Mathematics',
          dueDate: 'Tomorrow, Nov 7',
          priority: 'High',
          onTap: () {},
        ),

        const SizedBox(height: 12),

        UpcomingTaskCard(
          title: 'Project Report',
          subject: 'Software Engineering',
          dueDate: 'Nov 5, 2026',
          priority: 'Medium',
          isOverdue: true,
          onTap: () {},
        ),

        const SizedBox(height: 12),

        UpcomingTaskCard(
          title: 'Database Quiz',
          subject: 'Database',
          dueDate: 'Nov 9, 2026',
          priority: 'Low',
          onTap: () {},
        ),
      ],
    );
  }
}
