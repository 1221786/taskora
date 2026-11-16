import 'package:flutter/material.dart';

class GoalSelector extends StatelessWidget {
  final String? selectedGoalId;
  final List<Map<String, String>> goals;
  final ValueChanged<String?> onGoalChanged;
  final VoidCallback onSelectGoal;

  const GoalSelector({
    super.key,
    required this.selectedGoalId,
    required this.goals,
    required this.onGoalChanged,
    required this.onSelectGoal,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, String>? selectedGoal;

    for (final goal in goals) {
      if (goal['id'] == selectedGoalId) {
        selectedGoal = goal;
        break;
      }
    }

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
        InkWell(
          onTap: onSelectGoal,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE1E4EC)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_outlined, color: Color(0xFF6C63FF)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedGoal?['title'] ?? 'Select a goal (optional)',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedGoal == null
                          ? Colors.grey
                          : const Color(0xFF1B2B4F),
                      fontWeight: selectedGoal == null
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF9297A5)),
              ],
            ),
          ),
        ),
        if (selectedGoal != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => onGoalChanged(null),
              child: const Text(
                'Remove Goal',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Choose a goal to connect this task with it.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
