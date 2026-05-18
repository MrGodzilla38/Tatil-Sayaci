import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tatil_sayaci/models/holiday.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> scheduleHolidayReminder(Holiday holiday) async {
    final now = DateTime.now();
    final reminderDate = holiday.startDate.subtract(const Duration(days: 1));

    if (reminderDate.isBefore(now)) return;

    final tzDate = tz.TZDateTime.from(reminderDate, tz.local);

    await _plugin.zonedSchedule(
      holiday.title.hashCode,
      'Tatil Yaklaşıyor! 🎉',
      'Yarın ${holiday.title} tatili başlıyor!',
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'holiday_channel',
          'Tatil Bildirimleri',
          channelDescription: 'Tatil hatırlatma bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleAllReminders(List<Holiday> holidays) async {
    for (final holiday in holidays) {
      await scheduleHolidayReminder(holiday);
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
