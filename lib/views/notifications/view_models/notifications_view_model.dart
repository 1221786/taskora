import 'dart:async';

import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationService _notificationService;
  final String userId;

  NotificationsViewModel({
    required this.userId,
    NotificationService? notificationService,
  }) : _notificationService = notificationService ?? NotificationService();

  List<NotificationModel> _allNotifications = [];

  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  StreamSubscription<List<NotificationModel>>? _notificationsSubscription;

  Timer? _scheduledVisibilityTimer;

  // -----------------------------
  // Getters
  // -----------------------------

  // Show only notifications whose display time has arrived.
  List<NotificationModel> get notifications {
    final now = DateTime.now();

    final visibleNotifications = _allNotifications.where((notification) {
      if (!notification.isScheduled) {
        return true;
      }

      final scheduledAt = notification.scheduledAt;

      if (scheduledAt == null) {
        return true;
      }

      return !scheduledAt.isAfter(now);
    }).toList();

    // Sort by actual display time.
    visibleNotifications.sort((a, b) {
      final dateA = a.isScheduled && a.scheduledAt != null
          ? a.scheduledAt!
          : a.createdAt;

      final dateB = b.isScheduled && b.scheduledAt != null
          ? b.scheduledAt!
          : b.createdAt;

      return dateB.compareTo(dateA);
    });

    return List.unmodifiable(visibleNotifications);
  }

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasNotifications => notifications.isNotEmpty;

  int get unreadCount =>
      notifications.where((notification) => !notification.isRead).length;

  int get readCount =>
      notifications.where((notification) => notification.isRead).length;

  // -----------------------------
  // Listen to Firestore
  // -----------------------------

  void loadNotifications() {
    _isLoading = true;
    _errorMessage = null;
    _notifySafely();

    _notificationsSubscription?.cancel();
    _scheduledVisibilityTimer?.cancel();

    _notificationsSubscription = _notificationService
        .getNotifications(userId)
        .listen(
          (notifications) {
            _allNotifications = notifications;

            _isLoading = false;
            _errorMessage = null;

            _scheduleNextVisibilityUpdate();

            _notifySafely();
          },
          onError: (error, stackTrace) {
            debugPrint('Notifications loading error: $error');
            debugPrint('Stack trace: $stackTrace');

            _isLoading = false;
            _errorMessage = 'Failed to load notifications: $error';

            _notifySafely();
          },
        );
  }

  // -----------------------------
  // Schedule visibility update
  // -----------------------------

  void _scheduleNextVisibilityUpdate() {
    _scheduledVisibilityTimer?.cancel();

    final now = DateTime.now();

    final upcomingReminders = _allNotifications.where((notification) {
      if (!notification.isScheduled || notification.scheduledAt == null) {
        return false;
      }

      return notification.scheduledAt!.isAfter(now);
    }).toList();

    if (upcomingReminders.isEmpty) {
      return;
    }

    upcomingReminders.sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));

    final nextReminderTime = upcomingReminders.first.scheduledAt!;
    final difference = nextReminderTime.difference(now);

    _scheduledVisibilityTimer = Timer(difference, () {
      if (_isDisposed) return;

      // The reminder is now visible in the notifications page.
      _notifySafely();

      // Schedule the next upcoming reminder.
      _scheduleNextVisibilityUpdate();
    });
  }

  // -----------------------------
  // Mark notification as read
  // -----------------------------

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(
        userId: userId,
        notificationId: notificationId,
      );
    } catch (error) {
      _setError('Failed to mark notification as read.');
    }
  }

  // -----------------------------
  // Mark all notifications as read
  // -----------------------------

  Future<void> markAllAsRead() async {
    try {
      final unreadNotifications = notifications
          .where((notification) => !notification.isRead)
          .toList();

      for (final notification in unreadNotifications) {
        await _notificationService.markAsRead(
          userId: userId,
          notificationId: notification.id,
        );
      }
    } catch (error) {
      _setError('Failed to mark all notifications as read.');
    }
  }

  // -----------------------------
  // Delete notification
  // -----------------------------

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(
        userId: userId,
        notificationId: notificationId,
      );
    } catch (error) {
      _setError('Failed to delete notification.');
    }
  }

  // -----------------------------
  // Request notification permissions
  // -----------------------------

  Future<bool?> requestPermissions() async {
    try {
      return await _notificationService.requestPermissions();
    } catch (error) {
      _setError('Failed to request notification permissions.');
      return false;
    }
  }

  // -----------------------------
  // Refresh notifications
  // -----------------------------

  Future<void> refreshNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    _notifySafely();

    try {
      final notifications = await _notificationService
          .getNotifications(userId)
          .first;

      _allNotifications = notifications;

      _isLoading = false;
      _errorMessage = null;

      _scheduleNextVisibilityUpdate();

      _notifySafely();
    } catch (error) {
      _isLoading = false;
      _setError('Failed to refresh notifications.');
    }
  }

  // -----------------------------
  // Handle errors
  // -----------------------------

  void _setError(String message) {
    _errorMessage = message;
    _notifySafely();
  }

  // -----------------------------
  // Notify listeners safely
  // -----------------------------

  void _notifySafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // -----------------------------
  // Dispose
  // -----------------------------

  @override
  void dispose() {
    _isDisposed = true;

    _scheduledVisibilityTimer?.cancel();
    _notificationsSubscription?.cancel();

    super.dispose();
  }
}
