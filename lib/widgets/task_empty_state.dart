import 'package:flutter/material.dart';

class TaskEmptyState extends StatelessWidget {
  const TaskEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Column(
        children: [
          Icon(Icons.task_alt, size: 55, color: Color(0xFF6C63FF)),
          SizedBox(height: 15),
          Text(
            'No Tasks Found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2B4F),
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Your tasks will appear here.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
