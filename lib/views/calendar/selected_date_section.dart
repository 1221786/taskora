import 'package:flutter/material.dart';

class SelectedDateSection extends StatelessWidget {
  final DateTime selectedDate;

  const SelectedDateSection({super.key, required this.selectedDate});

  String get dayName {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[selectedDate.weekday - 1];
  }

  String get monthName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[selectedDate.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Date',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF77718F),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF6C63FF),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$dayName, ${selectedDate.day} $monthName ${selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2B4F),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
