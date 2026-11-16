import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class TaskInformationSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController subjectController;

  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  const TaskInformationSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.subjectController,
    required this.selectedDate,
    required this.selectedTime,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Task Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Task Title',
            hintText: 'Enter task name',
            prefixIcon: Icon(Icons.task_alt, color: AppColors.textSecondary),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter task title';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Enter task description',
            prefixIcon: Icon(
              Icons.description_outlined,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: subjectController,
          decoration: const InputDecoration(
            labelText: 'Subject / Category',
            hintText: 'Enter subject',
            prefixIcon: Icon(
              Icons.category_outlined,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter subject';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today, color: AppColors.primary),
          title: const Text(
            'Due Date',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            selectedDate == null
                ? 'Select due date'
                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.mutedText),
          onTap: onSelectDate,
        ),

        const Divider(color: AppColors.border),

        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.access_time, color: AppColors.primary),
          title: const Text(
            'Due Time',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            selectedTime == null
                ? 'Select due time'
                : selectedTime!.format(context),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.mutedText),
          onTap: onSelectTime,
        ),
      ],
    );
  }
}
