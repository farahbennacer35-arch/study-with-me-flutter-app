// ========================================
// 2. SERVICE: Gestionnaire de notifications
// lib/services/notification_manager.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager extends ChangeNotifier {
  int _unreadCount = 0;
  final List<NotificationItem> _notifications = [];

  int get unreadCount => _unreadCount;
  List<NotificationItem> get notifications => _notifications;
  List<NotificationItem> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  NotificationManager() {
    _loadUnreadCount();
  }

  // Charger le nombre de notifications non lues
  Future<void> _loadUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    _unreadCount = prefs.getInt('notification_unread_count') ?? 0;
    notifyListeners();
  }

  // Sauvegarder le nombre
  Future<void> _saveUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_unread_count', _unreadCount);
  }

  // Ajouter une notification
  Future<void> addNotification(NotificationItem notification) async {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
      await _saveUnreadCount();
    }
    notifyListeners();
  }

  // Marquer comme lue
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      _unreadCount = (_unreadCount - 1).clamp(0, 999);
      await _saveUnreadCount();
      notifyListeners();
    }
  }

  // Tout marquer comme lu
  Future<void> markAllAsRead() async {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    _unreadCount = 0;
    await _saveUnreadCount();
    notifyListeners();
  }

  // Supprimer une notification
  Future<void> deleteNotification(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      if (!_notifications[index].isRead) {
        _unreadCount = (_unreadCount - 1).clamp(0, 999);
        await _saveUnreadCount();
      }
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  // Supprimer toutes les notifications
  Future<void> clearAll() async {
    _notifications.clear();
    _unreadCount = 0;
    await _saveUnreadCount();
    notifyListeners();
  }

  // Incrémenter le compteur (appelé quand notification reçue)
  Future<void> incrementUnreadCount() async {
    _unreadCount++;
    await _saveUnreadCount();
    notifyListeners();
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type; // 'pomodoro', 'event', 'mood', 'badge'
  bool isRead;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.type = 'general',
    this.isRead = false,
    this.data,
  });

  IconData get icon {
    switch (type) {
      case 'pomodoro':
        return Icons.timer;
      case 'event':
        return Icons.event;
      case 'mood':
        return Icons.mood;
      case 'badge':
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case 'pomodoro':
        return Colors.green;
      case 'event':
        return Colors.blue;
      case 'mood':
        return Colors.orange;
      case 'badge':
        return Colors.amber;
      default:
        return const Color(0xFF7777EE);
    }
  }
}