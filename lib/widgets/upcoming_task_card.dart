import 'package:flutter/material.dart';

class UpcomingTaskCard extends StatelessWidget {
  final String title;
  final String subject;
  final String dueDate;
  final String priority;
  final bool isOverdue;
  final VoidCallback? onTap;

  const UpcomingTaskCard({
    super.key,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.priority,
    this.isOverdue = false,
    this.onTap,
  });

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF5350);
      case 'medium':
        return const Color(0xFFF5B942);
      default:
        return const Color(0xFF43B581);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: isOverdue
                ? const Color(0xFFF5DADA)
                : const Color(0xFFEDEEF3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: isOverdue
                    ? const Color(0xFFFCEAEA)
                    : const Color(0xFFECEAFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isOverdue
                    ? Icons.warning_amber_rounded
                    : Icons.calendar_today_rounded,
                color: isOverdue
                    ? const Color(0xFFE17C7C)
                    : const Color(0xFF6C63FF),
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2B4F),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9297A5),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 12,
                        color: isOverdue
                            ? const Color(0xFFE17C7C)
                            : const Color(0xFF9297A5),
                      ),

                      const SizedBox(width: 4),

                      Flexible(
                        child: Text(
                          dueDate,
                          style: TextStyle(
                            fontSize: 10,
                            color: isOverdue
                                ? const Color(0xFFE17C7C)
                                : const Color(0xFF9297A5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                if (isOverdue)
                  const Text(
                    'Overdue',
                    style: TextStyle(
                      color: Color(0xFFE17C7C),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Color(0xFFB0B3C0),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
