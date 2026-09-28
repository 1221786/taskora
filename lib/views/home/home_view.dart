import 'package:flutter/material.dart';

class TaskoraHomeView extends StatelessWidget {
  const TaskoraHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: const Center(
        child: Text(
          'HOME',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: Color(0xFF1B2B4F),
          ),
        ),
      ),
    );
  }
}
