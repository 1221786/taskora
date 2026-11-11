import 'package:flutter/material.dart';

class CalendarGrid extends StatelessWidget {
  final int daysInMonth;
  final int startingWeekday;
  final int totalCalendarCells;
  final DateTime selectedDate;
  final DateTime displayedMonth;
  final bool Function(DateTime) isSelected;
  final bool Function(DateTime) isToday;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarGrid({
    super.key,
    required this.daysInMonth,
    required this.startingWeekday,
    required this.totalCalendarCells,
    required this.selectedDate,
    required this.displayedMonth,
    required this.isSelected,
    required this.isToday,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      itemCount: totalCalendarCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final dayNumber = index - startingWeekday + 1;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(
          displayedMonth.year,
          displayedMonth.month,
          dayNumber,
        );

        final selected = isSelected(date);
        final today = isToday(date);

        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF6C63FF) : Colors.transparent,
              shape: BoxShape.circle,
              border: today && !selected
                  ? Border.all(color: const Color(0xFF6C63FF), width: 1.5)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected || today
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: selected ? Colors.white : const Color(0xFF1B2B4F),
              ),
            ),
          ),
        );
      },
    );
  }
}
