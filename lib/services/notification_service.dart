import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // Initialize timezone data
      tz_init.initializeTimeZones();

      // Initialize notification settings
      final AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
    // You can add navigation logic here if needed
  }

  Future<void> requestPermission() async {
    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      // For Android 13+, we would need to request permissions differently
      // In version 15.1.3, this method is not available yet
      // Android permissions are handled at the manifest level for this version
      debugPrint(
          'Android notification permissions must be declared in the manifest');
    }
  }

  // Show notification for received transaction
  Future<void> showReceivedTransactionNotification({
    required String cryptoType,
    required String amount,
    required String from,
    String? transactionId,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'transaction_channel',
      'Transactions',
      channelDescription: 'Notifications for cryptocurrency transactions',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Received $cryptoType',
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Received $amount $cryptoType',
      'Transaction from $from has been confirmed',
      details,
      payload: transactionId,
    );
  }

  // Show notification for sent transaction
  Future<void> showSentTransactionNotification({
    required String cryptoType,
    required String amount,
    required String to,
    String? transactionId,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'transaction_channel',
      'Transactions',
      channelDescription: 'Notifications for cryptocurrency transactions',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Sent $cryptoType',
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Sent $amount $cryptoType',
      'Transaction to $to has been confirmed',
      details,
      payload: transactionId,
    );
  }

  // Show notification for price alerts
  Future<void> showPriceAlertNotification({
    required String cryptoType,
    required double price,
    required double changePercent,
  }) async {
    final String changeDirection = changePercent >= 0 ? 'up' : 'down';
    final String changeText = '${changePercent.abs().toStringAsFixed(2)}%';

    final androidDetails = AndroidNotificationDetails(
      'price_alert_channel',
      'Price Alerts',
      channelDescription: 'Notifications for cryptocurrency price alerts',
      importance: Importance.high,
      priority: Priority.high,
      ticker: '$cryptoType price alert',
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      '$cryptoType Price Alert',
      '$cryptoType price is $changeDirection $changeText at \$${price.toStringAsFixed(2)}',
      details,
    );
  }

  // Schedule a reminder notification
  Future<void> scheduleReminationNotification({
    required String title,
    required String message,
    required DateTime scheduledTime,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Scheduled reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      message,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
