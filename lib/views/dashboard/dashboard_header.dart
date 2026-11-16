import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onNotificationsTap;
  final String name;
  final String? photoBase64;

  const DashboardHeader({
    super.key,
    required this.onLogout,
    required this.onNotificationsTap,
    required this.name,
    this.photoBase64,
  });

  String get greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';

    return 'Good Evening,';
  }

  Widget _buildAvatar() {
    ImageProvider? image;

    if (photoBase64 != null && photoBase64!.isNotEmpty) {
      try {
        image = MemoryImage(base64Decode(photoBase64!));
      } catch (_) {
        image = null;
      }
    }

    return CircleAvatar(
      radius: 25,
      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
      backgroundImage: image,
      child: image == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'S',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildAvatar(),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedText,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                '${name.isNotEmpty ? name : 'Student'} 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 3),

              const Text(
                "Let's make today productive!",
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: onNotificationsTap,
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primary,
            size: 25,
          ),
        ),

        IconButton(
          onPressed: onLogout,
          icon: const Icon(
            Icons.logout_rounded,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ),
      ],
    );
  }
}
