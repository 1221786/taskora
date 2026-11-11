import 'package:flutter/material.dart';

class GoalSelector extends StatelessWidget {
  final String? selectedGoalId;
  final List<Map<String, String>> goals;
  final ValueChanged<String?> onGoalChanged;

  const GoalSelector({
    super.key,
    required this.selectedGoalId,
    required this.goals,
    required this.onGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    final validGoalIds = goals.map((goal) => goal['id']).toSet();

    final currentValue = validGoalIds.contains(selectedGoalId)
        ? selectedGoalId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link to Goal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2B4F),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: currentValue,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Select a goal (optional)',
            prefixIcon: const Icon(
              Icons.flag_outlined,
              color: Color(0xFF6C63FF),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
            ),
          ),
          items: [
            const DropdownMenuItem<String>(value: null, child: Text('No Goal')),
            ...goals.map((goal) {
              return DropdownMenuItem<String>(
                value: goal['id'],
                child: Text(
                  goal['title'] ?? 'Untitled Goal',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: onGoalChanged,
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose a goal to connect this task with it.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
