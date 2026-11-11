import 'package:flutter/material.dart';

class GoalProgressIndicator extends StatelessWidget {
  final double progress;
  final bool showPercentage;
  final double height;

  const GoalProgressIndicator({
    super.key,
    required this.progress,
    this.showPercentage = true,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${(normalizedProgress * 100).round()}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2B4F),
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: normalizedProgress,
            minHeight: height,
            backgroundColor: const Color(0xFFE9ECF3),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
          ),
        ),
      ],
    );
  }
}
