// File: lib/providers/notification_provider.dart
import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  // Getters
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  // Filtered notifications
  List<AppNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  
  List<AppNotification> get readNotifications => 
      _notifications.where((n) => n.isRead).toList();

  List<AppNotification> getNotificationsByType(String type) =>
      _notifications.where((n) => n.type == type).toList();

  // Initialize streams
  void initializeNotifications() {
    _isLoading = true;
    notifyListeners();

    // Stream untuk semua notifikasi
    _notificationService.getAllNotifications().listen(
      (notifications) {
        _notifications = notifications;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error loading notifications: $error');
        _isLoading = false;
        notifyListeners();
      },
    );

    // Stream untuk unread count
    _notificationService.getUnreadCount().listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (error) {
        print('Error loading unread count: $error');
      },
    );
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      
      // Update local state
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Cleanup
  void dispose() {
    super.dispose();
  }

  // Helper method untuk mendapatkan notifikasi berdasarkan hari
  Map<String, List<AppNotification>> get groupedNotifications {
    final Map<String, List<AppNotification>> grouped = {};
    
    for (final notification in _notifications) {
      final now = DateTime.now();
      final notificationDate = notification.createdAt;
      
      String dateKey;
      
      if (notificationDate.year == now.year &&
          notificationDate.month == now.month &&
          notificationDate.day == now.day) {
        dateKey = 'Today';
      } else if (notificationDate.year == now.year &&
                 notificationDate.month == now.month &&
                 notificationDate.day == now.day - 1) {
        dateKey = 'Yesterday';
      } else if (now.difference(notificationDate).inDays < 7) {
        dateKey = 'This Week';
      } else if (now.difference(notificationDate).inDays < 30) {
        dateKey = 'This Month';
      } else {
        dateKey = 'Older';
      }
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notification);
    }
    
    return grouped;
  }
}