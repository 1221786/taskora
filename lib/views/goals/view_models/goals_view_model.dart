import 'dart:async';

import 'package:flutter/material.dart';

import '../models/goal_model.dart';
import '../services/goal_service.dart';
import '../../tasks/models/task_model.dart';

class GoalsViewModel extends ChangeNotifier {
  final GoalService _goalService;
  final String? _userId;

  GoalsViewModel({required String? userId, GoalService? goalService})
    : _userId = userId,
      _goalService = goalService ?? GoalService() {
    _listenToGoals();
  }

  List<GoalModel> _goals = [];
  final Map<String, List<TaskModel>> _goalTasks = {};

  StreamSubscription<List<GoalModel>>? _goalsSubscription;
  final Map<String, StreamSubscription<List<TaskModel>>> _taskSubscriptions =
      {};

  bool _isLoading = false;
  String? _errorMessage;

  List<GoalModel> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _listenToGoals() {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;

    _goalsSubscription = _goalService
        .watchGoals(userId)
        .listen(
          (goals) {
            _goals = goals;
            _syncGoalTaskSubscriptions(userId);
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = 'Could not load goals. Please try again.';
            notifyListeners();
          },
        );
  }

  void _syncGoalTaskSubscriptions(String userId) {
    final goalIds = _goals.map((goal) => goal.id).toSet();

    final removedGoalIds = _taskSubscriptions.keys
        .where((goalId) => !goalIds.contains(goalId))
        .toList();

    for (final goalId in removedGoalIds) {
      _taskSubscriptions[goalId]?.cancel();
      _taskSubscriptions.remove(goalId);
      _goalTasks.remove(goalId);
    }

    for (final goal in _goals) {
      if (_taskSubscriptions.containsKey(goal.id)) continue;

      final subscription = _goalService
          .watchGoalTasks(userId: userId, goalId: goal.id)
          .listen(
            (tasks) {
              _goalTasks[goal.id] = tasks;
              notifyListeners();
            },
            onError: (error) {
              _errorMessage = 'Could not load goal tasks.';
              notifyListeners();
            },
          );

      _taskSubscriptions[goal.id] = subscription;
    }
  }

  // Get tasks linked to a specific goal.
  List<TaskModel> tasksForGoal(String goalId) {
    return List.unmodifiable(_goalTasks[goalId] ?? []);
  }

  // Get completed tasks count.
  int completedTasksCount(String goalId) {
    return tasksForGoal(goalId).where((task) => task.isCompleted).length;
  }

  // Get total linked tasks count.
  int totalTasksCount(String goalId) {
    return tasksForGoal(goalId).length;
  }

  // Calculate goal progress.
  double progressPercentage(String goalId) {
    final total = totalTasksCount(goalId);

    if (total == 0) return 0;

    final completed = completedTasksCount(goalId);

    return completed / total;
  }

  // Check if all linked tasks are completed.
  bool isGoalCompleted(String goalId) {
    final total = totalTasksCount(goalId);

    return total > 0 && completedTasksCount(goalId) == total;
  }

  // Get goal status.
  String goalStatus(GoalModel goal) {
    final total = totalTasksCount(goal.id);
    final completed = completedTasksCount(goal.id);

    if (total > 0 && completed == total) {
      return 'Completed';
    }

    if (DateUtils.dateOnly(
      goal.targetDate,
    ).isBefore(DateUtils.dateOnly(DateTime.now()))) {
      return 'Overdue';
    }

    if (total == 0) {
      return 'Not Started';
    }

    return 'In Progress';
  }

  // Delete goal.
  Future<bool> deleteGoal(String goalId) async {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      _errorMessage = 'Please login first.';
      notifyListeners();
      return false;
    }

    try {
      await _goalService.deleteGoal(goalId: goalId, userId: userId);

      return true;
    } catch (error) {
      _errorMessage = 'Could not delete goal. Please try again.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _goalsSubscription?.cancel();

    for (final subscription in _taskSubscriptions.values) {
      subscription.cancel();
    }

    _taskSubscriptions.clear();
    super.dispose();
  }
}
