import 'package:flutter/material.dart';

import '/widgets/task_information_section.dart';
import '/widgets/priority_selector.dart';
import '/widgets/reminder_selector.dart';
import '/widgets/estimated_duration_field.dart';
import '/widgets/goal_selector.dart';

class AddEditTaskView extends StatelessWidget {
  final bool isEditing;

  final GlobalKey<FormState> formKey;

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController subjectController;
  final TextEditingController durationController;

  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  final String selectedPriority;
  final String selectedReminder;
  final String? selectedGoalId;

  final List<Map<String, String>> goals;

  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<String> onReminderChanged;
  final ValueChanged<String?> onGoalChanged;

  final VoidCallback onSave;
  final VoidCallback onCancel;

  const AddEditTaskView({
    super.key,
    this.isEditing = false,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.subjectController,
    required this.durationController,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedPriority,
    required this.selectedReminder,
    required this.selectedGoalId,
    required this.goals,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.onPriorityChanged,
    required this.onReminderChanged,
    required this.onGoalChanged,
    required this.onSave,
    required this.onCancel,
  });

  void _handleSave() {
    if (formKey.currentState!.validate()) {
      onSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Add New Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onCancel,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TaskInformationSection(
                titleController: titleController,
                descriptionController: descriptionController,
                subjectController: subjectController,
                selectedDate: selectedDate,
                selectedTime: selectedTime,
                onSelectDate: onSelectDate,
                onSelectTime: onSelectTime,
              ),

              const SizedBox(height: 24),

              PrioritySelector(
                selectedPriority: selectedPriority,
                onPriorityChanged: onPriorityChanged,
              ),

              const SizedBox(height: 24),

              EstimatedDurationField(controller: durationController),

              const SizedBox(height: 24),

              ReminderSelector(
                selectedReminder: selectedReminder,
                onReminderChanged: onReminderChanged,
              ),

              const SizedBox(height: 24),

              GoalSelector(
                selectedGoalId: selectedGoalId,
                goals: goals,
                onGoalChanged: onGoalChanged,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  child: Text(
                    isEditing ? 'Update Task' : 'Save Task',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
