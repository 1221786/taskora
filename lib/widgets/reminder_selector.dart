import 'package:flutter/material.dart';

class ReminderSelector extends StatelessWidget {
  final String selectedReminder;
  final ValueChanged<String> onReminderChanged;

  const ReminderSelector({
    super.key,
    required this.selectedReminder,
    required this.onReminderChanged,
  });

  static const Map<String, String> reminderOptions = {
    'none': 'No Reminder',
    '10_minutes': '10 minutes before',
    '30_minutes': '30 minutes before',
    '1_hour': '1 hour before',
    '1_day': '1 day before',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminder',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          value: selectedReminder,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.notifications_active_outlined),
            labelText: 'Select Reminder',
          ),
          items: reminderOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onReminderChanged(value);
            }
          },
        ),
      ],
    );
  }
}
