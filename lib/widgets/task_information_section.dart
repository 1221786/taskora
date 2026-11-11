import 'package:flutter/material.dart';

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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Task Title',
            hintText: 'Enter task name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.task_alt),
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
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description_outlined),
          ),
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: subjectController,
          decoration: const InputDecoration(
            labelText: 'Subject / Category',
            hintText: 'Enter subject',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category_outlined),
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
          leading: const Icon(Icons.calendar_today),
          title: const Text('Due Date'),
          subtitle: Text(
            selectedDate == null
                ? 'Select due date'
                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onSelectDate,
        ),

        const Divider(),

        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.access_time),
          title: const Text('Due Time'),
          subtitle: Text(
            selectedTime == null
                ? 'Select due time'
                : selectedTime!.format(context),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onSelectTime,
        ),
      ],
    );
  }
}
