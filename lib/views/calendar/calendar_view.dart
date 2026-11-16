import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_colors.dart';

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
  late final bool _isUserLoggedIn;

  @override
  void initState() {
    super.initState();

    final userId = FirebaseAuth.instance.currentUser?.uid;

    _isUserLoggedIn = userId != null && userId.isNotEmpty;

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CalendarHeader(
                    monthName: _viewModel.monthName,
                    year: _viewModel.displayedMonth.year,
                    onPreviousMonth: _viewModel.previousMonth,
                    onNextMonth: _viewModel.nextMonth,
                    onToday: _viewModel.goToToday,
                  ),

                  const CalendarWeekDays(),

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

                  SelectedDateSection(selectedDate: _viewModel.selectedDate),

                  if (!_isUserLoggedIn)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'Please login to view your tasks.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
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
