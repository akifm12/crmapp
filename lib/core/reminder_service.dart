import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../features/auth/auth_provider.dart';
import '../features/compliance_calendar/compliance_provider.dart';
import '../features/compliance_calendar/deadline_utils.dart';
import 'user_prefs.dart';

/// Schedules on-device reminders for upcoming deadlines (no server/FCM needed):
/// 9:00 am Dubai time, 7 days before, 1 day before, and on the day.
class ReminderService {
  ReminderService._();
  static final instance = ReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channel = AndroidNotificationDetails(
    'deadline_reminders',
    'Deadline reminders',
    channelDescription: 'Reminders before your compliance deadlines fall due',
    importance: Importance.high,
    priority: Priority.high,
  );
  static const _details = NotificationDetails(android: _channel, iOS: DarwinNotificationDetails());

  Future<void> _init() async {
    if (_ready) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dubai'));
    await _plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ));
    _ready = true;
  }

  /// Asks the OS for permission. Returns true if notifications are allowed.
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.requestNotificationsPermission() ?? false;
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    return false;
  }

  Future<void> cancelAll() async {
    await _init();
    await _plugin.cancelAll();
  }

  /// Replaces all scheduled reminders with [items].
  Future<void> reschedule(List<({int id, String title, DateTime due})> items) async {
    await _init();
    await _plugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    final slots = <({int id, String title, String body, tz.TZDateTime at})>[];
    for (final it in items) {
      for (final (offset, label) in const [(7, 'is due in 7 days'), (1, 'is due tomorrow'), (0, 'is due today')]) {
        final day = it.due.subtract(Duration(days: offset));
        final at = tz.TZDateTime(tz.local, day.year, day.month, day.day, 9);
        if (at.isAfter(now)) {
          slots.add((id: it.id * 10 + offset, title: 'Compliance deadline', body: '${it.title} $label', at: at));
        }
      }
    }
    slots.sort((a, b) => a.at.compareTo(b.at));
    // iOS keeps at most 64 pending local notifications — schedule the soonest.
    for (final s in slots.take(60)) {
      await _plugin.zonedSchedule(
        s.id,
        s.title,
        s.body,
        s.at,
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}

/// Keeps scheduled reminders in sync with the calendar, the user's own
/// deadlines, completion ticks and the on/off setting. Watched from the app root.
final reminderSyncProvider = Provider<void>((ref) {
  final prefs = ref.watch(userPrefsProvider);
  if (!prefs.loaded) return;
  if (!prefs.remindersOn) {
    ReminderService.instance.cancelAll();
    return;
  }

  final calendar = ref.watch(complianceCalendarProvider(prefs.sector)).valueOrNull;
  final loggedIn = ref.watch(authProvider).isLoggedIn;
  final mine = loggedIn ? ref.watch(myDeadlinesProvider).valueOrNull : null;
  if (calendar == null) return;

  // A date the user set themselves replaces the master date for that deadline.
  final overridden = {for (final m in mine ?? const []) if (m.complianceDeadlineId != null) m.complianceDeadlineId};
  final items = <({int id, String title, DateTime due})>[
    for (final d in calendar.deadlines)
      if (d.nextDueDate != null && !prefs.doneKeys.contains(doneKey(d)) && !overridden.contains(d.id))
        (id: d.id, title: d.title, due: d.nextDueDate!),
    // user-set dates (ids offset so they never collide with the master list)
    for (final m in mine ?? const [])
      (id: 100000 + (m.id as int), title: m.displayLabel, due: m.dueDate),
  ];
  ReminderService.instance.reschedule(items);
});
