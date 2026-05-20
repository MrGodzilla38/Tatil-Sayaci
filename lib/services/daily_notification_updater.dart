import 'package:workmanager/workmanager.dart';
import 'package:tatil_sayaci/services/holiday_service.dart';
import 'package:tatil_sayaci/services/custom_date_service.dart';
import 'package:tatil_sayaci/services/notification_foreground_service.dart';

class DailyNotificationUpdater {
  static const String dailyTaskId = 'tatil_sayaci_daily_update';

  static Future<void> register() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      dailyTaskId,
      dailyTaskId,
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(hours: 1),
      constraints: Constraints(networkType: NetworkType.not_required),
    );
  }

  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(dailyTaskId);
  }

  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      try {
        final holidayService = HolidayService();
        final customDateService = CustomDateService();

        final holidays = await holidayService.getHolidays();
        final customDates = await customDateService.loadCustomDates();

        final summerHoliday = holidayService.getSummerHoliday(holidays);
        final nextHoliday = holidayService.getNextHoliday(holidays);
        final nextCustomDate = customDateService.getNextCustomDate(customDates);

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

        return Future.value(true);
      } catch (e) {
        return Future.value(false);
      }
    });
  }
}
