import 'package:flutter/material.dart';
import 'package:taskora/views/tasks/task_filter_chip.dart';
import '../../core/theme/app_colors.dart';

class TasksFilterSection extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const TasksFilterSection({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  static const List<String> filters = [
    'All Tasks',
    'Today',
    'Upcoming',
    'Completed',
    'Overdue',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filters',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TaskFilterChip(
                  title: filter,
                  isSelected: selectedFilter == filter,
                  onTap: () {
                    onFilterChanged(filter);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
