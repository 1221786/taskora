import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:taskora/views/splash/splash_view.dart';
import 'package:taskora/views/notifications/services/notification_service.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize local notifications.
  final notificationService = NotificationService();

  try {
    await notificationService.initialize();
    await notificationService.requestPermissions();
  } catch (error) {
    debugPrint('NOTIFICATION INITIALIZATION ERROR: $error');
  }

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
