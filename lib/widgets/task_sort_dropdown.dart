import 'package:flutter/material.dart';

class TaskSortDropdown extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  const TaskSortDropdown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = [
      'Due Date',
      'Priority',
      'Creation Date',
      'Alphabetical Order',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6C63FF)),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
