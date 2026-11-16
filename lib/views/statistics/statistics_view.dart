import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'view_models/statistics_view_model.dart';
import 'package:flutter/foundation.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  late final StatisticsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = StatisticsViewModel();
    _viewModel.initialize();
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
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_viewModel.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildPeriodSelector(),
                  const SizedBox(height: 22),
                  _buildSummaryCards(),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    'Tasks Completed',
                    'Track your daily achievements',
                  ),
                  const SizedBox(height: 14),
                  _buildTasksChart(),
                  const SizedBox(height: 26),
                  _buildSectionTitle(
                    'Weekly Productivity',
                    'Your productivity overview',
                  ),
                  const SizedBox(height: 14),
                  _buildProductivityChart(),
                  const SizedBox(height: 26),
                  _buildSectionTitle(
                    'Tasks by Priority',
                    'Distribution of your tasks',
                  ),
                  const SizedBox(height: 14),
                  _buildPriorityChart(),
                  const SizedBox(height: 26),
                  _buildSectionTitle(
                    'Completion Overview',
                    'Completed vs pending tasks',
                  ),
                  const SizedBox(height: 14),
                  _buildCompletionOverview(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Keep track of your study progress',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _periodButton('Today', StatisticsPeriod.today),
          _periodButton('This Week', StatisticsPeriod.week),
          _periodButton('This Month', StatisticsPeriod.month),
        ],
      ),
    );
  }

  Widget _periodButton(String label, StatisticsPeriod period) {
    final isSelected = _viewModel.selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () => _viewModel.changePeriod(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final total = _viewModel.totalTasks;
    final completed = _viewModel.completedTasks;
    final pending = _viewModel.pendingTasks;
    final rate = _viewModel.completionRate.round();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Total Tasks',
                value: '$total',
                icon: Icons.assignment_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                title: 'Completed',
                value: '$completed',
                icon: Icons.check_circle_outline,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Pending',
                value: '$pending',
                icon: Icons.pending_actions_outlined,
                color: const Color(0xFFE6A23C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                title: 'Completion Rate',
                value: '$rate%',
                icon: Icons.trending_up_rounded,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _chartContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  // Group today's 24 hours into 6 four-hour intervals.
  List<int> get _tasksChartValues {
    switch (_viewModel.selectedPeriod) {
      case StatisticsPeriod.today:
        final hourlyData = _viewModel.todayCompletionData;

        return List.generate(6, (index) {
          return hourlyData
              .skip(index * 4)
              .take(4)
              .fold<int>(0, (sum, value) => sum + value);
        });

      case StatisticsPeriod.week:
        return _viewModel.weeklyCompletionData;

      case StatisticsPeriod.month:
        return _viewModel.monthlyCompletionData;
    }
  }

  List<String> get _tasksChartLabels {
    switch (_viewModel.selectedPeriod) {
      case StatisticsPeriod.today:
        return ['12 AM', '4 AM', '8 AM', '12 PM', '4 PM', '8 PM'];

      case StatisticsPeriod.week:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      case StatisticsPeriod.month:
        return List.generate(
          _viewModel.monthlyCompletionData.length,
          (index) => 'Week ${index + 1}',
        );
    }
  }

  Widget _buildTasksChart() {
    final values = _tasksChartValues;
    final labels = _tasksChartLabels;

    final maxValue = values.isEmpty ? 0 : values.reduce(math.max);

    return _chartContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Completed Tasks',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Icon(Icons.bar_chart_rounded, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 24),
          if (values.every((value) => value == 0))
            _emptyChartMessage()
          else
            SizedBox(
              height: 175,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(values.length, (index) {
                  final barHeight = maxValue == 0
                      ? 0.0
                      : (values[index] / maxValue) * 125;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${values[index]}',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: barHeight,
                          width: 17,
                          decoration: BoxDecoration(
                            color: index == values.length - 1
                                ? AppColors.accent
                                : AppColors.primary.withValues(alpha: 0.75),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          labels[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  List<String> get _productivityLabels {
    switch (_viewModel.selectedPeriod) {
      case StatisticsPeriod.today:
        return ['Today'];

      case StatisticsPeriod.week:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      case StatisticsPeriod.month:
        return List.generate(
          _viewModel.productivityData.length,
          (index) => '${index + 1}',
        );
    }
  }

  Widget _buildProductivityChart() {
    final values = _viewModel.productivityData;
    final labels = _productivityLabels;

    return _chartContainer(
      child: Column(
        children: List.generate(values.length, (index) {
          final value = values[index].clamp(0.0, 100.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                SizedBox(
                  width: 55,
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: value / 100,
                      minHeight: 9,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 35,
                  child: Text(
                    '${value.round()}%',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPriorityChart() {
    final priorityData = _viewModel.priorityData;

    final values = [
      priorityData['High'] ?? 0,
      priorityData['Medium'] ?? 0,
      priorityData['Low'] ?? 0,
    ];

    final total = values.fold<int>(0, (sum, value) => sum + value);

    const colors = [Color(0xFFE57373), Color(0xFFF5B942), Color(0xFF43B581)];

    const labels = ['High', 'Medium', 'Low'];

    return _chartContainer(
      child: Column(
        children: [
          SizedBox(
            height: 175,
            child: Center(
              child: SizedBox(
                height: 155,
                width: 155,
                child: CustomPaint(
                  painter: _DonutChartPainter(values: values, colors: colors),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Total Tasks',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      '${labels[index]} Priority',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '${values[index]} tasks',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompletionOverview() {
    final completed = _viewModel.completedTasks;
    final pending = _viewModel.pendingTasks;
    final total = _viewModel.totalTasks;

    final completedRatio = total == 0 ? 0.0 : completed / total;
    final pendingRatio = total == 0 ? 0.0 : pending / total;

    return _chartContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Task Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '$total Tasks',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: total == 0
                ? Container(height: 13, color: AppColors.border)
                : Row(
                    children: [
                      Expanded(
                        flex: completed,
                        child: Container(height: 13, color: AppColors.accent),
                      ),
                      Expanded(
                        flex: pending,
                        child: Container(
                          height: 13,
                          color: const Color(0xFFE6A23C),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 18),
          _statusLegend(
            'Completed',
            completed,
            '${(completedRatio * 100).round()}%',
            AppColors.accent,
          ),
          const SizedBox(height: 12),
          _statusLegend(
            'Pending',
            pending,
            '${(pendingRatio * 100).round()}%',
            const Color(0xFFE6A23C),
          ),
        ],
      ),
    );
  }

  Widget _statusLegend(
    String title,
    int count,
    String percentage,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        Text(
          '$count tasks',
          style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 15),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _emptyChartMessage() {
    return SizedBox(
      height: 130,
      child: Center(
        child: Text(
          'No completed tasks in this period yet.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<int> values;
  final List<Color> colors;

  _DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<int>(0, (sum, value) => sum + value);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    if (total == 0) {
      paint.color = AppColors.border;
      canvas.drawArc(rect, 0, 2 * math.pi, false, paint);
      return;
    }

    double startAngle = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      if (values[i] == 0) continue;

      final sweepAngle = (values[i] / total) * 2 * math.pi;

      paint.color = colors[i];

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return !listEquals(oldDelegate.values, values) ||
        !listEquals(oldDelegate.colors, colors);
  }
}
