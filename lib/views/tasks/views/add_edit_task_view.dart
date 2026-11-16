import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/widgets/task_information_section.dart';
import '/widgets/priority_selector.dart';
import '/widgets/reminder_selector.dart';
import '/widgets/estimated_duration_field.dart';

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

  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<String> onReminderChanged;

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
    required this.onSelectDate,
    required this.onSelectTime,
    required this.onPriorityChanged,
    required this.onReminderChanged,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Task' : 'Add New Task',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
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

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
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
