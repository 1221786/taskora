import 'package:flutter/material.dart';

import '../models/goal_model.dart';
import 'goal_progress_indicator.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;
  final double progress;
  final int completedTasks;
  final int totalTasks;
  final String status;

  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddTask;

  const GoalCard({
    super.key,
    required this.goal,
    required this.progress,
    required this.completedTasks,
    required this.totalTasks,
    required this.status,
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
    required this.onAddTask,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _statusColor() {
    switch (status) {
      case 'Completed':
        return const Color(0xFF45B77A);
      case 'Overdue':
        return const Color(0xFFE85D5D);
      case 'In Progress':
        return const Color(0xFF6C63FF);
      default:
        return const Color(0xFF9297A5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal title and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2B4F),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          // Goal description
          if (goal.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              goal.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9297A5),
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Dates
          Row(
            children: [
              Expanded(
                child: _DateInfo(
                  label: 'Start Date',
                  date: _formatDate(goal.startDate),
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              Expanded(
                child: _DateInfo(
                  label: 'Target Date',
                  date: _formatDate(goal.targetDate),
                  icon: Icons.flag_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B2B4F),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          GoalProgressIndicator(progress: progress, showPercentage: false),

          const SizedBox(height: 10),

          Text(
            '$completedTasks/$totalTasks Tasks Completed',
            style: const TextStyle(fontSize: 12, color: Color(0xFF9297A5)),
          ),

          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE9ECF3)),
          const SizedBox(height: 8),

          // Goal actions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionButton(
                label: 'Details',
                icon: Icons.visibility_outlined,
                onTap: onViewDetails,
              ),
              _ActionButton(
                label: 'Edit',
                icon: Icons.edit_outlined,
                onTap: onEdit,
              ),
              _ActionButton(
                label: 'Add Task',
                icon: Icons.add_task,
                onTap: onAddTask,
              ),
              _ActionButton(
                label: 'Delete',
                icon: Icons.delete_outline,
                color: const Color(0xFFE85D5D),
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final String date;
  final IconData icon;

  const _DateInfo({
    required this.label,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6C63FF)),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9297A5)),
              ),
              const SizedBox(height: 3),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B2B4F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF6C63FF),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
