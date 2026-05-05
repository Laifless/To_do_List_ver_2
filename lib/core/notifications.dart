import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import 'colors.dart';

/// Servizio notifiche.
///
/// IMPORTANTE: il vecchio codice usava `notifPlugin.show()` per programmare
/// notifiche, il che ignorava completamente il tempo richiesto e mostrava
/// la notifica subito. Qui usiamo `zonedSchedule` con il package `timezone`,
/// che è il modo corretto a partire da flutter_local_notifications 15+.
///
/// Aggiungi al pubspec.yaml:
/// ```yaml
/// dependencies:
///   flutter_local_notifications: ^17.0.0
///   timezone: ^0.9.4
///   flutter_timezone: ^3.0.0
/// ```
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Setup timezone — necessario per zonedSchedule.
    tz_data.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (e) {
      debugPrint('Timezone init failed: $e — falling back to UTC');
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: iOS);
    await _plugin.initialize(settings);

    // Permessi runtime Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'hunter_system_channel',
      'Hunter System',
      channelDescription: 'Quest reminders',
      importance: Importance.high,
      priority: Priority.high,
      color: AppColors.blue,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  /// Programma una notifica per [scheduledTime].
  /// Se il tempo è nel passato, non fa nulla.
Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,            // <-- Passato come parametro posizionale
      _details,          // <-- Passato come parametro posizionale
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}