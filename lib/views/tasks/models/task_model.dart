import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String priority;
  final DateTime dueDate;
  final int estimatedDuration;
  final String reminder;
  final String? goalId;
  final bool isCompleted;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.subject,
    required this.priority,
    required this.dueDate,
    required this.estimatedDuration,
    this.reminder = 'none',
    this.goalId,
    this.isCompleted = false,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  // Convert TaskModel to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'subject': subject,
      'priority': priority,
      'dueDate': Timestamp.fromDate(dueDate),
      'estimatedDuration': estimatedDuration,
      'reminder': reminder,
      'goalId': goalId,
      'isCompleted': isCompleted,
      'userId': userId,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create TaskModel from Firestore Map
  factory TaskModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TaskModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      priority: map['priority'] ?? 'medium',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      estimatedDuration: map['estimatedDuration'] ?? 0,
      reminder: map['reminder'] ?? 'none',
      goalId: map['goalId'],
      isCompleted: map['isCompleted'] ?? false,
      userId: map['userId'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
