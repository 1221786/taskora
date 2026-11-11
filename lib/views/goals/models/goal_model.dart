import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime targetDate;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GoalModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.startDate,
    required this.targetDate,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'targetDate': Timestamp.fromDate(targetDate),
      'userId': userId,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map, String documentId) {
    return GoalModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      targetDate: (map['targetDate'] as Timestamp).toDate(),
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
