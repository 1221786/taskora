import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskora/views/tasks/tasks_list_section.dart';

import 'tasks_header.dart';
import 'tasks_search_section.dart';
import 'tasks_filter_section.dart';
import 'tasks_sort_section.dart';

import 'views/task_details_page.dart';
import 'views/add_edit_task_page.dart';
import 'services/task_service.dart';
import 'models/task_model.dart';
import '../calendar/calendar_view.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  final TaskService _taskService = TaskService();

  String selectedFilter = 'All Tasks';
  String searchQuery = '';
  String selectedSort = 'Due Date';

  // Open Add Task Screen
  Future<void> _openAddTask() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first.')));
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskPage(
          userId: user.uid,
          onSaveTask: _taskService.saveTask,
        ),
      ),
    );
  }

  // Open Edit Task Screen
  Future<void> _openEditTask(TaskModel task) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskPage(
          userId: user.uid,
          task: task,
          onSaveTask: _taskService.saveTask,
        ),
      ),
    );
  }

  // Open Task Details Screen
  Future<void> _openTaskDetails(TaskModel task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsPage(task: task)),
    );
  }

  // Open Calendar Screen
  Future<void> _openCalendar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarView()),
    );
  }

  // Toggle task completion
  Future<void> _toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await _taskService.updateTaskCompletion(taskId, isCompleted);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCompleted
                ? 'Task marked as completed.'
                : 'Task marked as incomplete.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update task. Please try again.'),
        ),
      );

      debugPrint('TASK UPDATE ERROR: $e');
    }
  }

  // Delete task after confirmation
  Future<void> _deleteTask(String taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _taskService.deleteTask(taskId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete task. Please try again.'),
        ),
      );

      debugPrint('TASK DELETE ERROR: $e');
    }
  }

  // Format date
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Format time
  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // Convert TaskModel to the map used by the task cards
  List<Map<String, dynamic>> _convertTasks(List<TaskModel> taskModels) {
    final now = DateTime.now();

    return taskModels.map((task) {
      return {
        'id': task.id,
        'task': task,
        'title': task.title,
        'description': task.description,
        'subject': task.subject,
        'priority': task.priority,
        'dueDate': _formatDate(task.dueDate),
        'dueTime': _formatTime(task.dueDate),
        'dueAt': task.dueDate,
        'createdAt': task.createdAt ?? DateTime(2000),
        'duration': '${task.estimatedDuration} min',
        'isCompleted': task.isCompleted,
        'isOverdue': task.dueDate.isBefore(now) && !task.isCompleted,
      };
    }).toList();
  }

  // Filter tasks
  List<Map<String, dynamic>> _filterTasks(List<Map<String, dynamic>> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return tasks.where((task) {
      final dueAt = task['dueAt'] as DateTime;
      final isCompleted = task['isCompleted'] as bool;

      switch (selectedFilter) {
        case 'Today':
          if (dueAt.isBefore(today) || !dueAt.isBefore(tomorrow)) {
            return false;
          }
          break;

        case 'Upcoming':
          if (!dueAt.isAfter(now) || isCompleted) {
            return false;
          }
          break;

        case 'Completed':
          if (!isCompleted) return false;
          break;

        case 'Overdue':
          if (!dueAt.isBefore(now) || isCompleted) {
            return false;
          }
          break;

        case 'All Tasks':
        default:
          break;
      }

      final query = searchQuery.trim().toLowerCase();

      final title = task['title'].toString().toLowerCase();
      final description = task['description'].toString().toLowerCase();
      final subject = task['subject'].toString().toLowerCase();

      return title.contains(query) ||
          description.contains(query) ||
          subject.contains(query);
    }).toList();
  }

  // Sort tasks
  List<Map<String, dynamic>> _sortTasks(
    List<Map<String, dynamic>> filteredTasks,
  ) {
    final sortedTasks = List<Map<String, dynamic>>.from(filteredTasks);

    switch (selectedSort) {
      case 'Due Date':
        sortedTasks.sort(
          (a, b) => (a['dueAt'] as DateTime).compareTo(b['dueAt'] as DateTime),
        );
        break;

      case 'Priority':
        const priorityOrder = {'high': 1, 'medium': 2, 'low': 3};

        sortedTasks.sort((a, b) {
          final priorityA =
              priorityOrder[a['priority'].toString().toLowerCase()] ?? 4;

          final priorityB =
              priorityOrder[b['priority'].toString().toLowerCase()] ?? 4;

          return priorityA.compareTo(priorityB);
        });
        break;

      case 'Creation Date':
        sortedTasks.sort(
          (a, b) => (b['createdAt'] as DateTime).compareTo(
            a['createdAt'] as DateTime,
          ),
        );
        break;

      case 'Alphabetical Order':
        sortedTasks.sort(
          (a, b) => a['title'].toString().toLowerCase().compareTo(
            b['title'].toString().toLowerCase(),
          ),
        );
        break;
    }

    return sortedTasks;
  }

  // Build the tasks list from Firestore
  Widget _buildTasksList(String userId) {
    return StreamBuilder<List<TaskModel>>(
      stream: _taskService.watchTasks(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Could not load tasks. Please try again.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final taskModels = snapshot.data ?? [];

        final tasks = _convertTasks(taskModels);
        final filteredTasks = _filterTasks(tasks);
        final sortedTasks = _sortTasks(filteredTasks);

        return TasksListSection(
          tasks: sortedTasks,
          title: selectedFilter,
          onComplete: _toggleTaskCompletion,
          onDelete: _deleteTask,
          onEdit: _openEditTask,
          onViewDetails: _openTaskDetails,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TasksHeader(
                onAddTask: _openAddTask,
                onOpenCalendar: _openCalendar,
              ),

              const SizedBox(height: 22),

              TasksSearchSection(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              TasksFilterSection(
                selectedFilter: selectedFilter,
                onFilterChanged: (value) {
                  setState(() {
                    selectedFilter = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              TasksSortSection(
                selectedSort: selectedSort,
                onSortChanged: (value) {
                  setState(() {
                    selectedSort = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              if (user == null)
                const Text('Please login to view your tasks.')
              else
                _buildTasksList(user.uid),
            ],
          ),
        ),
      ),
    );
  }
}
