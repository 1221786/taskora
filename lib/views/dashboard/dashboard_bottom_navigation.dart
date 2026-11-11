import 'package:flutter/material.dart';

class DashboardBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DashboardBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E8EF), width: 0.8)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(icon: Icons.home_outlined, index: 0),
                  _buildNavItem(icon: Icons.description_outlined, index: 1),
                  _buildNavItem(icon: Icons.calendar_month_outlined, index: 2),
                  _buildNavItem(icon: Icons.person_outline_rounded, index: 3),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: 110,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final bool isSelected = currentIndex == index;

    return IconButton(
      onPressed: () => onTap(index),
      splashRadius: 24,
      icon: Icon(
        icon,
        size: 25,
        color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF9297A5),
      ),
    );
  }
}
