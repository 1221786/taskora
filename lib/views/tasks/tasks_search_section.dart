import 'package:flutter/material.dart';

class TasksSearchSection extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const TasksSearchSection({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 23),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
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
