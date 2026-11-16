import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Authentication/Login/login_view.dart';
import '../../core/theme/app_colors.dart';

import 'dashboard_header.dart';
import 'today_progress_card.dart';
import 'today_tasks_section.dart';
import 'upcoming_tasks_section.dart';
import 'dashboard_bottom_navigation.dart';
import 'dashboard_view_model.dart';

import '../tasks/tasks_view.dart';
import '../goals/views/goals_view.dart';
import '../statistics/statistics_view.dart';
import '../profile/views/profile_view.dart';
import '../notifications/views/notifications_view.dart';

class TaskoraDashboardView extends StatefulWidget {
  const TaskoraDashboardView({super.key});

  @override
  State<TaskoraDashboardView> createState() => _TaskoraDashboardViewState();
}

class _TaskoraDashboardViewState extends State<TaskoraDashboardView> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = DashboardViewModel(
      userId: FirebaseAuth.instance.currentUser?.uid,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TaskoraLoginView()),
      (route) => false,
    );
  }

  void _openNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to view notifications.'),
          backgroundColor: AppColors.primaryDark,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsView(userId: userId),
      ),
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardHeader(
              onLogout: _logout,
              onNotificationsTap: _openNotifications,
              name: _viewModel.profile?.name ?? '',
              photoBase64: _viewModel.profile?.photoBase64,
            ),

            const SizedBox(height: 26),

            TodayProgressCard(
              completed: _viewModel.completedTodayCount,
              total: _viewModel.totalTodayCount,
            ),

            const SizedBox(height: 25),

            TodayTasksSection(
              tasks: _viewModel.todayTasks,
              isLoading: _viewModel.isLoadingTasks,
              onToggle: _viewModel.toggleTaskCompletion,
              onDelete: _viewModel.deleteTask,
            ),

            const SizedBox(height: 25),

            UpcomingTasksSection(
              tasks: _viewModel.upcomingTasks,
              isLoading: _viewModel.isLoadingTasks,
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPage() {
    switch (_viewModel.currentIndex) {
      case 1:
        return const TasksView();

      case 2:
        return const GoalsView();

      case 3:
        return const StatisticsView();

      case 4:
        return ProfileView(onLogout: _logout);

      default:
        return _buildHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: _buildSelectedPage(),
          bottomNavigationBar: DashboardBottomNavigation(
            currentIndex: _viewModel.currentIndex,
            onTap: _viewModel.changePage,
          ),
        );
      },
    );
  }
}
