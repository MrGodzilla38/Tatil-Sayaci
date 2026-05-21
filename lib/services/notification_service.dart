import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tatil_sayaci/models/holiday.dart';
import 'package:tatil_sayaci/models/custom_date.dart';
import 'package:tatil_sayaci/services/notification_foreground_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  static const String _notifKey = 'notifications_enabled';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _enabled = false;

  bool get isEnabled => _enabled;

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

    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_notifKey) ?? true;

    _initialized = true;
  }

  Future<void> scheduleHolidayReminder(Holiday holiday) async {
    if (!_enabled) return;

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
    if (!_enabled) return;

    for (final holiday in holidays) {
      await scheduleHolidayReminder(holiday);
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> startForegroundNotification({
    required Holiday? summerHoliday,
    required Holiday? nextHoliday,
    required CustomDate? nextCustomDate,
  }) async {
    _enabled = true;

    final summerVisible = summerHoliday != null;
    final holidayVisible = nextHoliday != null;
    final customVisible = nextCustomDate != null;
    final emptyVisible = !summerVisible && !holidayVisible && !customVisible;

    await NotificationForegroundService.start(
      summerLabel: summerVisible ? 'Yaz Tatili' : '',
      summerDays: summerVisible ? '${summerHoliday!.daysRemaining} gün kaldı' : '',
      summerVisible: summerVisible,
      holidayLabel: holidayVisible ? nextHoliday!.title : '',
      holidayDays: holidayVisible ? '${nextHoliday.daysRemaining} gün kaldı' : '',
      holidayVisible: holidayVisible,
      customLabel: customVisible ? nextCustomDate!.title : '',
      customDays: customVisible ? '${nextCustomDate.daysRemaining} gün kaldı' : '',
      customVisible: customVisible,
      emptyVisible: emptyVisible,
    );
  }

  Future<void> updateForegroundNotification({
    required Holiday? summerHoliday,
    required Holiday? nextHoliday,
    required CustomDate? nextCustomDate,
  }) async {
    if (!_enabled) return;

    final summerVisible = summerHoliday != null;
    final holidayVisible = nextHoliday != null;
    final customVisible = nextCustomDate != null;
    final emptyVisible = !summerVisible && !holidayVisible && !customVisible;

    await NotificationForegroundService.update(
      summerLabel: summerVisible ? 'Yaz Tatili' : '',
      summerDays: summerVisible ? '${summerHoliday!.daysRemaining} gün kaldı' : '',
      summerVisible: summerVisible,
      holidayLabel: holidayVisible ? nextHoliday!.title : '',
      holidayDays: holidayVisible ? '${nextHoliday.daysRemaining} gün kaldı' : '',
      holidayVisible: holidayVisible,
      customLabel: customVisible ? nextCustomDate!.title : '',
      customDays: customVisible ? '${nextCustomDate.daysRemaining} gün kaldı' : '',
      customVisible: customVisible,
      emptyVisible: emptyVisible,
    );
  }

  Future<void> stopForegroundNotification() async {
    _enabled = false;
    await NotificationForegroundService.stop();
  }
}
