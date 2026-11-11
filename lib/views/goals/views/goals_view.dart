import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/goal_model.dart';
import '../view_models/goals_view_model.dart';
import '../widgets/goal_card.dart';
import '../widgets/goals_empty_state.dart';
import 'add_edit_goal_view.dart';
import 'goal_details_view.dart';

class GoalsView extends StatefulWidget {
  const GoalsView({super.key});

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

  Future<void> _deleteGoal(GoalModel goal) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Goal'),
          content: Text('Are you sure you want to delete "${goal.title}"?'),
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
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
          const Expanded(
            child: Text(
              'My Goals',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2B4F),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _openAddGoal,
            icon: const Icon(Icons.add, size: 19),
            label: const Text('Add Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
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
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
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
              style: const TextStyle(color: Colors.red),
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
      backgroundColor: const Color(0xFFF8F9FC),
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
