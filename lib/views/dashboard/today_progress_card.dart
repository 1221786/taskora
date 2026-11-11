
import 'package:flutter/material.dart';

class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    const int completed = 4;
    const int total = 6;

    const double progress = completed / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B2B4F)
                .withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Progress",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2B4F),
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: progress,
                  ),
                  duration: const Duration(
                    milliseconds: 1500,
                  ),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 9,
                            strokeCap: StrokeCap.round,
                            backgroundColor:
                                const Color(0xFFECEAF7),
                            valueColor:
                                const AlwaysStoppedAnimation(
                              Color(0xFF6C63FF),
                            ),
                          ),
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(value * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                            const Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9297A5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(width: 20),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '4 / 6',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2B4F),
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Tasks Completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9297A5),
                      ),
                    ),

                    SizedBox(height: 16),

                    _ProgressInfo(
                      color: Color(0xFF39B98A),
                      title: '4 Completed',
                    ),

                    SizedBox(height: 9),

                    _ProgressInfo(
                      color: Color(0xFFF5B942),
                      title: '2 Remaining',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressInfo extends StatelessWidget {
  final Color color;
  final String title;

  const _ProgressInfo({
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF777D8E),
          ),
        ),
      ],
    );
  }
}
