import 'package:flutter/foundation.dart';
import 'package:tatil_sayaci/models/holiday.dart';
import 'package:tatil_sayaci/models/custom_date.dart';
import 'package:tatil_sayaci/services/holiday_service.dart';
import 'package:tatil_sayaci/services/custom_date_service.dart';
import 'package:tatil_sayaci/services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  final HolidayService _holidayService = HolidayService();
  final CustomDateService _customDateService = CustomDateService();

  List<Holiday> _holidays = [];
  List<CustomDate> _customDates = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _cacheStatusText = '';

  List<Holiday> get holidays => _holidays;
  List<CustomDate> get customDates => _customDates;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String get cacheStatusText => _cacheStatusText;

  Holiday? get summerHoliday => _holidayService.getSummerHoliday(_holidays);
  Holiday? get nextHoliday => _holidayService.getNextHoliday(_holidays);
  CustomDate? get nextCustomDate =>
      _customDateService.getNextCustomDate(_customDates);

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final cached = await _holidayService.getHolidays();
    if (cached.isNotEmpty) {
      _holidays = cached;
      _cacheStatusText = await _holidayService.getCacheStatusText();
    }

    _customDates = await _customDateService.loadCustomDates();

    if (_holidays.isNotEmpty) {
      await NotificationService().scheduleAllReminders(_holidays);
    }

    _isLoading = false;
    notifyListeners();

    _refreshInBackground();
  }

  Future<void> _refreshInBackground() async {
    try {
      final fresh = await _holidayService.refreshHolidays();
      if (fresh.isNotEmpty) {
        _holidays = fresh;
        _cacheStatusText = await _holidayService.getCacheStatusText();
        await NotificationService().scheduleAllReminders(_holidays);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Background refresh failed: $e');
    }
  }

  Future<void> refreshHolidays() async {
    _isRefreshing = true;
    notifyListeners();

    try {
      _holidays = await _holidayService.refreshHolidays();
      _cacheStatusText = await _holidayService.getCacheStatusText();
      await NotificationService().scheduleAllReminders(_holidays);
    } catch (e) {
      debugPrint('Manual refresh failed: $e');
    }

    _isRefreshing = false;
    notifyListeners();
  }

  Future<void> addCustomDate(CustomDate date) async {
    await _customDateService.addCustomDate(date);
    _customDates = await _customDateService.loadCustomDates();
    notifyListeners();
  }

  Future<void> removeCustomDate(String id) async {
    await _customDateService.removeCustomDate(id);
    _customDates = await _customDateService.loadCustomDates();
    notifyListeners();
  }

  Future<void> updateCustomDate(CustomDate date) async {
    await _customDateService.updateCustomDate(date);
    _customDates = await _customDateService.loadCustomDates();
    notifyListeners();
  }

  Map<DateTime, List<Holiday>> get holidayEvents {
    final map = <DateTime, List<Holiday>>{};
    for (final holiday in _holidays) {
      if (holiday.isMultiDay) {
        var date = holiday.startDate;
        while (!date.isAfter(holiday.endDate!)) {
          final key = DateTime(date.year, date.month, date.day);
          map.putIfAbsent(key, () => []);
          map[key]!.add(holiday);
          date = date.add(const Duration(days: 1));
        }
      } else {
        final key =
            DateTime(holiday.startDate.year, holiday.startDate.month, holiday.startDate.day);
        map.putIfAbsent(key, () => []);
        map[key]!.add(holiday);
      }
    }
    return map;
  }

  Map<DateTime, List<CustomDate>> get customDateEvents {
    final map = <DateTime, List<CustomDate>>{};
    for (final date in _customDates) {
      final key = DateTime(date.date.year, date.date.month, date.date.day);
      map.putIfAbsent(key, () => []);
      map[key]!.add(date);
    }
    return map;
  }
}
