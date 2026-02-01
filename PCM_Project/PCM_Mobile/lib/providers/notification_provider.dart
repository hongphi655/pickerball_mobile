import 'package:flutter/material.dart';
import '../models/notification_model.dart' as notification_model;

class NotificationProvider extends ChangeNotifier {
  final List<notification_model.Notification> _notifications = [];
  int _unreadCount = 0;

  List<notification_model.Notification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  // Add a new notification
  void addNotification({
    required String title,
    required String message,
    required String type,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) {
    final notification = notification_model.Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      actionUrl: actionUrl,
      data: data,
    );
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      _unreadCount--;
      notifyListeners();
    }
  }

  // Mark all as read
  void markAllAsRead() {
    for (var notification in _notifications) {
      if (!notification.isRead) {
        notification.isRead = true;
      }
    }
    _unreadCount = 0;
    notifyListeners();
  }

  // Delete notification
  void deleteNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      if (!_notifications[index].isRead) {
        _unreadCount--;
      }
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  // Clear all notifications
  void clearAll() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  // Get unread notifications
  List<notification_model.Notification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Get notifications by type
  List<notification_model.Notification> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Show snackbar notification (for quick feedback)
  static void showSnackbarNotification({
    required BuildContext context,
    required String message,
    String type = 'info',
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case 'success':
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'error':
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case 'warning':
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
      default:
        backgroundColor = Colors.blue;
        icon = Icons.info;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
