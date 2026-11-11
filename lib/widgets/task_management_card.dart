import 'package:flutter/material.dart';

class TaskManagementCard extends StatelessWidget {
  final String title;
  final String description;
  final String subject;
  final String priority;
  final String dueDate;
  final String dueTime;
  final String duration;
  final bool isCompleted;
  final bool isOverdue;

  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskManagementCard({
    super.key,
    required this.title,
    required this.description,
    required this.subject,
    required this.priority,
    required this.dueDate,
    required this.dueTime,
    required this.duration,
    this.isCompleted = false,
    this.isOverdue = false,
    this.onTap,
    this.onComplete,
    this.onEdit,
    this.onDelete,
  });

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFE85D5D);
      case 'medium':
        return const Color(0xFFE6A23C);
      case 'low':
        return const Color(0xFF45B883);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: isOverdue && !isCompleted
                ? const Color(0xFFF3B5B5)
                : const Color(0xFFEDEEF3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? Colors.grey
                          : const Color(0xFF1B2B4F),
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
                Checkbox(
                  value: isCompleted,
                  activeColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onChanged: (_) => onComplete?.call(),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Color(0xFF858B9C)),
            ),

            const SizedBox(height: 13),

            Row(
              children: [
                const Icon(
                  Icons.book_outlined,
                  size: 16,
                  color: Color(0xFF6C63FF),
                ),
                const SizedBox(width: 5),
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF687087),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Wrap(
              spacing: 15,
              runSpacing: 8,
              children: [
                _InfoItem(icon: Icons.calendar_today_outlined, text: dueDate),
                _InfoItem(icon: Icons.access_time, text: dueTime),
                _InfoItem(icon: Icons.hourglass_bottom, text: duration),
              ],
            ),

            if (isOverdue && !isCompleted) ...[
              const SizedBox(height: 10),
              const Text(
                'Overdue',
                style: TextStyle(
                  color: Color(0xFFE85D5D),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(icon: Icons.edit_outlined, onTap: onEdit),
                _ActionButton(
                  icon: Icons.delete_outline,
                  color: const Color(0xFFE85D5D),
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.grey),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: Color(0xFF687087)),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    this.color = const Color(0xFF858B9C),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 19, color: color),
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}
