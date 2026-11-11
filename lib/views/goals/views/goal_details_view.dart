import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/goal_model.dart';
import '../view_models/goal_details_view_model.dart';
import '../widgets/goal_progress_indicator.dart';
import '../widgets/linked_tasks_section.dart';
import 'add_edit_goal_view.dart';

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

    _viewModel = GoalDetailsViewModel(
      goal: widget.goal,
      userId: FirebaseAuth.instance.currentUser?.uid,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _editGoal() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditGoalView(goal: widget.goal),
      ),
    );

    if (mounted) {
      // Return to the goals list so the updated goal is displayed.
      Navigator.pop(context);
    }
  }

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
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    final success = await _viewModel.deleteGoal();

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ?? 'Could not delete goal.'),
        ),
      );
    }
  }

  Future<void> _addTask() async {
    final selectedTaskId = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            final tasks = _viewModel.availableTasks;

            return AlertDialog(
              title: const Text('Add Task to Goal'),
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
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(task.title),
                            subtitle: Text(task.subject),
                            trailing: const Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF6C63FF),
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
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
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

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        const Expanded(
          child: Text(
            'Goal Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2B4F),
            ),
          ),
        ),
        IconButton(
          onPressed: _editGoal,
          tooltip: 'Edit Goal',
          icon: const Icon(Icons.edit_outlined, color: Color(0xFF6C63FF)),
        ),
        IconButton(
          onPressed: _deleteGoal,
          tooltip: 'Delete Goal',
          icon: const Icon(Icons.delete_outline, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildGoalInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: Color(0xFF1B2B4F),
            ),
          ),
          if (widget.goal.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              widget.goal.description,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 17,
                color: Color(0xFF6C63FF),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Start: ${_formatDate(widget.goal.startDate)}'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                size: 17,
                color: Color(0xFF6C63FF),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Target: ${_formatDate(widget.goal.targetDate)}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    final percentage = (_viewModel.progressPercentage * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: Color(0xFF1B2B4F),
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
                const Color(0xFF35B58A),
              ),
              const Spacer(),
              _buildCountItem(
                'Remaining',
                _viewModel.remainingTasksCount,
                const Color(0xFFE5A23B),
              ),
              const Spacer(),
              _buildCountItem(
                'Total',
                _viewModel.totalTasksCount,
                const Color(0xFF6C63FF),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (_viewModel.isCompleted)
            const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF35B58A)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Congratulations! All goal tasks are completed.',
                    style: TextStyle(
                      color: Color(0xFF27966F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          else if (_viewModel.totalTasksCount == 0)
            const Text(
              'No tasks linked to this goal yet.',
              style: TextStyle(color: Colors.black54),
            )
          else
            Text(
              '$percentage% completed',
              style: const TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

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
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

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
                color: Color(0xFF1B2B4F),
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
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
                      ? const Center(child: CircularProgressIndicator())
                      : _viewModel.errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              _viewModel.errorMessage!,
                              textAlign: TextAlign.center,
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
