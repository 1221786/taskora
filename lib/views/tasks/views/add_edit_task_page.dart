import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../view_models/add_edit_task_view_model.dart';
import 'add_edit_task_view.dart';
import 'package:flutter/foundation.dart';

class AddEditTaskPage extends StatefulWidget {
  final String userId;
  final TaskModel? task;
  final List<Map<String, String>> goals;
  final Future<void> Function(TaskModel task) onSaveTask;

  const AddEditTaskPage({
    super.key,
    required this.userId,
    required this.onSaveTask,
    this.task,
    this.goals = const [],
  });

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  late final AddEditTaskViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = AddEditTaskViewModel(task: widget.task);

    // Load the current user's goals from Firestore.
    viewModel.loadGoals(widget.userId);
  }

  Future<void> _saveTask() async {
    if (!viewModel.validateTaskData()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields correctly.'),
        ),
      );
      return;
    }

    final task = viewModel.prepareTask(
      userId: widget.userId,
      taskId: widget.task?.id ?? '',
    );

    if (task == null) return;

    try {
      await widget.onSaveTask(task);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (error, stackTrace) {
      debugPrint('TASK SAVE ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save task. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,

      builder: (context, child) {
        return AddEditTaskView(
          isEditing: widget.task != null,

          formKey: viewModel.formKey,

          titleController: viewModel.titleController,
          descriptionController: viewModel.descriptionController,
          subjectController: viewModel.subjectController,
          durationController: viewModel.durationController,

          selectedDate: viewModel.selectedDate,
          selectedTime: viewModel.selectedTime,

          selectedPriority: viewModel.selectedPriority,
          selectedReminder: viewModel.selectedReminder,
          selectedGoalId: viewModel.selectedGoalId,

          goals: viewModel.goals,

          onSelectDate: () {
            viewModel.selectDate(context);
          },

          onSelectTime: () {
            viewModel.selectTime(context);
          },

          onPriorityChanged: viewModel.changePriority,
          onReminderChanged: viewModel.changeReminder,
          onGoalChanged: viewModel.changeGoal,

          onSave: _saveTask,
          onCancel: () => Navigator.pop(context),
        );
      },
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }
}
