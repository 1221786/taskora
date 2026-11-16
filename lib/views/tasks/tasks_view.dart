import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskora/views/tasks/tasks_list_section.dart';

import '../../core/theme/app_colors.dart';

import 'tasks_header.dart';
import 'tasks_search_section.dart';
import 'tasks_filter_section.dart';
import 'tasks_sort_section.dart';

import 'views/task_details_page.dart';
import 'views/add_edit_task_page.dart';
import 'models/task_model.dart';
import 'view_models/tasks_view_model.dart';

import '../calendar/calendar_view.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  TasksViewModel? _viewModel;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _viewModel = TasksViewModel(userId: user.uid);
    }
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  // Open Edit Task Screen
  Future<void> _openEditTask(TaskModel task) async {
    final user = FirebaseAuth.instance.currentUser;
    final viewModel = _viewModel;

    if (user == null || viewModel == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskPage(
          userId: user.uid,
          task: task,
          onSaveTask: viewModel.saveTask,
        ),
      ),
    );
  }

  // Open Task Details Screen
  Future<void> _openTaskDetails(TaskModel task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsPage(task: task)),
    );
  }

  // Open Calendar Screen
  Future<void> _openCalendar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarView()),
    );
  }

  // Toggle Task Completion
  Future<void> _toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      final task = _viewModel!.tasks.firstWhere((task) => task.id == taskId);

      await _viewModel!.toggleTaskCompletion(task, isCompleted);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCompleted
                ? 'Task marked as completed.'
                : 'Task marked as incomplete.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update task. Please try again.'),
        ),
      );

      debugPrint('TASK UPDATE ERROR: $e');
    }
  }

  // Delete Task After Confirmation
  Future<void> _deleteTask(String taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final task = _viewModel!.tasks.firstWhere((task) => task.id == taskId);

      await _viewModel!.deleteTask(task);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete task. Please try again.'),
        ),
      );

      debugPrint('TASK DELETE ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final viewModel = _viewModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TasksHeader(onOpenCalendar: _openCalendar),

              const SizedBox(height: 22),

              TasksSearchSection(
                onChanged: (value) {
                  viewModel?.setSearchQuery(value);
                },
              ),

              const SizedBox(height: 20),

              if (user == null || viewModel == null)
                const Text('Please login to view your tasks.')
              else
                AnimatedBuilder(
                  animation: viewModel,
                  builder: (context, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TasksFilterSection(
                          selectedFilter: viewModel.selectedFilter,
                          onFilterChanged: viewModel.setFilter,
                        ),

                        const SizedBox(height: 20),

                        TasksSortSection(
                          selectedSort: viewModel.selectedSort,
                          onSortChanged: viewModel.setSort,
                        ),

                        const SizedBox(height: 18),

                        if (viewModel.isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(30),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        else if (viewModel.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              viewModel.errorMessage!,
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          )
                        else
                          TasksListSection(
                            tasks: viewModel.visibleTasks,
                            title: viewModel.selectedFilter,
                            onComplete: _toggleTaskCompletion,
                            onDelete: _deleteTask,
                            onEdit: _openEditTask,
                            onViewDetails: _openTaskDetails,
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
