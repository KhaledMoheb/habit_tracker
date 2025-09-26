import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> init() async {}
  static Future<void> requestWebPermission() async {}
  static Future<String> checkWebPermission() async => "unknown";
  static Future<void> showTestNotification() async {}
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {}
  static Future<void> cancelAllNotifications() async {}
}
