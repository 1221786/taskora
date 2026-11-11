import 'package:flutter/material.dart';

class CalendarWeekDays extends StatelessWidget {
  const CalendarWeekDays({super.key});

  static const List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: weekDays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A94A6),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
