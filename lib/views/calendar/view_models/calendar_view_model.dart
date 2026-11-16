import 'dart:async';

import 'package:flutter/material.dart';

import '../../tasks/models/task_model.dart';
import '../../tasks/services/task_service.dart';

class CalendarViewModel extends ChangeNotifier {
  final TaskService _taskService;
  final String? _userId;

  DateTime _selectedDate = DateTime.now();
  DateTime _displayedMonth = DateTime.now();

  List<TaskModel> _tasks = [];

  bool _isLoading = false;
  bool _isDisposed = false;

  String? _errorMessage;

  StreamSubscription<List<TaskModel>>? _tasksSubscription;

  CalendarViewModel({String? userId, TaskService? taskService})
    : _userId = userId,
      _taskService = taskService ?? TaskService() {
    _listenToTasks();
  }

  // Calendar dates

  DateTime get selectedDate => _selectedDate;

  DateTime get displayedMonth => _displayedMonth;

  String get monthName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[_displayedMonth.month - 1];
  }

  void previousMonth() {
    _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);

    _notify();
  }

  void nextMonth() {
    _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);

    _notify();
  }

  void goToToday() {
    final today = DateTime.now();

    _selectedDate = today;
    _displayedMonth = today;

    _notify();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;

    if (date.year != _displayedMonth.year ||
        date.month != _displayedMonth.month) {
      _displayedMonth = DateTime(date.year, date.month);
    }

    _notify();
  }

  bool isSelected(DateTime date) {
    return _isSameDay(_selectedDate, date);
  }

  bool isToday(DateTime date) {
    return _isSameDay(DateTime.now(), date);
  }

  int get daysInMonth {
    return DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
  }

  int get startingWeekday {
    return DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday - 1;
  }

  int get totalCalendarCells {
    return ((startingWeekday + daysInMonth + 6) ~/ 7) * 7;
  }

  // Tasks information

  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  List<TaskModel> get selectedDateTasks {
    return _tasks.where((task) {
      return _isSameDay(task.dueDate, _selectedDate);
    }).toList();
  }

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // Listen to Firestore tasks

  void _listenToTasks() {
    if (_userId == null || _userId.isEmpty) {
      _isLoading = false;
      _errorMessage = 'Please login to view your tasks.';
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    _tasksSubscription = _taskService
        .watchTasks(_userId)
        .listen(
          (tasks) {
            if (_isDisposed) return;

            _tasks = tasks;
            _isLoading = false;
            _errorMessage = null;

            _notify();
          },
          onError: (error) {
            if (_isDisposed) return;

            _isLoading = false;
            _errorMessage = 'Could not load tasks. Please try again.';

            debugPrint('CALENDAR TASKS ERROR: $error');

            _notify();
          },
        );
  }

  // Helper methods

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _tasksSubscription?.cancel();

    super.dispose();
  }
}
