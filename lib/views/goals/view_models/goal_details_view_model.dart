import 'dart:async';

import 'package:flutter/material.dart';

import '../models/goal_model.dart';
import '../services/goal_service.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/services/task_service.dart';

class GoalDetailsViewModel extends ChangeNotifier {
  final GoalModel goal;
  final String? _userId;
  final GoalService _goalService;
  final TaskService _taskService;

  GoalDetailsViewModel({
    required this.goal,
    required String? userId,
    GoalService? goalService,
    TaskService? taskService,
  }) : _userId = userId,
       _goalService = goalService ?? GoalService(),
       _taskService = taskService ?? TaskService() {
    _listenToGoalTasks();
  }

  List<TaskModel> _linkedTasks = [];
  List<TaskModel> _availableTasks = [];

  StreamSubscription<List<TaskModel>>? _linkedTasksSubscription;
  StreamSubscription<List<TaskModel>>? _allTasksSubscription;

  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  List<TaskModel> get linkedTasks => List.unmodifiable(_linkedTasks);

  List<TaskModel> get availableTasks => List.unmodifiable(_availableTasks);

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  int get completedTasksCount =>
      _linkedTasks.where((task) => task.isCompleted).length;

  int get remainingTasksCount => _linkedTasks.length - completedTasksCount;

  int get totalTasksCount => _linkedTasks.length;

  double get progressPercentage {
    if (_linkedTasks.isEmpty) return 0;

    return completedTasksCount / _linkedTasks.length;
  }

  bool get isCompleted =>
      _linkedTasks.isNotEmpty && completedTasksCount == _linkedTasks.length;

  void _listenToGoalTasks() {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      _errorMessage = 'Please login first.';
      notifyListeners();
      return;
    }

    _isLoading = true;

    _linkedTasksSubscription = _goalService
        .watchGoalTasks(userId: userId, goalId: goal.id)
        .listen(
          (tasks) {
            _linkedTasks = tasks;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = 'Could not load linked tasks.';
            notifyListeners();
          },
        );

    _listenToAvailableTasks(userId);
  }

  void _listenToAvailableTasks(String userId) {
    _allTasksSubscription = _taskService
        .watchTasks(userId)
        .listen(
          (tasks) {
            _availableTasks = tasks
                .where((task) => task.goalId == null || task.goalId!.isEmpty)
                .toList();

            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Could not load available tasks.';
            notifyListeners();
          },
        );
  }

  Future<bool> addTaskToGoal(String taskId) async {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      _errorMessage = 'Please login first.';
      notifyListeners();
      return false;
    }

    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _goalService.linkTaskToGoal(
        taskId: taskId,
        goalId: goal.id,
        userId: userId,
      );

      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isUpdating = false;
      _errorMessage = 'Could not add task to goal.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeTaskFromGoal(String taskId) async {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      _errorMessage = 'Please login first.';
      notifyListeners();
      return false;
    }

    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _goalService.unlinkTaskFromGoal(taskId: taskId, userId: userId);

      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isUpdating = false;
      _errorMessage = 'Could not remove task from goal.';
      notifyListeners();
      return false;
    }
  }

  // Delete the current goal.
  Future<bool> deleteGoal() async {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      _errorMessage = 'Please login first.';
      notifyListeners();
      return false;
    }

    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _goalService.deleteGoal(goalId: goal.id, userId: userId);

      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isUpdating = false;
      _errorMessage = 'Could not delete goal. Please try again.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _linkedTasksSubscription?.cancel();
    _allTasksSubscription?.cancel();
    super.dispose();
  }
}
