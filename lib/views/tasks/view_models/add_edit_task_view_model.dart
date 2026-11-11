import 'dart:async';

import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../../goals/models/goal_model.dart';
import '../../goals/services/goal_service.dart';

class AddEditTaskViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  final GoalService _goalService;

  AddEditTaskViewModel({TaskModel? task, GoalService? goalService})
    : _goalService = goalService ?? GoalService() {
    if (task != null) {
      _loadTask(task);
    }
  }

  // Task Information
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Priority and Reminder
  String selectedPriority = 'medium';
  String selectedReminder = 'none';

  // Selected Goal
  String? selectedGoalId;

  // Available Goals
  List<Map<String, String>> goals = [];

  bool isLoading = false;
  bool isLoadingGoals = false;

  String? goalsError;

  TaskModel? _existingTask;

  StreamSubscription<List<GoalModel>>? _goalsSubscription;

  // Load existing task
  void _loadTask(TaskModel task) {
    _existingTask = task;

    titleController.text = task.title;
    descriptionController.text = task.description;
    subjectController.text = task.subject;

    selectedDate = task.dueDate;

    selectedTime = TimeOfDay(
      hour: task.dueDate.hour,
      minute: task.dueDate.minute,
    );

    durationController.text = task.estimatedDuration.toString();

    selectedPriority = task.priority;
    selectedReminder = task.reminder;
    selectedGoalId = task.goalId;
  }

  // Load goals belonging to the current user
  void loadGoals(String userId) {
    if (userId.isEmpty) return;

    _goalsSubscription?.cancel();

    isLoadingGoals = true;
    goalsError = null;
    notifyListeners();

    _goalsSubscription = _goalService
        .watchGoals(userId)
        .listen(
          (goalList) {
            goals = goalList.map((goal) {
              return {'id': goal.id, 'title': goal.title};
            }).toList();

            // Clear selection if the selected goal no longer exists.
            if (selectedGoalId != null &&
                !goals.any((goal) => goal['id'] == selectedGoalId)) {
              selectedGoalId = null;
            }

            isLoadingGoals = false;
            goalsError = null;
            notifyListeners();
          },
          onError: (error) {
            isLoadingGoals = false;
            goalsError = 'Could not load goals.';
            notifyListeners();
          },
        );
  }

  // Select due date
  Future<void> selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      selectedDate = pickedDate;
      notifyListeners();
    }
  }

  // Select due time
  Future<void> selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      selectedTime = pickedTime;
      notifyListeners();
    }
  }

  // Change priority
  void changePriority(String priority) {
    selectedPriority = priority;
    notifyListeners();
  }

  // Change reminder
  void changeReminder(String reminder) {
    selectedReminder = reminder;
    notifyListeners();
  }

  // Change selected goal
  void changeGoal(String? goalId) {
    selectedGoalId = goalId;
    notifyListeners();
  }

  // Validate task information
  bool validateTaskData() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    if (selectedDate == null || selectedTime == null) {
      return false;
    }

    final duration = int.tryParse(durationController.text.trim());

    if (duration == null || duration <= 0) {
      return false;
    }

    final dueDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (!dueDateTime.isAfter(DateTime.now())) {
      return false;
    }

    return true;
  }

  // Prepare task model
  TaskModel? prepareTask({required String userId, required String taskId}) {
    if (!validateTaskData()) {
      return null;
    }

    final dueDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    return TaskModel(
      id: taskId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      subject: subjectController.text.trim(),
      priority: selectedPriority,
      dueDate: dueDateTime,
      estimatedDuration: int.parse(durationController.text.trim()),
      reminder: selectedReminder,
      goalId: selectedGoalId,
      isCompleted: _existingTask?.isCompleted ?? false,
      userId: userId,
      createdAt: _existingTask?.createdAt,
    );
  }

  @override
  void dispose() {
    _goalsSubscription?.cancel();

    titleController.dispose();
    descriptionController.dispose();
    subjectController.dispose();
    durationController.dispose();

    super.dispose();
  }
}
