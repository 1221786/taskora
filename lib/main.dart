import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'views/splash/splash_view.dart';

void main() {
  runApp(const TaskoraApp());
}

class TaskoraApp extends StatelessWidget {
  const TaskoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taskora',
      theme: AppTheme.lightTheme,
      home: const TaskoraSplashView(),
    );
  }
}