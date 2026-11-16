import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../tasks/models/task_model.dart';
import '../tasks/services/task_service.dart';

import '../profile/models/profile_model.dart';
import '../profile/services/profile_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final TaskService _taskService;
  final ProfileService _profileService;

  DashboardViewModel({
    TaskService? taskService,
    ProfileService? profileService,
    String? userId,
  }) : _taskService = taskService ?? TaskService(),
       _profileService = profileService ?? ProfileService() {
    final currentUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId != null && currentUserId.isNotEmpty) {
      _listenToTasks(currentUserId);
      _listenToProfile(currentUserId);
    } else {
      isLoadingTasks = false;
      isLoadingProfile = false;
    }
  }

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changePage(int index) {
    if (index < 0 || index > 4) return;
    if (_currentIndex == index) return;

    _currentIndex = index;
    notifyListeners();
  }

  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => _tasks;

  ProfileModel? profile;

  bool isLoadingTasks = true;
  bool isLoadingProfile = true;

  String? errorMessage;

  StreamSubscription<List<TaskModel>>? _tasksSubscription;
  StreamSubscription<ProfileModel?>? _profileSubscription;

  void _listenToTasks(String userId) {
    _tasksSubscription = _taskService
        .watchTasks(userId)
        .listen(
          (tasks) {
            _tasks = tasks;
            isLoadingTasks = false;
            errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            isLoadingTasks = false;
            errorMessage = 'Unable to load tasks.';
            notifyListeners();
          },
        );
  }

  void _listenToProfile(String userId) {
    _profileSubscription = _profileService
        .watchProfile(userId)
        .listen(
          (userProfile) {
            profile = userProfile;
            isLoadingProfile = false;
            notifyListeners();
          },
          onError: (error) {
            isLoadingProfile = false;
            notifyListeners();
          },
        );
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  List<TaskModel> get todayTasks {
    final now = DateTime.now();

    final result = _tasks
        .where((task) => _isSameDay(task.dueDate, now))
        .toList();

    result.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return result;
  }

  int get completedTodayCount {
    return todayTasks.where((task) => task.isCompleted).length;
  }

  int get totalTodayCount => todayTasks.length;

  int get remainingTodayCount => totalTodayCount - completedTodayCount;

  double get todayProgress {
    if (totalTodayCount == 0) return 0;

    return completedTodayCount / totalTodayCount;
  }

  List<TaskModel> get upcomingTasks {
    final now = DateTime.now();

    final result = _tasks.where((task) {
      return !task.isCompleted && !_isSameDay(task.dueDate, now);
    }).toList();

    result.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return result;
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    try {
      await _taskService.updateTaskCompletion(task.id, !task.isCompleted);
    } catch (error) {
      errorMessage = 'Unable to update task.';
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
    } catch (error) {
      errorMessage = 'Unable to delete task.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }
}
