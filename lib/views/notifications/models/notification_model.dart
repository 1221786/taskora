import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  taskCreated,
  taskUpdated,
  taskCompleted,
  taskDeleted,
  taskReminder,
  goalCreated,
  goalUpdated,
  goalCompleted,
  goalReminder,
  calendarReminder,
  general,
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;

  final String? taskId;
  final String? goalId;
  final String? eventId;

  final DateTime createdAt;
  final DateTime? scheduledAt;

  final bool isRead;
  final bool isScheduled;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.taskId,
    this.goalId,
    this.eventId,
    required this.createdAt,
    this.scheduledAt,
    this.isRead = false,
    this.isScheduled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'taskId': taskId,
      'goalId': goalId,
      'eventId': eventId,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledAt': scheduledAt != null
          ? Timestamp.fromDate(scheduledAt!)
          : null,
      'isRead': isRead,
      'isScheduled': isScheduled,
    };
  }

  factory NotificationModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return NotificationModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => NotificationType.general,
      ),
      taskId: map['taskId'],
      goalId: map['goalId'],
      eventId: map['eventId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledAt: (map['scheduledAt'] as Timestamp?)?.toDate(),
      isRead: map['isRead'] ?? false,
      isScheduled: map['isScheduled'] ?? false,
    );
  }

  NotificationModel copyWith({
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    bool? isScheduled,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      taskId: taskId,
      goalId: goalId,
      eventId: eventId,
      createdAt: createdAt,
      scheduledAt: scheduledAt,
      isRead: isRead ?? this.isRead,
      isScheduled: isScheduled ?? this.isScheduled,
    );
  }
}
