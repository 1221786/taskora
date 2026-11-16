import 'dart:async';
import 'package:flutter/material.dart';

import '../models/goal_model.dart';
import '../services/goal_service.dart';
import '../../tasks/models/task_model.dart';
import '../../notifications/models/notification_model.dart';
import '../../notifications/services/notification_service.dart';

class GoalsViewModel extends ChangeNotifier {
  final GoalService _goalService;
  final NotificationService _notificationService;
  final String? _userId;

  GoalsViewModel({
    required String? userId,
    GoalService? goalService,
    NotificationService? notificationService,
  }) : _userId = userId,
       _goalService = goalService ?? GoalService(),
       _notificationService = notificationService ?? NotificationService() {
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

  // Listen to user's goals.
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
            debugPrint('LOAD GOALS ERROR: $error');
          },
        );
  }

  // Synchronize task subscriptions for each goal.
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
              debugPrint('LOAD GOAL TASKS ERROR: $error');
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

  // Save goal deletion activity notification.
  Future<void> _saveGoalDeletionNotification(GoalModel goal) async {
    final notification = NotificationModel(
      id: 'goal_${goal.id}_deleted_${DateTime.now().microsecondsSinceEpoch}',
      userId: goal.userId,
      title: 'Goal Deleted',
      body: 'Your goal "${goal.title}" was deleted.',
      type: NotificationType.general,
      goalId: goal.id,
      createdAt: DateTime.now(),
    );

    try {
      await _notificationService.saveAndShowNotification(notification);
    } catch (error) {
      debugPrint('GOAL DELETION NOTIFICATION ERROR: $error');
    }
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
      // Find the goal before deleting it.
      GoalModel? goalToDelete;

      for (final goal in _goals) {
        if (goal.id == goalId) {
          goalToDelete = goal;
          break;
        }
      }

      if (goalToDelete == null) {
        _errorMessage = 'Goal not found. Please refresh and try again.';
        notifyListeners();
        return false;
      }

      // Delete the goal and detach its linked tasks.
      await _goalService.deleteGoal(goalId: goalId, userId: userId);

      // Cancel its scheduled local reminder.
      try {
        await _notificationService.cancelGoalReminder(goalToDelete);
      } catch (error) {
        debugPrint('CANCEL GOAL REMINDER ERROR: $error');
      }

      // Notify the user that the goal was deleted.
      await _saveGoalDeletionNotification(goalToDelete);

      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = 'Could not delete goal. Please try again.';
      notifyListeners();
      debugPrint('DELETE GOAL ERROR: $error');
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
    _goalTasks.clear();

    super.dispose();
  }
}
