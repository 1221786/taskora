import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          initialValue: selectedReminder,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            prefixIcon: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primary,
            ),
            labelText: 'Select Reminder',
            labelStyle: const TextStyle(color: AppColors.textSecondary),
          ),
          dropdownColor: AppColors.white,
          style: const TextStyle(color: AppColors.textPrimary),
          iconEnabledColor: AppColors.primary,
          items: reminderOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
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
