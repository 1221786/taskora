import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/goal_model.dart';
import '../view_models/add_edit_goal_view_model.dart';

class AddEditGoalView extends StatefulWidget {
  final GoalModel? goal;

  const AddEditGoalView({super.key, this.goal});

  @override
  State<AddEditGoalView> createState() => _AddEditGoalViewState();
}

class _AddEditGoalViewState extends State<AddEditGoalView> {
  late final AddEditGoalViewModel _viewModel;

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    final userId = FirebaseAuth.instance.currentUser?.uid;

    _viewModel = AddEditGoalViewModel(userId: userId, goal: widget.goal);

    _titleController = TextEditingController(text: _viewModel.title);

    _descriptionController = TextEditingController(
      text: _viewModel.description,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final initialDate = isStartDate
        ? _viewModel.startDate
        : _viewModel.targetDate;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1B2B4F),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null || !mounted) return;

    if (isStartDate) {
      _viewModel.setStartDate(selectedDate);
    } else {
      _viewModel.setTargetDate(selectedDate);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveGoal() async {
    final success = await _viewModel.saveGoal();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.isEditing
                ? 'Goal updated successfully.'
                : 'Goal created successfully.',
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B2B4F),
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB0B5C0), fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xFFE5E8EF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xFFE5E8EF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: Color(0xFF6C63FF),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B2B4F),
          ),
        ),
        const SizedBox(height: 9),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFE5E8EF)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF6C63FF)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1B2B4F),
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9297A5)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        elevation: 0,
        title: Text(
          _viewModel.isEditing ? 'Edit Goal' : 'Create Goal',
          style: const TextStyle(
            color: Color(0xFF1B2B4F),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1B2B4F)),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'Goal Title',
                  hint: 'Enter your goal title',
                  controller: _titleController,
                  onChanged: _viewModel.setTitle,
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Description',
                  hint: 'Describe what you want to achieve',
                  controller: _descriptionController,
                  onChanged: _viewModel.setDescription,
                  maxLines: 4,
                ),

                const SizedBox(height: 20),

                _buildDateField(
                  label: 'Start Date',
                  date: _viewModel.startDate,
                  icon: Icons.calendar_today_outlined,
                  onTap: () => _selectDate(isStartDate: true),
                ),

                const SizedBox(height: 20),

                _buildDateField(
                  label: 'Target Date',
                  date: _viewModel.targetDate,
                  icon: Icons.flag_outlined,
                  onTap: () => _selectDate(isStartDate: false),
                ),

                if (_viewModel.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ],

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _viewModel.isLoading ? null : _saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _viewModel.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _viewModel.isEditing
                                ? 'Update Goal'
                                : 'Create Goal',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
