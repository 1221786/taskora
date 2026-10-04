import 'package:flutter/material.dart';
import 'package:taskora/core/theme/app_colors.dart';
import '../login/login_view.dart';

class TaskoraDashboardView extends StatefulWidget {
  const TaskoraDashboardView({super.key});

  @override
  State<TaskoraDashboardView> createState() => _TaskoraDashboardViewState();
}

class _TaskoraDashboardViewState extends State<TaskoraDashboardView> {
  int currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // Empty main screen
      body: SafeArea(
        child: Stack(
          children: [
            // Log Out button
            Positioned(
              top: 8,
              right: 20,

              child: IconButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskoraLoginView(),
      ),
    );
  },
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 27,
                  color: Color(0xFF1B2B4F),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(
                color: Color(0xFFD9E0E7),
                width: 0.8,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                      isSelected: currentIndex == 0,
                      onTap: () {
                        setState(() {
                          currentIndex = 0;
                        });
                      },
                    ),
                    _NavItem(
                      icon: Icons.description_outlined,
                      isSelected: currentIndex == 1,
                      onTap: () {
                        setState(() {
                          currentIndex = 1;
                        });
                      },
                    ),
                    _NavItem(
                      icon: Icons.calendar_month_outlined,
                      isSelected: currentIndex == 2,
                      onTap: () {
                        setState(() {
                          currentIndex = 2;
                        });
                      },
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      isSelected: currentIndex == 3,
                      onTap: () {
                        setState(() {
                          currentIndex = 3;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Home indicator
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
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      splashRadius: 24,
      icon: Icon(
        icon,
        size: 25,
        color: const Color(0xFF1B2B4F),
      ),
    );
  }
}