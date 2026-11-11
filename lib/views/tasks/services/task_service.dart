import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore;

  TaskService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final String _collectionName = 'tasks';

  // Add a new task
  Future<String> addTask(TaskModel task) async {
    final document = await _firestore
        .collection(_collectionName)
        .add(task.toMap());

    return document.id;
  }

  // Update an existing task
  Future<void> updateTask(TaskModel task) async {
    await _firestore
        .collection(_collectionName)
        .doc(task.id)
        .update(task.toMap());
  }

  // Save: Add or Update
  Future<void> saveTask(TaskModel task) async {
    if (task.id.isEmpty) {
      await addTask(task);
    } else {
      await updateTask(task);
    }
  }

  // Update task completion status
  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    await _firestore.collection(_collectionName).doc(taskId).update({
      'isCompleted': isCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection(_collectionName).doc(taskId).delete();
  }

  // Listen to the current user's tasks
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
