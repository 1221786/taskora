import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/goal_model.dart';
import '../../tasks/models/task_model.dart';

class GoalService {
  final FirebaseFirestore _firestore;

  GoalService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final String _goalsCollection = 'goals';
  final String _tasksCollection = 'tasks';

  // Add a new goal
  Future<String> addGoal(GoalModel goal) async {
    final document = await _firestore
        .collection(_goalsCollection)
        .add(goal.toMap());

    return document.id;
  }

  // Update an existing goal
  Future<void> updateGoal(GoalModel goal) async {
    await _firestore
        .collection(_goalsCollection)
        .doc(goal.id)
        .update(goal.toMap());
  }

  // Watch all goals for a specific user
  Stream<List<GoalModel>> watchGoals(String userId) {
    return _firestore
        .collection(_goalsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((document) {
            return GoalModel.fromMap(document.data(), document.id);
          }).toList();
        });
  }

  // Watch tasks linked to a specific goal
  Stream<List<TaskModel>> watchGoalTasks({
    required String userId,
    required String goalId,
  }) {
    return _firestore
        .collection(_tasksCollection)
        .where('userId', isEqualTo: userId)
        .where('goalId', isEqualTo: goalId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((document) {
            return TaskModel.fromMap(document.data(), document.id);
          }).toList();
        });
  }

  // Link an existing task to a goal
  Future<void> linkTaskToGoal({
    required String taskId,
    required String goalId,
    required String userId,
  }) async {
    final goalDocument = await _firestore
        .collection(_goalsCollection)
        .doc(goalId)
        .get();

    final taskDocument = await _firestore
        .collection(_tasksCollection)
        .doc(taskId)
        .get();

    if (!goalDocument.exists || !taskDocument.exists) {
      throw Exception('Goal or task was not found.');
    }

    if (goalDocument.data()?['userId'] != userId ||
        taskDocument.data()?['userId'] != userId) {
      throw Exception('You cannot link this task to this goal.');
    }

    await taskDocument.reference.update({
      'goalId': goalId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove a task from a goal
  Future<void> unlinkTaskFromGoal({
    required String taskId,
    required String userId,
  }) async {
    final taskDocument = await _firestore
        .collection(_tasksCollection)
        .doc(taskId)
        .get();

    if (!taskDocument.exists) {
      throw Exception('Task was not found.');
    }

    if (taskDocument.data()?['userId'] != userId) {
      throw Exception('You cannot modify this task.');
    }

    await taskDocument.reference.update({
      'goalId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete a goal without deleting its linked tasks
  Future<void> deleteGoal({
    required String goalId,
    required String userId,
  }) async {
    final goalReference = _firestore.collection(_goalsCollection).doc(goalId);

    final goalDocument = await goalReference.get();

    if (!goalDocument.exists || goalDocument.data()?['userId'] != userId) {
      throw Exception('Goal was not found.');
    }

    final linkedTasks = await _firestore
        .collection(_tasksCollection)
        .where('userId', isEqualTo: userId)
        .where('goalId', isEqualTo: goalId)
        .get();

    // Detach linked tasks in batches.
    for (var i = 0; i < linkedTasks.docs.length; i += 450) {
      final batch = _firestore.batch();
      final end = (i + 450 < linkedTasks.docs.length)
          ? i + 450
          : linkedTasks.docs.length;

      for (final task in linkedTasks.docs.sublist(i, end)) {
        batch.update(task.reference, {
          'goalId': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    }

    await goalReference.delete();
  }
}
