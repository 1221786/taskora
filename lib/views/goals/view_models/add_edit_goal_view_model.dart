import 'package:flutter/material.dart';

import '../models/goal_model.dart';
import '../services/goal_service.dart';

class AddEditGoalViewModel extends ChangeNotifier {
  final GoalService _goalService;
  final GoalModel? _existingGoal;
  final String? _userId;

  AddEditGoalViewModel({
    required String? userId,
    GoalModel? goal,
    GoalService? goalService,
  }) : _userId = userId,
       _existingGoal = goal,
       _goalService = goalService ?? GoalService() {
    _initialize();
  }

  String _title = '';
  String _description = '';

  DateTime _startDate = DateUtils.dateOnly(DateTime.now());
  DateTime _targetDate = DateUtils.dateOnly(
    DateTime.now().add(const Duration(days: 7)),
  );

  bool _isLoading = false;
  String? _errorMessage;

  String get title => _title;
  String get description => _description;
  DateTime get startDate => _startDate;
  DateTime get targetDate => _targetDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isEditing => _existingGoal != null;

  void _initialize() {
    if (_existingGoal == null) return;

    _title = _existingGoal.title;
    _description = _existingGoal.description;
    _startDate = _existingGoal.startDate;
    _targetDate = _existingGoal.targetDate;
  }

  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    _startDate = DateUtils.dateOnly(date);

    if (_targetDate.isBefore(_startDate)) {
      _targetDate = _startDate;
    }

    notifyListeners();
  }

  void setTargetDate(DateTime date) {
    _targetDate = DateUtils.dateOnly(date);
    notifyListeners();
  }

  bool _validate() {
    if (_title.trim().isEmpty) {
      _errorMessage = 'Please enter a goal title.';
      return false;
    }

    if (_targetDate.isBefore(_startDate)) {
      _errorMessage = 'Target date cannot be before start date.';
      return false;
    }

    return true;
  }

  Future<bool> saveGoal() async {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      _errorMessage = 'Please login first.';
      notifyListeners();
      return false;
    }

    if (!_validate()) {
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final goal = GoalModel(
        id: _existingGoal?.id ?? '',
        title: _title.trim(),
        description: _description.trim(),
        startDate: _startDate,
        targetDate: _targetDate,
        userId: userId,
        createdAt: _existingGoal?.createdAt,
      );

      if (isEditing) {
        await _goalService.updateGoal(goal);
      } else {
        await _goalService.addGoal(goal);
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Could not save goal. Please try again.';
      notifyListeners();

      return false;
    }
  }
}
