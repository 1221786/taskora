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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link to Goal (Optional)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          value: selectedGoalId,
          decoration: const InputDecoration(
            labelText: 'Select Goal',
            prefixIcon: Icon(Icons.flag_outlined),
            border: OutlineInputBorder(),
          ),
          hint: const Text('No goal selected'),
          items: [
            const DropdownMenuItem<String>(value: null, child: Text('No Goal')),
            ...goals.map((goal) {
              return DropdownMenuItem<String>(
                value: goal['id'],
                child: Text(goal['title'] ?? ''),
              );
            }),
          ],
          onChanged: onGoalChanged,
        ),
      ],
    );
  }
}
