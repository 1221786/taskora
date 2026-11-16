import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/goal_model.dart';
import '../services/goal_service.dart';

import '../../tasks/models/task_model.dart';
import '../../tasks/services/task_service.dart';

import '../../notifications/models/notification_model.dart';
import '../../notifications/services/notification_service.dart';

class GoalDetailsViewModel extends ChangeNotifier {
  final GoalModel goal;

  final String? _userId;

  final GoalService _goalService;
  final TaskService _taskService;
  final NotificationService _notificationService;

  GoalDetailsViewModel({
    required this.goal,
    required String? userId,
    GoalService? goalService,
    TaskService? taskService,
    NotificationService? notificationService,
  }) : _userId = userId ?? FirebaseAuth.instance.currentUser?.uid,
       _goalService = goalService ?? GoalService(),
       _taskService = taskService ?? TaskService(),
       _notificationService = notificationService ?? NotificationService() {
    _listenToGoalTasks();
  }

  // State

  List<TaskModel> _linkedTasks = [];
  List<TaskModel> _availableTasks = [];

  StreamSubscription<List<TaskModel>>? _linkedTasksSubscription;
  StreamSubscription<List<TaskModel>>? _allTasksSubscription;

  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isDisposed = false;
  bool _isDeletingGoal = false;

  String? _errorMessage;

  bool? _lastKnownGoalCompletionState;

  // Getters

  String? get userId => _userId;

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

  // State helpers

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void _setUpdating(bool value) {
    _isUpdating = value;
    _notify();
  }

  // Save task activity notification.

  Future<void> _saveTaskActivityNotification({
    required TaskModel task,
    required NotificationType type,
  }) async {
    final notification = NotificationModel(
      id: 'task_${task.id}_${type.name}_${DateTime.now().microsecondsSinceEpoch}',
      userId: task.userId,
      title: type == NotificationType.taskCreated
          ? 'Task Created'
          : type == NotificationType.taskCompleted
          ? 'Task Completed'
          : 'Task Updated',
      body: type == NotificationType.taskCreated
          ? 'Your task "${task.title}" was created successfully.'
          : type == NotificationType.taskCompleted
          ? 'Your task "${task.title}" was completed.'
          : 'Your task "${task.title}" was updated.',
      type: type,
      taskId: task.id,
      goalId: task.goalId,
      createdAt: DateTime.now(),
    );

    try {
      await _notificationService.saveAndShowNotification(notification);
    } catch (error) {
      debugPrint('TASK ACTIVITY NOTIFICATION ERROR: $error');
    }
  }

  // Save goal deletion notification.

  // Goal reminder management

  Future<void> _syncGoalReminder(bool completed) async {
    if (_isDisposed || _isDeletingGoal) return;

    try {
      if (completed) {
        await _notificationService.cancelGoalReminder(goal);
      } else {
        await _notificationService.scheduleGoalReminder(goal);
      }
    } catch (error) {
      debugPrint('GOAL REMINDER ERROR: $error');
    }
  }

  void _handleGoalCompletionChange() {
    if (_isDisposed || _isDeletingGoal) return;

    final currentCompletionState = isCompleted;

    if (_lastKnownGoalCompletionState == currentCompletionState) {
      return;
    }

    _lastKnownGoalCompletionState = currentCompletionState;

    _syncGoalReminder(currentCompletionState);
  }

  // Listen to goal tasks

  void _listenToGoalTasks() {
    final currentUserId = _userId;

    if (currentUserId == null || currentUserId.isEmpty) {
      _errorMessage = 'Please login first.';
      _notify();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _notify();

    _linkedTasksSubscription = _goalService
        .watchGoalTasks(userId: currentUserId, goalId: goal.id)
        .listen(
          (tasks) {
            if (_isDisposed || _isDeletingGoal) return;

            _linkedTasks = tasks;
            _isLoading = false;
            _errorMessage = null;

            _handleGoalCompletionChange();

            _notify();
          },
          onError: (error) {
            if (_isDisposed || _isDeletingGoal) return;

            _isLoading = false;
            _errorMessage = 'Could not load linked tasks.';

            debugPrint('GOAL TASKS ERROR: $error');

            _notify();
          },
        );

    _listenToAvailableTasks(currentUserId);
  }

  // Listen to available tasks

  void _listenToAvailableTasks(String userId) {
    _allTasksSubscription = _taskService
        .watchTasks(userId)
        .listen(
          (tasks) {
            if (_isDisposed) return;

            _availableTasks = tasks.where((task) {
              return task.goalId == null || task.goalId!.isEmpty;
            }).toList();

            _notify();
          },
          onError: (error) {
            if (_isDisposed) return;

            _errorMessage = 'Could not load available tasks.';

            debugPrint('AVAILABLE TASKS ERROR: $error');

            _notify();
          },
        );
  }

  // Save task

  Future<void> saveTask(TaskModel task) async {
    final currentUserId = _userId;

    if (currentUserId == null || currentUserId.isEmpty) {
      throw Exception('Please login first.');
    }

    if (_isUpdating) {
      throw Exception('Please wait until the current operation finishes.');
    }

    if (task.userId != currentUserId) {
      throw Exception('Invalid task user.');
    }

    if (goal.id.isEmpty) {
      throw Exception('Invalid goal ID.');
    }

    _setUpdating(true);
    _errorMessage = null;

    try {
      final isNewTask = task.id.isEmpty;

      final linkedTask = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        subject: task.subject,
        priority: task.priority,
        dueDate: task.dueDate,
        estimatedDuration: task.estimatedDuration,
        reminder: task.reminder,
        goalId: goal.id,
        isCompleted: task.isCompleted,
        userId: currentUserId,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
        completedAt: task.completedAt,
      );

      late final String savedTaskId;

      if (isNewTask) {
        savedTaskId = await _taskService.addTask(linkedTask);
      } else {
        await _taskService.updateTask(linkedTask);
        savedTaskId = linkedTask.id;
      }

      final savedTask = TaskModel(
        id: savedTaskId,
        title: linkedTask.title,
        description: linkedTask.description,
        subject: linkedTask.subject,
        priority: linkedTask.priority,
        dueDate: linkedTask.dueDate,
        estimatedDuration: linkedTask.estimatedDuration,
        reminder: linkedTask.reminder,
        goalId: linkedTask.goalId,
        isCompleted: linkedTask.isCompleted,
        userId: linkedTask.userId,
        createdAt: linkedTask.createdAt,
        updatedAt: linkedTask.updatedAt,
        completedAt: linkedTask.completedAt,
      );

      // Schedule or update task reminder.
      try {
        await _notificationService.scheduleTaskReminder(savedTask);
      } catch (error) {
        debugPrint('TASK REMINDER ERROR: $error');
      }

      // Save and show task activity notification.
      await _saveTaskActivityNotification(
        task: savedTask,
        type: isNewTask
            ? NotificationType.taskCreated
            : NotificationType.taskUpdated,
      );
    } catch (error) {
      _errorMessage = 'Could not save task. Please try again.';

      debugPrint('SAVE GOAL TASK ERROR: $error');

      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  // Add existing task to goal

  Future<bool> addTaskToGoal(String taskId) async {
    final currentUserId = _userId;

    if (currentUserId == null || currentUserId.isEmpty) {
      _errorMessage = 'Please login first.';
      _notify();
      return false;
    }

    if (_isUpdating) return false;

    _setUpdating(true);
    _errorMessage = null;

    try {
      await _goalService.linkTaskToGoal(
        taskId: taskId,
        goalId: goal.id,
        userId: currentUserId,
      );

      return true;
    } catch (error) {
      _errorMessage = 'Could not add task to goal.';

      debugPrint('ADD TASK TO GOAL ERROR: $error');

      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Remove task from goal

  Future<bool> removeTaskFromGoal(String taskId) async {
    final currentUserId = _userId;

    if (currentUserId == null || currentUserId.isEmpty) {
      _errorMessage = 'Please login first.';
      _notify();
      return false;
    }

    if (_isUpdating) return false;

    _setUpdating(true);
    _errorMessage = null;

    try {
      await _goalService.unlinkTaskFromGoal(
        taskId: taskId,
        userId: currentUserId,
      );

      return true;
    } catch (error) {
      _errorMessage = 'Could not remove task from goal.';

      debugPrint('REMOVE TASK FROM GOAL ERROR: $error');

      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Toggle task completion

  Future<bool> toggleTaskCompletion(String taskId, bool isCompleted) async {
    final currentUserId = _userId;

    if (currentUserId == null || currentUserId.isEmpty) {
      _errorMessage = 'Please login first.';
      _notify();
      return false;
    }

    if (_isUpdating) return false;

    _setUpdating(true);
    _errorMessage = null;

    try {
      final taskIndex = _linkedTasks.indexWhere((task) => task.id == taskId);

      if (taskIndex == -1) {
        throw Exception('Task not found in this goal.');
      }

      final originalTask = _linkedTasks[taskIndex];

      await _taskService.updateTaskCompletion(taskId, isCompleted);

      final updatedTask = TaskModel(
        id: originalTask.id,
        title: originalTask.title,
        description: originalTask.description,
        subject: originalTask.subject,
        priority: originalTask.priority,
        dueDate: originalTask.dueDate,
        estimatedDuration: originalTask.estimatedDuration,
        reminder: originalTask.reminder,
        goalId: originalTask.goalId,
        isCompleted: isCompleted,
        userId: originalTask.userId,
        createdAt: originalTask.createdAt,
        updatedAt: DateTime.now(),
        completedAt: isCompleted ? DateTime.now() : null,
      );

      // Update task reminder.
      try {
        if (isCompleted) {
          await _notificationService.cancelTaskReminder(updatedTask);
        } else {
          await _notificationService.scheduleTaskReminder(updatedTask);
        }
      } catch (error) {
        debugPrint('TASK REMINDER UPDATE ERROR: $error');
      }

      // Save and show completion activity notification.
      await _saveTaskActivityNotification(
        task: updatedTask,
        type: isCompleted
            ? NotificationType.taskCompleted
            : NotificationType.taskUpdated,
      );

      return true;
    } catch (error) {
      _errorMessage = 'Could not update task completion.';

      debugPrint('TOGGLE GOAL TASK ERROR: $error');

      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Delete goal

  Future<bool> deleteGoal() async {
    final currentUserId = _userId;

    if (currentUserId == null || currentUserId.isEmpty) {
      _errorMessage = 'Please login first.';
      _notify();
      return false;
    }

    if (_isUpdating) return false;

    _setUpdating(true);
    _errorMessage = null;

    // Prevent the tasks stream from scheduling the reminder again.
    _isDeletingGoal = true;

    try {
      await _goalService.deleteGoal(goalId: goal.id, userId: currentUserId);

      // Cancel the scheduled goal reminder.
      try {
        await _notificationService.cancelGoalReminder(goal);
      } catch (error) {
        debugPrint('CANCEL GOAL REMINDER ERROR: $error');
      }

      // Save and show goal deletion notification.
      final notification = NotificationModel(
        id: 'goal_${goal.id}_deleted_${DateTime.now().microsecondsSinceEpoch}',
        userId: currentUserId,
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

      return true;
    } catch (error) {
      // Deletion failed, so allow reminder synchronization again.
      _isDeletingGoal = false;

      _errorMessage = 'Could not delete goal. Please try again.';

      debugPrint('DELETE GOAL ERROR: $error');

      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Dispose

  @override
  void dispose() {
    _isDisposed = true;

    _linkedTasksSubscription?.cancel();
    _allTasksSubscription?.cancel();

    super.dispose();
  }
}
