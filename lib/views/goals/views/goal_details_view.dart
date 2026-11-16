import 'package:flutter/material.dart';
import 'package:taskora/core/theme/app_colors.dart';
import '../models/goal_model.dart';
import '../view_models/goal_details_view_model.dart';
import '../widgets/goal_progress_indicator.dart';
import '../widgets/linked_tasks_section.dart';
import 'add_edit_goal_view.dart';

import '../../tasks/views/add_edit_task_page.dart';

class GoalDetailsView extends StatefulWidget {
  final GoalModel goal;

  const GoalDetailsView({super.key, required this.goal});

  @override
  State<GoalDetailsView> createState() => _GoalDetailsViewState();
}

class _GoalDetailsViewState extends State<GoalDetailsView> {
  late final GoalDetailsViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = GoalDetailsViewModel(goal: widget.goal, userId: null);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // -----------------------------
  // Edit Goal
  // -----------------------------

  Future<void> _editGoal() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditGoalView(goal: widget.goal),
      ),
    );

    if (!mounted) return;

    if (updated == true) {
      Navigator.pop(context, true);
    }
  }

  // -----------------------------
  // Delete Goal
  // -----------------------------

  Future<void> _deleteGoal() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Goal'),
          content: Text(
            'Are you sure you want to delete "${widget.goal.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    final success = await _viewModel.deleteGoal();

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ?? 'Could not delete goal.'),
        ),
      );
    }
  }

  // -----------------------------
  // Add Task Options
  // -----------------------------

  Future<void> _addTask() async {
    final selectedOption = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Task to Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.add_task, color: AppColors.primary),
                title: const Text('Create New Task'),
                subtitle: const Text('Create a new task for this goal.'),
                onTap: () {
                  Navigator.pop(dialogContext, 'create');
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.playlist_add,
                  color: AppColors.primary,
                ),
                title: const Text('Add Existing Task'),
                subtitle: const Text('Link an existing task to this goal.'),
                onTap: () {
                  Navigator.pop(dialogContext, 'existing');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (!mounted || selectedOption == null) return;

    if (selectedOption == 'create') {
      await _createNewTask();
    } else if (selectedOption == 'existing') {
      await _addExistingTask();
    }
  }

  // -----------------------------
  // Create New Task
  // -----------------------------

  Future<void> _createNewTask() async {
    final userId = _viewModel.userId;

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first.')));
      return;
    }

    if (widget.goal.id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid goal.')));
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskPage(
          userId: userId,
          initialGoalId: widget.goal.id,
          onSaveTask: _viewModel.saveTask,
        ),
      ),
    );
  }

  // -----------------------------
  // Add Existing Task
  // -----------------------------

  Future<void> _addExistingTask() async {
    final selectedTaskId = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            final tasks = _viewModel.availableTasks;

            return AlertDialog(
              title: const Text('Add Existing Task'),
              content: SizedBox(
                width: double.maxFinite,
                child: tasks.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'There are no available tasks to add.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(task.title),
                            subtitle: Text(task.subject),
                            trailing: const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.primary,
                            ),
                            onTap: () {
                              Navigator.pop(dialogContext, task.id);
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedTaskId == null || !mounted) return;

    final success = await _viewModel.addTaskToGoal(selectedTaskId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Task added to goal successfully.'
              : _viewModel.errorMessage ?? 'Could not add task.',
        ),
      ),
    );
  }

  // -----------------------------
  // Toggle Task Completion
  // -----------------------------

  Future<void> _toggleTask(String taskId, bool isCompleted) async {
    final success = await _viewModel.toggleTaskCompletion(taskId, isCompleted);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ?? 'Could not update task.'),
        ),
      );
    }
  }

  // -----------------------------
  // Remove Task from Goal
  // -----------------------------

  Future<void> _removeTask(String taskId) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove Task'),
          content: const Text('Do you want to remove this task from the goal?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Remove',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );

    if (shouldRemove != true || !mounted) return;

    final success = await _viewModel.removeTaskFromGoal(taskId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Task removed from goal.'
              : _viewModel.errorMessage ?? 'Could not remove task.',
        ),
      ),
    );
  }

  // -----------------------------
  // Header
  // -----------------------------

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        const Expanded(
          child: Text(
            'Goal Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: _viewModel.isUpdating ? null : _editGoal,
          tooltip: 'Edit Goal',
          icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
        ),
        IconButton(
          onPressed: _viewModel.isUpdating ? null : _deleteGoal,
          tooltip: 'Delete Goal',
          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
        ),
      ],
    );
  }

  // -----------------------------
  // Goal Information
  // -----------------------------

  Widget _buildGoalInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.goal.title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (widget.goal.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              widget.goal.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Start: ${_formatDate(widget.goal.startDate)}',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Target: ${_formatDate(widget.goal.targetDate)}',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // Goal Progress
  // -----------------------------

  Widget _buildProgress() {
    final percentage = (_viewModel.progressPercentage * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Goal Progress',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 15),
          GoalProgressIndicator(progress: _viewModel.progressPercentage),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildCountItem(
                'Completed',
                _viewModel.completedTasksCount,
                AppColors.success,
              ),
              const Spacer(),
              _buildCountItem(
                'Remaining',
                _viewModel.remainingTasksCount,
                AppColors.warning,
              ),
              const Spacer(),
              _buildCountItem(
                'Total',
                _viewModel.totalTasksCount,
                AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (_viewModel.isCompleted)
            const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Congratulations! All goal tasks are completed.',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          else if (_viewModel.totalTasksCount == 0)
            const Text(
              'No tasks linked to this goal yet.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            Text(
              '$percentage% completed',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  // -----------------------------
  // Count Item
  // -----------------------------

  Widget _buildCountItem(String label, int count, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // -----------------------------
  // Linked Tasks Section
  // -----------------------------

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Linked Tasks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _viewModel.isUpdating ? null : _addTask,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinkedTasksSection(
          tasks: _viewModel.linkedTasks,
          isUpdating: _viewModel.isUpdating,
          onRemoveTask: _removeTask,
          onToggleTask: _toggleTask,
        ),
      ],
    );
  }

  // -----------------------------
  // Build
  // -----------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: _buildHeader(),
                ),
                Expanded(
                  child: _viewModel.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : _viewModel.errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              _viewModel.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGoalInformation(),
                              const SizedBox(height: 18),
                              _buildProgress(),
                              const SizedBox(height: 22),
                              _buildTasksSection(),
                            ],
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
