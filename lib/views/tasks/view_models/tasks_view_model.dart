import 'dart:async';

import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

import '../../notifications/models/notification_model.dart';
import '../../notifications/services/notification_service.dart';

class TasksViewModel extends ChangeNotifier {
  final String userId;
  final TaskService _taskService;
  final NotificationService _notificationService;

  TasksViewModel({
    required this.userId,
    TaskService? taskService,
    NotificationService? notificationService,
  }) : _taskService = taskService ?? TaskService(),
       _notificationService = notificationService ?? NotificationService() {
    _listenToTasks();
  }

  StreamSubscription<List<TaskModel>>? _tasksSubscription;

  List<TaskModel> _tasks = [];

  String _selectedFilter = 'All Tasks';
  String _searchQuery = '';
  String _selectedSort = 'Due Date';

  bool _isLoading = true;
  bool _isDisposed = false;

  String? _errorMessage;

  // -----------------------------
  // Getters
  // -----------------------------

  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  String get selectedFilter => _selectedFilter;

  String get searchQuery => _searchQuery;

  String get selectedSort => _selectedSort;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> get visibleTasks {
    final convertedTasks = _convertTasks(_tasks);
    final filteredTasks = _filterTasks(convertedTasks);

    return _sortTasks(filteredTasks);
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // -----------------------------
  // Listen to Firestore
  // -----------------------------

  void _listenToTasks() {
    if (userId.isEmpty) {
      _isLoading = false;
      _errorMessage = 'Please login to view your tasks.';
      _notify();
      return;
    }

    _tasksSubscription = _taskService
        .watchTasks(userId)
        .listen(
          (tasks) {
            _tasks = tasks;
            _isLoading = false;
            _errorMessage = null;
            _notify();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = 'Could not load tasks. Please try again.';
            _notify();

            debugPrint('TASKS STREAM ERROR: $error');
          },
        );
  }

  // -----------------------------
  // Search, Filter and Sort
  // -----------------------------

  void setSearchQuery(String value) {
    _searchQuery = value;
    _notify();
  }

  void setFilter(String value) {
    _selectedFilter = value;
    _notify();
  }

  void setSort(String value) {
    _selectedSort = value;
    _notify();
  }

  // -----------------------------
  // Format Task Data
  // -----------------------------

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  List<Map<String, dynamic>> _convertTasks(List<TaskModel> taskModels) {
    final now = DateTime.now();

    return taskModels.map((task) {
      return {
        'id': task.id,
        'task': task,
        'title': task.title,
        'description': task.description,
        'subject': task.subject,
        'priority': task.priority,
        'dueDate': _formatDate(task.dueDate),
        'dueTime': _formatTime(task.dueDate),
        'dueAt': task.dueDate,
        'createdAt': task.createdAt ?? DateTime(2000),
        'duration': '${task.estimatedDuration} min',
        'isCompleted': task.isCompleted,
        'isOverdue': task.dueDate.isBefore(now) && !task.isCompleted,
      };
    }).toList();
  }

  // -----------------------------
  // Filter Tasks
  // -----------------------------

  List<Map<String, dynamic>> _filterTasks(List<Map<String, dynamic>> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final query = _searchQuery.trim().toLowerCase();

    return tasks.where((task) {
      final dueAt = task['dueAt'] as DateTime;
      final isCompleted = task['isCompleted'] as bool;

      switch (_selectedFilter) {
        case 'Today':
          if (dueAt.isBefore(today) || !dueAt.isBefore(tomorrow)) {
            return false;
          }
          break;

        case 'Upcoming':
          if (!dueAt.isAfter(now) || isCompleted) {
            return false;
          }
          break;

        case 'Completed':
          if (!isCompleted) return false;
          break;

        case 'Overdue':
          if (!dueAt.isBefore(now) || isCompleted) {
            return false;
          }
          break;

        case 'All Tasks':
        default:
          break;
      }

      final title = task['title'].toString().toLowerCase();
      final description = task['description'].toString().toLowerCase();
      final subject = task['subject'].toString().toLowerCase();

      return title.contains(query) ||
          description.contains(query) ||
          subject.contains(query);
    }).toList();
  }

  // -----------------------------
  // Sort Tasks
  // -----------------------------

  List<Map<String, dynamic>> _sortTasks(
    List<Map<String, dynamic>> filteredTasks,
  ) {
    final sortedTasks = List<Map<String, dynamic>>.from(filteredTasks);

    switch (_selectedSort) {
      case 'Due Date':
        sortedTasks.sort(
          (a, b) => (a['dueAt'] as DateTime).compareTo(b['dueAt'] as DateTime),
        );
        break;

      case 'Priority':
        const priorityOrder = {'high': 1, 'medium': 2, 'low': 3};

        sortedTasks.sort((a, b) {
          final priorityA =
              priorityOrder[a['priority'].toString().toLowerCase()] ?? 4;

          final priorityB =
              priorityOrder[b['priority'].toString().toLowerCase()] ?? 4;

          return priorityA.compareTo(priorityB);
        });
        break;

      case 'Creation Date':
        sortedTasks.sort(
          (a, b) => (b['createdAt'] as DateTime).compareTo(
            a['createdAt'] as DateTime,
          ),
        );
        break;

      case 'Alphabetical Order':
        sortedTasks.sort(
          (a, b) => a['title'].toString().toLowerCase().compareTo(
            b['title'].toString().toLowerCase(),
          ),
        );
        break;
    }

    return sortedTasks;
  }

  // -----------------------------
  // Save Task
  // -----------------------------

  Future<void> saveTask(TaskModel task) async {
    if (userId.isEmpty || task.userId != userId) {
      throw Exception('Invalid task user.');
    }

    final isNewTask = task.id.isEmpty;

    // Save task in Firestore.
    final savedTaskId = await _taskService.saveTask(task);

    final savedTask = _copyTask(task, id: savedTaskId);

    // Schedule task reminder separately from activity notifications.
    try {
      await _notificationService.scheduleTaskReminder(savedTask);
    } catch (error) {
      debugPrint('TASK REMINDER ERROR: $error');
    }

    // Save activity notification.
    await _saveActivityNotification(
      task: savedTask,
      type: isNewTask
          ? NotificationType.taskCreated
          : NotificationType.taskUpdated,
      title: isNewTask ? 'New Task Created' : 'Task Updated',
      body: isNewTask
          ? 'You created the task "${savedTask.title}".'
          : 'You updated the task "${savedTask.title}".',
    );
  }

  // -----------------------------
  // Toggle Task Completion
  // -----------------------------

  Future<void> toggleTaskCompletion(TaskModel task, bool isCompleted) async {
    // Update task in Firestore.
    await _taskService.updateTaskCompletion(task.id, isCompleted);

    final updatedTask = _copyTask(
      task,
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
      clearCompletedAt: !isCompleted,
    );

    // Update scheduled reminder.
    try {
      if (isCompleted) {
        await _notificationService.cancelTaskReminder(updatedTask);
      } else {
        await _notificationService.scheduleTaskReminder(updatedTask);
      }
    } catch (error) {
      debugPrint('TASK REMINDER UPDATE ERROR: $error');
    }

    // Save activity notification.
    await _saveActivityNotification(
      task: updatedTask,
      type: isCompleted
          ? NotificationType.taskCompleted
          : NotificationType.taskUpdated,
      title: isCompleted ? 'Task Completed' : 'Task Reopened',
      body: isCompleted
          ? 'You completed the task "${task.title}".'
          : 'You marked the task "${task.title}" as incomplete.',
    );
  }

  // -----------------------------
  // Delete Task
  // -----------------------------

  Future<void> deleteTask(TaskModel task) async {
    // Delete task from Firestore.
    await _taskService.deleteTask(task.id);

    // Cancel its scheduled reminder.
    try {
      await _notificationService.cancelTaskReminder(task);
    } catch (error) {
      debugPrint('TASK REMINDER CANCELLATION ERROR: $error');
    }

    // Save activity notification after successful deletion.
    await _saveActivityNotification(
      task: task,
      type: NotificationType.taskDeleted,
      title: 'Task Deleted',
      body: 'You deleted the task "${task.title}".',
    );
  }

  // -----------------------------
  // Save Activity Notification
  // -----------------------------

  Future<void> _saveActivityNotification({
    required TaskModel task,
    required NotificationType type,
    required String title,
    required String body,
  }) async {
    try {
      final now = DateTime.now();

      // Generate a unique ID for every activity notification.
      final notificationId =
          '${task.id}_${type.name}_${now.microsecondsSinceEpoch}';

      final notification = NotificationModel(
        id: notificationId,
        userId: userId,
        title: title,
        body: body,
        type: type,
        taskId: task.id,
        goalId: task.goalId,
        createdAt: now,
        isRead: false,
        isScheduled: false,
      );
      await _notificationService.saveAndShowNotification(notification);
    } catch (error) {
      // A notification failure must not undo a successful task operation.
      debugPrint('TASK ACTIVITY NOTIFICATION ERROR: $error');
    }
  }

  // -----------------------------
  // Copy Task
  // -----------------------------

  TaskModel _copyTask(
    TaskModel task, {
    String? id,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return TaskModel(
      id: id ?? task.id,
      title: task.title,
      description: task.description,
      subject: task.subject,
      priority: task.priority,
      dueDate: task.dueDate,
      estimatedDuration: task.estimatedDuration,
      reminder: task.reminder,
      goalId: task.goalId,
      isCompleted: isCompleted ?? task.isCompleted,
      userId: task.userId,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? task.completedAt,
    );
  }

  // -----------------------------
  // Dispose
  // -----------------------------

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_tasksSubscription?.cancel());
    super.dispose();
  }
}
