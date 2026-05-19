import 'package:tatil_sayaci/models/holiday.dart';
import 'package:tatil_sayaci/services/national_holiday_generator.dart';
import 'package:tatil_sayaci/services/religious_holiday_service.dart';
import 'package:tatil_sayaci/services/school_holiday_calculator.dart';
import 'package:tatil_sayaci/services/holiday_cache_service.dart';
import 'package:tatil_sayaci/utils/constants.dart';

class HolidayService {
  final ReligiousHolidayService _religiousService = ReligiousHolidayService();
  final HolidayCacheService _cacheService = HolidayCacheService();

  Future<List<Holiday>> getHolidays() async {
    final cached = await _cacheService.loadCache();
    final isValid = await _cacheService.isCacheValid();

    if (cached != null && isValid) {
      return cached;
    }

    return await _generateAndCacheHolidays();
  }

  Future<List<Holiday>> refreshHolidays() async {
    await _cacheService.clearCache();
    return await _generateAndCacheHolidays();
  }

  Future<List<Holiday>> _generateAndCacheHolidays() async {
    final now = DateTime.now();
    final currentYear = now.year;
    final nextYear = currentYear + 1;

    final nationalHolidays = NationalHolidayGenerator.generateAll(
      AppConstants.minYear,
      AppConstants.maxYear,
    );

    final schoolHolidays = SchoolHolidayCalculator.calculateAll(
      AppConstants.minYear,
      AppConstants.maxYear,
    );

    final religiousHolidays = await _religiousService.getReligiousHolidaysForRange(
      currentYear,
      nextYear,
    );

    final allHolidays = <Holiday>[];
    allHolidays.addAll(nationalHolidays);
    allHolidays.addAll(schoolHolidays);
    allHolidays.addAll(religiousHolidays);

    final merged = _mergeAndDeduplicate(allHolidays);
    merged.sort((a, b) => a.startDate.compareTo(b.startDate));

    await _cacheService.saveCache(merged);
    return merged;
  }

  List<Holiday> _mergeAndDeduplicate(List<Holiday> allHolidays) {
    final seen = <String>{};
    final unique = <Holiday>[];

    for (final holiday in allHolidays) {
      final key = '${holiday.title}_${holiday.startDate.year}_${holiday.startDate.month}_${holiday.startDate.day}';
      if (!seen.contains(key)) {
        seen.add(key);
        unique.add(holiday);
      }
    }

    return unique;
  }

  Holiday? getNextHoliday(List<Holiday> holidays) {
    final upcoming = holidays.where((h) => !h.isPast).toList();
    upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  Holiday? getSummerHoliday(List<Holiday> holidays) {
    return holidays.where((h) => h.type == HolidayType.summer).firstOrNull;
  }

  List<Holiday> getHolidaysForYear(List<Holiday> holidays, int year) {
    return holidays.where((h) => h.startDate.year == year).toList();
  }

  Future<String> getCacheStatusText() {
    return _cacheService.getCacheStatusText();
  }
}
