import 'package:flutter/material.dart';

import '../../Authentication/Login/login_view.dart';

import 'dashboard_header.dart';
import 'today_progress_card.dart';
import 'today_tasks_section.dart';
import 'upcoming_tasks_section.dart';
import 'dashboard_bottom_navigation.dart';
import 'dashboard_view_model.dart';

import '../tasks/tasks_view.dart';
import '../calendar/calendar_view.dart';

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
    _viewModel = DashboardViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
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
              onLogout: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskoraLoginView(),
                  ),
                );
              },
            ),

            const SizedBox(height: 26),
            const TodayProgressCard(),

            const SizedBox(height: 25),
            const TodayTasksSection(),

            const SizedBox(height: 25),
            const UpcomingTasksSection(),

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
        return const CalendarView();

      case 3:
        return const Center(
          child: Text(
            'Profile page coming soon',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B2B4F),
            ),
          ),
        );

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
          backgroundColor: const Color(0xFFF8F9FC),

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
