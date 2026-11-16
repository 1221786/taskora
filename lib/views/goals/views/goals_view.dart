import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_colors.dart';
import '../models/goal_model.dart';
import '../view_models/goals_view_model.dart';
import '../widgets/goal_card.dart';
import '../widgets/goals_empty_state.dart';
import 'add_edit_goal_view.dart';
import 'goal_details_view.dart';

class GoalsView extends StatefulWidget {
  final bool isSelectionMode;

  const GoalsView({super.key, this.isSelectionMode = false});

  @override
  State<GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> {
  late final GoalsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    _viewModel = GoalsViewModel(userId: userId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openAddGoal() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditGoalView()),
    );
  }

  Future<void> _openEditGoal(GoalModel goal) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditGoalView(goal: goal)),
    );
  }

  void _openGoalDetails(GoalModel goal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GoalDetailsView(goal: goal)),
    );
  }

  void _selectGoal(GoalModel goal) {
    Navigator.pop(context, goal);
  }

  Future<void> _deleteGoal(GoalModel goal) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Goal',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            'Are you sure you want to delete "${goal.title}"?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
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

    if (shouldDelete != true || !mounted) return;

    final success = await _viewModel.deleteGoal(goal.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? AppColors.success : AppColors.danger,
        content: Text(
          success
              ? 'Goal deleted successfully.'
              : _viewModel.errorMessage ?? 'Could not delete goal.',
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.isSelectionMode ? 'Select a Goal' : 'My Goals',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _openAddGoal,
            icon: const Icon(Icons.add, size: 19),
            label: const Text('Add Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    final goals = _viewModel.goals;

    if (_viewModel.isLoading && goals.isEmpty) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_viewModel.errorMessage != null && goals.isEmpty) {
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ),
      );
    }

    if (goals.isEmpty) {
      return Expanded(child: GoalsEmptyState(onAddGoal: _openAddGoal));
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];

          return GoalCard(
            goal: goal,
            progress: _viewModel.progressPercentage(goal.id),
            completedTasks: _viewModel.completedTasksCount(goal.id),
            totalTasks: _viewModel.totalTasksCount(goal.id),
            status: _viewModel.goalStatus(goal),
            isSelectionMode: widget.isSelectionMode,
            onSelect: () => _selectGoal(goal),
            onViewDetails: () => _openGoalDetails(goal),
            onEdit: () => _openEditGoal(goal),
            onDelete: () => _deleteGoal(goal),
            onAddTask: () => _openGoalDetails(goal),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildHeader(), _buildGoalsList()],
            );
          },
        ),
      ),
    );
  }
}
