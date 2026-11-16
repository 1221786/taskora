import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../tasks/models/task_model.dart';
import '../../tasks/services/task_service.dart';

enum StatisticsPeriod { today, week, month }

class StatisticsViewModel extends ChangeNotifier {
  final TaskService _taskService;
  final FirebaseAuth _auth;

  StatisticsViewModel({TaskService? taskService, FirebaseAuth? auth})
    : _taskService = taskService ?? TaskService(),
      _auth = auth ?? FirebaseAuth.instance;

  StreamSubscription<List<TaskModel>>? _tasksSubscription;

  List<TaskModel> _tasks = [];

  StatisticsPeriod _selectedPeriod = StatisticsPeriod.today;

  bool _isLoading = true;
  String? _errorMessage;

  List<TaskModel> get tasks => _tasks;

  StatisticsPeriod get selectedPeriod => _selectedPeriod;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // Listen to the current user's tasks.
  void initialize() {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      _isLoading = false;
      _errorMessage = 'Please log in to view statistics.';
      notifyListeners();
      return;
    }

    _tasksSubscription = _taskService
        .watchTasks(userId)
        .listen(
          (tasks) {
            _tasks = tasks;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = 'Unable to load statistics.';
            notifyListeners();
          },
        );
  }

  // Change the selected statistics period.
  void changePeriod(StatisticsPeriod period) {
    if (_selectedPeriod == period) return;

    _selectedPeriod = period;
    notifyListeners();
  }

  // Get the selected period's date range.
  DateTime get periodStart {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case StatisticsPeriod.today:
        return DateTime(now.year, now.month, now.day);

      case StatisticsPeriod.week:
        final today = DateTime(now.year, now.month, now.day);
        return today.subtract(Duration(days: today.weekday - 1));

      case StatisticsPeriod.month:
        return DateTime(now.year, now.month, 1);
    }
  }

  DateTime get periodEnd {
    switch (_selectedPeriod) {
      case StatisticsPeriod.today:
        return periodStart.add(const Duration(days: 1));

      case StatisticsPeriod.week:
        return periodStart.add(const Duration(days: 7));

      case StatisticsPeriod.month:
        return DateTime(periodStart.year, periodStart.month + 1, 1);
    }
  }

  bool _isWithinPeriod(DateTime date) {
    return !date.isBefore(periodStart) && date.isBefore(periodEnd);
  }

  // Tasks whose due dates fall within the selected period.
  List<TaskModel> get periodTasks {
    return _tasks.where((task) => _isWithinPeriod(task.dueDate)).toList();
  }

  int get totalTasks => periodTasks.length;

  int get completedTasks =>
      periodTasks.where((task) => task.isCompleted).length;

  int get pendingTasks => totalTasks - completedTasks;

  double get completionRate {
    if (totalTasks == 0) return 0;
    return completedTasks / totalTasks * 100;
  }

  // Tasks completed during the selected period.
  List<TaskModel> get completedInPeriod {
    return _tasks.where((task) {
      final completedAt = task.completedAt;
      return task.isCompleted &&
          completedAt != null &&
          _isWithinPeriod(completedAt);
    }).toList();
  }

  // Completed tasks grouped by hour for today.
  List<int> get todayCompletionData {
    final counts = List<int>.filled(24, 0);

    for (final task in completedInPeriod) {
      final hour = task.completedAt!.hour;
      counts[hour]++;
    }

    return counts;
  }

  // Completed tasks grouped by weekday for the selected week.
  List<int> get weeklyCompletionData {
    final counts = List<int>.filled(7, 0);

    for (final task in completedInPeriod) {
      final dayIndex = task.completedAt!.weekday - 1;
      counts[dayIndex]++;
    }

    return counts;
  }

  // Completed tasks grouped by week for the selected month.
  List<int> get monthlyCompletionData {
    final numberOfWeeks = ((periodEnd.day - 1) ~/ 7) + 1;
    final counts = List<int>.filled(numberOfWeeks, 0);

    for (final task in completedInPeriod) {
      final weekIndex = (task.completedAt!.day - 1) ~/ 7;

      if (weekIndex < counts.length) {
        counts[weekIndex]++;
      }
    }

    return counts;
  }

  List<int> get completionChartData {
    switch (_selectedPeriod) {
      case StatisticsPeriod.today:
        return todayCompletionData;
      case StatisticsPeriod.week:
        return weeklyCompletionData;
      case StatisticsPeriod.month:
        return monthlyCompletionData;
    }
  }

  // Tasks grouped by priority.
  Map<String, int> get priorityData {
    return {
      'High': periodTasks
          .where((task) => task.priority.toLowerCase() == 'high')
          .length,
      'Medium': periodTasks
          .where((task) => task.priority.toLowerCase() == 'medium')
          .length,
      'Low': periodTasks
          .where((task) => task.priority.toLowerCase() == 'low')
          .length,
    };
  }

  // Completion percentage for each day in the selected week.
  List<double> get weeklyProductivityData {
    final result = List<double>.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final dayStart = periodStart.add(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayTasks = _tasks.where((task) {
        return !task.dueDate.isBefore(dayStart) &&
            task.dueDate.isBefore(dayEnd);
      }).toList();

      if (dayTasks.isEmpty) continue;

      final completed = dayTasks.where((task) => task.isCompleted).length;

      result[i] = completed / dayTasks.length * 100;
    }

    return result;
  }

  // Completion percentage for each day in the selected period.
  List<double> get productivityData {
    if (_selectedPeriod == StatisticsPeriod.week) {
      return weeklyProductivityData;
    }

    if (_selectedPeriod == StatisticsPeriod.today) {
      return [completionRate];
    }

    final numberOfDays = periodEnd.difference(periodStart).inDays;
    final result = <double>[];

    for (int i = 0; i < numberOfDays; i++) {
      final dayStart = periodStart.add(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayTasks = _tasks.where((task) {
        return !task.dueDate.isBefore(dayStart) &&
            task.dueDate.isBefore(dayEnd);
      }).toList();

      if (dayTasks.isEmpty) {
        result.add(0);
      } else {
        final completed = dayTasks.where((task) => task.isCompleted).length;

        result.add(completed / dayTasks.length * 100);
      }
    }

    return result;
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
