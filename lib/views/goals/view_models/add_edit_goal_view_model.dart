import 'package:flutter/material.dart';

import '../models/goal_model.dart';
import '../services/goal_service.dart';
import '../../notifications/models/notification_model.dart';
import '../../notifications/services/notification_service.dart';

class AddEditGoalViewModel extends ChangeNotifier {
  final GoalService _goalService;
  final NotificationService _notificationService;
  final GoalModel? _existingGoal;
  final String? _userId;

  AddEditGoalViewModel({
    required String? userId,
    GoalModel? goal,
    GoalService? goalService,
    NotificationService? notificationService,
  }) : _userId = userId,
       _existingGoal = goal,
       _goalService = goalService ?? GoalService(),
       _notificationService = notificationService ?? NotificationService() {
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

  // Initialize existing goal data when editing.
  void _initialize() {
    if (_existingGoal == null) return;

    _title = _existingGoal.title;
    _description = _existingGoal.description;
    _startDate = _existingGoal.startDate;
    _targetDate = _existingGoal.targetDate;
  }

  // Update goal title.
  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  // Update goal description.
  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  // Update start date.
  void setStartDate(DateTime date) {
    _startDate = DateUtils.dateOnly(date);

    if (_targetDate.isBefore(_startDate)) {
      _targetDate = _startDate;
    }

    notifyListeners();
  }

  // Update target date.
  void setTargetDate(DateTime date) {
    _targetDate = DateUtils.dateOnly(date);
    notifyListeners();
  }

  // Validate goal information.
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

  // Schedule or update the goal deadline reminder.
  Future<void> _updateGoalReminder(GoalModel savedGoal) async {
    try {
      await _notificationService.scheduleGoalReminder(savedGoal);
    } catch (error) {
      debugPrint('Goal reminder scheduling failed: $error');
    }
  }

  // Save goal creation or update activity notification.
  Future<void> _saveGoalActivityNotification(
    GoalModel goal,
    NotificationType type,
  ) async {
    final notification = NotificationModel(
      id: 'goal_${goal.id}_${type.name}_${DateTime.now().microsecondsSinceEpoch}',
      userId: goal.userId,
      title: type == NotificationType.goalCreated
          ? 'Goal Created'
          : 'Goal Updated',
      body: type == NotificationType.goalCreated
          ? 'Your goal "${goal.title}" was created successfully.'
          : 'Your goal "${goal.title}" was updated successfully.',
      type: type,
      goalId: goal.id,
      createdAt: DateTime.now(),
    );

    try {
      await _notificationService.saveAndShowNotification(notification);
    } catch (error) {
      debugPrint('GOAL ACTIVITY NOTIFICATION ERROR: $error');
    }
  }

  // Save goal.
  Future<GoalModel?> saveGoal() async {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      _errorMessage = 'Please login first.';
      notifyListeners();
      return null;
    }

    if (!_validate()) {
      notifyListeners();
      return null;
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

      late final GoalModel savedGoal;

      if (isEditing) {
        await _goalService.updateGoal(goal);
        savedGoal = goal;
      } else {
        final goalId = await _goalService.addGoal(goal);

        savedGoal = GoalModel(
          id: goalId,
          title: goal.title,
          description: goal.description,
          startDate: goal.startDate,
          targetDate: goal.targetDate,
          userId: goal.userId,
          createdAt: DateTime.now(),
        );
      }

      // Schedule the deadline reminder after successful saving.
      await _updateGoalReminder(savedGoal);

      // Save and show the activity notification.
      await _saveGoalActivityNotification(
        savedGoal,
        isEditing ? NotificationType.goalUpdated : NotificationType.goalCreated,
      );

      _isLoading = false;
      notifyListeners();

      return savedGoal;
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Could not save goal. Please try again.';
      notifyListeners();

      debugPrint('Save goal failed: $error');

      return null;
    }
  }
}
