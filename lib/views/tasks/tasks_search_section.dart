import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TasksSearchSection extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const TasksSearchSection({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textSecondary, size: 23),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: TextStyle(color: AppColors.mutedText, fontSize: 14),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
