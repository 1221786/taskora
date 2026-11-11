import 'package:flutter/material.dart';

class CalendarHeader extends StatelessWidget {
  final String monthName;
  final int year;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;

  const CalendarHeader({
    super.key,
    required this.monthName,
    required this.year,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$monthName $year',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2B4F),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your schedule',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onPreviousMonth,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: onNextMonth,
            icon: const Icon(Icons.chevron_right),
          ),
          TextButton(
            onPressed: onToday,
            child: const Text(
              'Today',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
