import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class EstimatedDurationField extends StatelessWidget {
  final TextEditingController controller;

  const EstimatedDurationField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estimated Duration',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            labelText: 'Duration in minutes',
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            hintText: 'e.g. 60',
            hintStyle: const TextStyle(color: AppColors.mutedText),
            prefixIcon: const Icon(
              Icons.timer_outlined,
              color: AppColors.primary,
            ),
            suffixText: 'Minutes',
            suffixStyle: const TextStyle(color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter estimated duration';
            }

            final duration = int.tryParse(value);

            if (duration == null || duration <= 0) {
              return 'Enter a valid duration';
            }

            return null;
          },
        ),
      ],
    );
  }
}
