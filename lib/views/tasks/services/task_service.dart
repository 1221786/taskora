import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore;

  TaskService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final String _collectionName = 'tasks';

  // Add a new task and return its Firestore document ID.
  Future<String> addTask(TaskModel task) async {
    final document = await _firestore
        .collection(_collectionName)
        .add(task.toMap());

    return document.id;
  }

  // Update an existing task.
  Future<void> updateTask(TaskModel task) async {
    await _firestore
        .collection(_collectionName)
        .doc(task.id)
        .update(task.toMap());
  }

  // Save a task and return its document ID.
  Future<String> saveTask(TaskModel task) async {
    if (task.id.isEmpty) {
      return await addTask(task);
    }

    await updateTask(task);
    return task.id;
  }

  // Update task completion status and completion date.
  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    await _firestore.collection(_collectionName).doc(taskId).update({
      'isCompleted': isCompleted,
      'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete a task.
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection(_collectionName).doc(taskId).delete();
  }

  // Listen to the current user's tasks.
  Stream<List<TaskModel>> watchTasks(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((document) {
            return TaskModel.fromMap(document.data(), document.id);
          }).toList();
        });
  }
}
