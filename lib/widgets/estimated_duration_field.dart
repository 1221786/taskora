import 'package:flutter/material.dart';

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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Duration in minutes',
            hintText: 'e.g. 60',
            prefixIcon: Icon(Icons.timer_outlined),
            suffixText: 'Minutes',
            border: OutlineInputBorder(),
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
