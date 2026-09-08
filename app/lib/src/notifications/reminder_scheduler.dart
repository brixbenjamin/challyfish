import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';

/// Exactly one optional daily reminder, off by default (ADR-0011).
///
/// Local only: no push service, no device tokens, nothing server-initiated.
/// This is the single place in the product where the app initiates contact, and
/// its copy never references a miss, a streak, or the archetype balance.
abstract class ReminderScheduler {
  Future<bool> isEnabled();

  /// The time the user chose, defaulting to 08:00 before they have chosen one.
  Future<TimeOfDay> savedTime();

  /// Requests permission and schedules. Returns false if permission was denied.
  Future<bool> enable(TimeOfDay at);

  Future<void> disable();

  /// Cancels when no run is active — there is nothing to remind anyone about
  /// between campaigns.
  Future<void> rescheduleForActiveRun({
    required bool hasActiveRun,
    required TimeOfDay at,
  });
}

class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler(this._plugin);

  static const _enabledKey = 'reminder_enabled'; // niche:allow — storage key
  static const _hourKey = 'reminder_hour'; // niche:allow — storage key
  static const _minuteKey = 'reminder_minute'; // niche:allow — storage key
  static const _notificationId = 1;

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<bool> isEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_enabledKey) ?? false;

  @override
  Future<TimeOfDay> savedTime() async {
    final prefs = await SharedPreferences.getInstance();
    return TimeOfDay(
      hour: prefs.getInt(_hourKey) ?? 8,
      minute: prefs.getInt(_minuteKey) ?? 0,
    );
  }

  @override
  Future<bool> enable(TimeOfDay at) async {
    // The permission prompt fires here — at the moment of intent — and nowhere
    // else. A user who never wants a reminder is never asked.
    final granted = await _requestPermission();
    if (!granted) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
    await prefs.setInt(_hourKey, at.hour);
    await prefs.setInt(_minuteKey, at.minute);

    await _schedule(at);
    return true;
  }

  @override
  Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
    await _plugin.cancel(id: _notificationId);
  }

  @override
  Future<void> rescheduleForActiveRun({
    required bool hasActiveRun,
    required TimeOfDay at,
  }) async {
    await _plugin.cancel(id: _notificationId);
    if (!hasActiveRun || !await isEnabled()) return;
    await _schedule(at);
  }

  Future<bool> _requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: false) ?? false;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return false;
  }

  Future<void> _schedule(TimeOfDay at) async {
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      at.hour,
      at.minute,
    );
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));

    // The one place in the product that needs words with no BuildContext to get
    // them from. Loading the delegate directly is the whole answer, and it is
    // why this path did not need a mechanism of its own (ADR-0022).
    final l10n = await AppLocalizations.delegate.load(
      PlatformDispatcher.instance.locale,
    );

    // Named arguments throughout: flutter_local_notifications 22 moved
    // zonedSchedule and cancel off positional parameters.
    await _plugin.zonedSchedule(
      id: _notificationId,
      title: l10n.reminderNotificationTitle,
      // Never a miss, never a streak, never the balance.
      body: l10n.reminderNotificationBody,
      scheduledDate: when,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder', // niche:allow — channel id, never shown
          l10n.reminderChannelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(presentSound: false),
      ),
      // Deliberate: an exact alarm needs a special Android permission and a
      // justification at review, and a reminder a few minutes late is fine.
      // Do not "fix" this to exact.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
