import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/task_sort_dropdown.dart';

class TasksSortSection extends StatelessWidget {
  final String selectedSort;
  final ValueChanged<String> onSortChanged;

  const TasksSortSection({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Sort By',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const Spacer(),

        SizedBox(
          width: 175,
          child: TaskSortDropdown(
            selectedValue: selectedSort,
            onChanged: (value) {
              if (value == null) return;

              onSortChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
