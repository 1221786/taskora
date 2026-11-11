
import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback onLogout;

  const DashboardHeader({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFE9E6FF),
          child: const Text(
            'S',
            style: TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning,',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9297A5),
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Sara 👋',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2B4F),
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Let's make today productive!",
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9297A5),
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF1B2B4F),
            size: 25,
          ),
        ),

        IconButton(
          onPressed: onLogout,
          icon: const Icon(
            Icons.logout_rounded,
            color: Color(0xFF1B2B4F),
            size: 22,
          ),
        ),
      ],
    );
  }
}
