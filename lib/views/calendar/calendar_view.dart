import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'selected_date_section.dart';
import 'view_models/calendar_view_model.dart';
import 'widgets/calendar_header.dart';
import 'widgets/calendar_week_days.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/selected_date_tasks_section.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late final CalendarViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    final userId = FirebaseAuth.instance.currentUser?.uid;

    _viewModel = CalendarViewModel(userId: userId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar Header
                  CalendarHeader(
                    monthName: _viewModel.monthName,
                    year: _viewModel.displayedMonth.year,
                    onPreviousMonth: _viewModel.previousMonth,
                    onNextMonth: _viewModel.nextMonth,
                    onToday: _viewModel.goToToday,
                  ),

                  // Week Days
                  const CalendarWeekDays(),

                  // Calendar Grid
                  CalendarGrid(
                    daysInMonth: _viewModel.daysInMonth,
                    startingWeekday: _viewModel.startingWeekday,
                    totalCalendarCells: _viewModel.totalCalendarCells,
                    selectedDate: _viewModel.selectedDate,
                    displayedMonth: _viewModel.displayedMonth,
                    isSelected: _viewModel.isSelected,
                    isToday: _viewModel.isToday,
                    onDateSelected: _viewModel.selectDate,
                  ),

                  // Selected Date
                  SelectedDateSection(selectedDate: _viewModel.selectedDate),

                  // Tasks of Selected Date
                  SelectedDateTasksSection(
                    tasks: _viewModel.selectedDateTasks,
                    isLoading: _viewModel.isLoading,
                    errorMessage: _viewModel.errorMessage,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
