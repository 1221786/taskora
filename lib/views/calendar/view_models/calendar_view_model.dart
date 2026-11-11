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

    notifyListeners();
  }

  void nextMonth() {
    _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);

    notifyListeners();
  }

  void goToToday() {
    _selectedDate = DateTime.now();
    _displayedMonth = DateTime.now();

    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;

    notifyListeners();
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

  void _listenToTasks() {
    if (_userId == null || _userId.isEmpty) {
      _isLoading = false;
      return;
    }

    _isLoading = true;

    _tasksSubscription = _taskService
        .watchTasks(_userId)
        .listen(
          (tasks) {
            _tasks = tasks;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = 'Could not load tasks. Please try again.';
            notifyListeners();
          },
        );
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
