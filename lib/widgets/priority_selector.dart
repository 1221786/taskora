import 'package:flutter/material.dart';

class PrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String> onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  static const Map<String, Color> priorityColors = {
    'low': Color(0xFF4CAF50),
    'medium': Color(0xFFFFC107),
    'high': Color(0xFFE53935),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Row(
          children: priorityColors.entries.map((entry) {
            final priority = entry.key;
            final color = entry.value;

            final isSelected = selectedPriority == priority;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => onPriorityChanged(priority),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.flag_rounded, color: color),
                        const SizedBox(height: 6),
                        Text(
                          priority[0].toUpperCase() + priority.substring(1),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
