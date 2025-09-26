// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> init() async {
    debugPrint("Web init → using native Notification API");
  }

  static Future<void> requestWebPermission() async {
    debugPrint("Web → requesting permission");
    js.context.callMethod("eval", [
      "Notification.requestPermission().then(p => console.log('Permission result:', p));",
    ]);
  }

  static Future<String> checkWebPermission() async {
    final status = js.context['Notification']['permission'] as String;
    debugPrint("Web → current permission: $status");
    return status;
  }

  static Future<void> showTestNotification() async {
    debugPrint('Running on Web → Native Notification API test');
    js.context.callMethod("eval", [
      """
      if (Notification.permission === 'granted') {
        new Notification('Test Notification', { body: 'This is a test (Web)' });
      } else if (Notification.permission !== 'denied') {
        Notification.requestPermission().then(function(p) {
          if (p === 'granted') {
            new Notification('Test Notification', { body: 'This is a test (Web)' });
          }
        });
      }
      """,
    ]);
  }

  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    await showTestNotification();
  }

  static Future<void> cancelAllNotifications() async {
    debugPrint("Web → cancelAll not supported with native API");
  }
}
