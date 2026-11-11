import 'package:flutter/material.dart';

class GoalsEmptyState extends StatelessWidget {
  final VoidCallback onAddGoal;

  const GoalsEmptyState({super.key, required this.onAddGoal});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 45),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag_outlined,
                size: 52,
                color: Color(0xFF6C63FF),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No Goals Yet!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2B4F),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Start setting your goals and track your progress '
              'one step at a time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF9297A5),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: onAddGoal,
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Goal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
