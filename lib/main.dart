import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:taskora/views/splash/splash_view.dart';
import 'core/theme/app_theme.dart';
/*import 'views/splash/splash_view.dart';
import 'views/login/login_view.dart';
*/
import 'firebase_options.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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