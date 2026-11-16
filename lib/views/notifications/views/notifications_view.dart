import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../view_models/notifications_view_model.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_header.dart';

class NotificationsView extends StatefulWidget {
  final String userId;

  const NotificationsView({super.key, required this.userId});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late final NotificationsViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = NotificationsViewModel(userId: widget.userId);

    _viewModel.loadNotifications();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isRead) {
      await _viewModel.markAsRead(notification.id);
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    await _viewModel.deleteNotification(notification.id);
  }

  Future<void> _markAllAsRead() async {
    await _viewModel.markAllAsRead();
  }

  Future<void> _refreshNotifications() async {
    await _viewModel.refreshNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF252542),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF252542)),
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          final notifications = _viewModel.notifications;

          return RefreshIndicator(
            color: const Color(0xFF6C63FF),
            onRefresh: _refreshNotifications,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                NotificationHeader(
                  unreadCount: _viewModel.unreadCount,
                  onMarkAllAsRead: _viewModel.unreadCount > 0
                      ? _markAllAsRead
                      : null,
                ),

                if (_viewModel.isLoading && notifications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  )
                else if (_viewModel.errorMessage != null &&
                    notifications.isEmpty)
                  _buildErrorState()
                else if (notifications.isEmpty)
                  const SizedBox(height: 450, child: NotificationEmptyState())
                else
                  ...notifications.map(
                    (notification) => NotificationCard(
                      notification: notification,
                      onTap: () => _markAsRead(notification),
                      onDelete: () => _deleteNotification(notification),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 55,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong!',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF252542),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _viewModel.errorMessage ?? 'Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _viewModel.loadNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
