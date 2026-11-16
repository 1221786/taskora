import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_model.dart';
import '../../tasks/models/task_model.dart';
import '../../goals/models/goal_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _localNotifications;

  static const String _channelId = 'taskora_notifications';
  static const String _channelName = 'Taskora Notifications';

  static const Map<String, Duration> _reminderOffsets = {
    '10_minutes': Duration(minutes: 10),
    '30_minutes': Duration(minutes: 30),
    '1_hour': Duration(hours: 1),
    '1_day': Duration(days: 1),
  };

  bool _isInitialized = false;
  bool _isTimeZoneConfigured = false;

  String? _deviceTimeZone;

  NotificationService({
    FirebaseFirestore? firestore,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  CollectionReference<Map<String, dynamic>> _notificationsCollection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  String? get deviceTimeZone => _deviceTimeZone;

  // Initialize local notifications and device timezone.

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    final timezoneName = timezoneInfo.identifier;

    tz.setLocalLocation(tz.getLocation(timezoneName));

    _deviceTimeZone = timezoneName;
    _isTimeZoneConfigured = true;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        // Notification navigation will be connected later.
      },
    );

    _isInitialized = true;
  }

  Future<void> configureTimeZone(String timeZoneName) async {
    if (!_isInitialized) {
      await initialize();
    }

    tz.setLocalLocation(tz.getLocation(timeZoneName));

    _deviceTimeZone = timeZoneName;
    _isTimeZoneConfigured = true;
  }

  // Request notification permissions.

  Future<bool?> requestPermissions() async {
    await initialize();

    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      return await androidImplementation.requestNotificationsPermission();
    }

    final iosImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosImplementation != null) {
      return await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return null;
  }

  // Save notification in Firestore.

  Future<void> saveNotification(NotificationModel notification) async {
    await _notificationsCollection(
      notification.userId,
    ).doc(notification.id).set(notification.toMap());
  }

  // Listen to notifications.

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _notificationsCollection(
      userId,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((document) {
        return NotificationModel.fromMap(document.data(), document.id);
      }).toList();
    });
  }

  // Show an immediate local notification.

  Future<void> showNotification({
    required int notificationId,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    await _localNotifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: _notificationDetails,
      payload: payload,
    );
  }

  // Save notification in Firestore and show it on the device.
  Future<void> saveAndShowNotification(NotificationModel notification) async {
    // Keep the notification in the in-app notifications page.
    await saveNotification(notification);

    // Show it in the phone notification tray.
    try {
      await showNotification(
        notificationId: _stableNotificationId('activity_${notification.id}'),
        title: notification.title,
        body: notification.body,
        payload: notification.id,
      );
    } catch (error) {
      // A local notification failure must not undo the Firestore save.
      debugPrint('LOCAL NOTIFICATION ERROR: $error');
    }
  }

  // -----------------------------
  // Task reminders
  // -----------------------------

  Future<void> scheduleTaskReminder(TaskModel task) async {
    await initialize();

    if (task.id.isEmpty) {
      throw ArgumentError('Task ID cannot be empty.');
    }

    if (task.reminder == 'none' || task.isCompleted) {
      await cancelTaskReminder(task);
      return;
    }

    final offset = _reminderOffsets[task.reminder];

    if (offset == null) {
      throw ArgumentError('Invalid reminder option: ${task.reminder}');
    }

    final scheduledAt = task.dueDate.subtract(offset);

    if (!scheduledAt.isAfter(DateTime.now())) {
      await cancelTaskReminder(task);
      return;
    }

    final notification = NotificationModel(
      id: _taskReminderDocumentId(task.id),
      userId: task.userId,
      title: 'Task Reminder',
      body: '${task.title} is due soon.',
      type: NotificationType.taskReminder,
      taskId: task.id,
      createdAt: DateTime.now(),
      scheduledAt: scheduledAt,
      isScheduled: true,
    );

    await scheduleNotification(
      notificationId: _stableNotificationId('task_${task.id}'),
      notification: notification,
    );
  }

  Future<void> cancelTaskReminder(TaskModel task) async {
    await initialize();

    if (task.id.isEmpty) return;

    await cancelScheduledNotification(_stableNotificationId('task_${task.id}'));

    await _notificationsCollection(
      task.userId,
    ).doc(_taskReminderDocumentId(task.id)).delete();
  }

  String _taskReminderDocumentId(String taskId) {
    return 'task_reminder_$taskId';
  }

  // -----------------------------
  // Goal reminders
  // -----------------------------

  Future<void> scheduleGoalReminder(GoalModel goal) async {
    await initialize();

    if (goal.id.isEmpty) {
      throw ArgumentError('Goal ID cannot be empty.');
    }

    if (goal.userId.isEmpty) {
      throw ArgumentError('Goal user ID cannot be empty.');
    }

    // Schedule the reminder at 9:00 AM on the day before the goal deadline.
    final scheduledAt = DateTime(
      goal.targetDate.year,
      goal.targetDate.month,
      goal.targetDate.day - 1,
      9,
      0,
    );

    // If the reminder time has already passed, cancel the old reminder.
    if (!scheduledAt.isAfter(DateTime.now())) {
      await cancelGoalReminder(goal);
      return;
    }

    final notification = NotificationModel(
      id: _goalReminderDocumentId(goal.id),
      userId: goal.userId,
      title: 'Goal Deadline Reminder',
      body: 'Your goal "${goal.title}" is due tomorrow.',
      type: NotificationType.goalReminder,
      goalId: goal.id,
      createdAt: DateTime.now(),
      scheduledAt: scheduledAt,
      isScheduled: true,
    );

    await scheduleNotification(
      notificationId: _stableNotificationId('goal_${goal.id}'),
      notification: notification,
    );
  }

  Future<void> cancelGoalReminder(GoalModel goal) async {
    await initialize();

    if (goal.id.isEmpty || goal.userId.isEmpty) return;

    await cancelScheduledNotification(_stableNotificationId('goal_${goal.id}'));

    await _notificationsCollection(
      goal.userId,
    ).doc(_goalReminderDocumentId(goal.id)).delete();
  }

  String _goalReminderDocumentId(String goalId) {
    return 'goal_reminder_$goalId';
  }

  // -----------------------------
  // General scheduling
  // -----------------------------

  int _stableNotificationId(String value) {
    const int offsetBasis = 0x811C9DC5;
    const int prime = 0x01000193;
    const int mask = 0x7FFFFFFF;

    var hash = offsetBasis;

    for (final byte in utf8.encode(value)) {
      hash ^= byte;
      hash = (hash * prime) & mask;
    }

    return hash == 0 ? 1 : hash;
  }

  Future<void> scheduleNotification({
    required int notificationId,
    required NotificationModel notification,
  }) async {
    await initialize();

    if (!_isTimeZoneConfigured) {
      throw StateError('Device timezone has not been configured.');
    }

    final scheduledAt = notification.scheduledAt;

    if (scheduledAt == null) {
      throw ArgumentError('A scheduled date is required.');
    }

    if (!scheduledAt.isAfter(DateTime.now())) {
      throw ArgumentError('The scheduled date must be in the future.');
    }

    await _localNotifications.zonedSchedule(
      id: notificationId,
      title: notification.title,
      body: notification.body,
      scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: notification.id,
    );

    await saveNotification(notification.copyWith(isScheduled: true));
  }

  // Mark notification as read.

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    await _notificationsCollection(
      userId,
    ).doc(notificationId).update({'isRead': true});
  }

  // Delete notification from Firestore.

  Future<void> deleteNotification({
    required String userId,
    required String notificationId,
  }) async {
    await _notificationsCollection(userId).doc(notificationId).delete();
  }

  // Cancel a scheduled local notification.

  Future<void> cancelScheduledNotification(int notificationId) async {
    await initialize();
    await _localNotifications.cancel(id: notificationId);
  }

  // Cancel all local notifications.

  Future<void> cancelAllNotifications() async {
    await initialize();
    await _localNotifications.cancelAll();
  }

  // Notification appearance.

  NotificationDetails get _notificationDetails {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Taskora tasks, goals and calendar reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
