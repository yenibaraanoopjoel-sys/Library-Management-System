import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification/notification_service.dart';
import '../core/mock/mock_data.dart';

/// Notification state provider managing notifications and unread badge count with Firestore sync
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  NotificationProvider({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService() {
    _loadNotifications();
  }

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> _loadNotifications({String userId = 'usr_student'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cloudList = await _notificationService.getNotifications(userId);
      if (cloudList.isNotEmpty) {
        _notifications = cloudList;
      } else {
        _loadFallback();
      }
    } catch (_) {
      _loadFallback();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadFallback() {
    _notifications = MockData.getInitialNotifications().map((n) {
      return NotificationModel(
        id: n.id,
        userId: n.userId,
        title: n.title,
        message: n.message,
        type: n.type,
        isRead: n.isRead,
        createdAt: n.timestamp,
      );
    }).toList();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();

      try {
        await _notificationService.markAsRead(id);
      } catch (_) {}
    }
  }

  Future<void> markAllAsRead({String userId = 'usr_student'}) async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();

    try {
      await _notificationService.markAllAsRead(userId);
    } catch (_) {}
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required String type,
    String userId = 'usr_student',
    String relatedId = '',
  }) async {
    final notif = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      message: message,
      type: type,
      isRead: false,
      relatedId: relatedId,
      createdAt: DateTime.now(),
    );

    _notifications.insert(0, notif);
    notifyListeners();

    try {
      await _notificationService.createNotification(
        userId: userId,
        title: title,
        message: message,
        type: type,
        relatedId: relatedId,
      );
    } catch (_) {}
  }
}
