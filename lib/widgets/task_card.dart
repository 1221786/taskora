import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String subject;
  final String priority;
  final String dueTime;
  final bool isCompleted;
  final VoidCallback? onCheckboxTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.title,
    required this.subject,
    required this.priority,
    required this.dueTime,
    this.isCompleted = false,
    this.onCheckboxTap,
    this.onEdit,
    this.onDelete,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEDEEF3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: onCheckboxTap,
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted
                  ? const Color(0xFF39B98A)
                  : const Color(0xFFB8BCC9),
              size: 23,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B2B4F),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
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

                    const SizedBox(width: 8),

                    const Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Color(0xFF9297A5),
                    ),

                    const SizedBox(width: 3),

                    Text(
                      dueTime,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9297A5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: Color(0xFF7E83A0),
            ),
            visualDensity: VisualDensity.compact,
          ),

          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 19,
              color: Color(0xFFE17C7C),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
