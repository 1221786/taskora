import 'package:flutter/material.dart';

import '../models/task_model.dart';

class AddEditTaskViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController subjectController = TextEditingController();

  final TextEditingController durationController = TextEditingController();

  AddEditTaskViewModel({TaskModel? task, String? initialGoalId}) {
    if (task != null) {
      _loadTask(task);
    } else {
      selectedGoalId = initialGoalId;
    }
  }

  // Task information
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Priority and reminder
  String selectedPriority = 'medium';
  String selectedReminder = 'none';

  // Automatically assigned goal ID
  String? selectedGoalId;

  TaskModel? _existingTask;

  // Load existing task data
  void _loadTask(TaskModel task) {
    _existingTask = task;

    titleController.text = task.title;
    descriptionController.text = task.description;
    subjectController.text = task.subject;
    durationController.text = task.estimatedDuration.toString();

    selectedDate = task.dueDate;

    selectedTime = TimeOfDay(
      hour: task.dueDate.hour,
      minute: task.dueDate.minute,
    );

    selectedPriority = task.priority;
    selectedReminder = task.reminder;

    // Preserve the original goal when editing.
    selectedGoalId = task.goalId;
  }

  // Select due date
  Future<void> selectDate(BuildContext context) async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
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
    titleController.dispose();
    descriptionController.dispose();
    subjectController.dispose();
    durationController.dispose();

    super.dispose();
  }
}
