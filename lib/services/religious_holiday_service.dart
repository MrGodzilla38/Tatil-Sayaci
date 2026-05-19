import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tatil_sayaci/models/holiday.dart';
import 'package:tatil_sayaci/utils/constants.dart';
import 'package:hijri_date/hijri.dart';

class ReligiousHolidayService {
  static const _apiBaseUrl = AppConstants.tallyfyApiUrl;

  Future<List<Holiday>?> fetchFromApi(int year) async {
    try {
      final url = '$_apiBaseUrl$year.json';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode != 200) return null;

      final List<dynamic> data = _decodeJson(response.body);
      final holidays = <Holiday>[];

      for (final item in data) {
        final name = item['local_name']?.toString().toLowerCase() ?? '';
        final dateStr = item['date']?.toString() ?? '';
        if (dateStr.isEmpty) continue;

        if (name.contains('ramazan') || name.contains('ramadan')) {
          final startDate = DateTime.parse(dateStr);
          holidays.add(Holiday(
            title: 'Ramazan Bayramı',
            startDate: startDate,
            type: HolidayType.religious,
          ));
        } else if (name.contains('kurban') || name.contains('sacrifice') || name.contains('eid al-adha')) {
          final startDate = DateTime.parse(dateStr);
          holidays.add(Holiday(
            title: 'Kurban Bayramı',
            startDate: startDate,
            type: HolidayType.religious,
          ));
        } else if (name.contains('arife')) {
          final startDate = DateTime.parse(dateStr);
          final parentName = name.contains('ramazan') ? 'Ramazan Bayramı Arifesi' : 'Kurban Bayramı Arifesi';
          holidays.add(Holiday(
            title: parentName,
            startDate: startDate,
            type: HolidayType.religious,
          ));
        }
      }

      return _mergeMultiDayHolidays(holidays);
    } catch (e) {
      debugPrint('API fetch failed for year $year: $e');
      return null;
    }
  }

  List<Holiday> getFromDiyanetCalendar(int year) {
    final holidays = <Holiday>[];
    final yearData = AppConstants.diyanetReligiousHolidays[year];
    if (yearData == null) return holidays;

    final ramazanDates = yearData['ramazan'] ?? [];
    if (ramazanDates.isNotEmpty) {
      final start = DateTime.parse(ramazanDates.first);
      final end = DateTime.parse(ramazanDates.last);
      holidays.add(Holiday(
        title: 'Ramazan Bayramı',
        startDate: start,
        endDate: end,
        type: HolidayType.religious,
      ));
    }

    final kurbanDates = yearData['kurban'] ?? [];
    if (kurbanDates.isNotEmpty) {
      final start = DateTime.parse(kurbanDates.first);
      final end = DateTime.parse(kurbanDates.last);
      holidays.add(Holiday(
        title: 'Kurban Bayramı',
        startDate: start,
        endDate: end,
        type: HolidayType.religious,
      ));
    }

    return holidays;
  }

  List<Holiday> calculateFromHijri(int year) {
    final holidays = <Holiday>[];

    try {
      final ramazanStart = _hijriToGregorian(year, 10, 1);
      if (ramazanStart != null) {
        holidays.add(Holiday(
          title: 'Ramazan Bayramı',
          startDate: ramazanStart,
          endDate: ramazanStart.add(const Duration(days: 2)),
          type: HolidayType.religious,
        ));
      }

      final kurbanStart = _hijriToGregorian(year, 12, 10);
      if (kurbanStart != null) {
        holidays.add(Holiday(
          title: 'Kurban Bayramı',
          startDate: kurbanStart,
          endDate: kurbanStart.add(const Duration(days: 3)),
          type: HolidayType.religious,
        ));
      }
    } catch (e) {
      debugPrint('Hijri calculation failed for year $year: $e');
    }

    return holidays;
  }

  DateTime? _hijriToGregorian(int gYear, int hMonth, int hDay) {
    try {
      final jan1 = HijriDate.fromDate(DateTime(gYear, 1, 1));
      final targetHijriYear = jan1.hYear;
      final hijri = HijriDate.fromHijri(targetHijriYear, hMonth, hDay);
      return hijri.hijriToGregorian(hijri.hYear, hijri.hMonth, hijri.hDay);
    } catch (e) {
      return null;
    }
  }

  Future<List<Holiday>> getReligiousHolidays(int year) async {
    final apiResult = await fetchFromApi(year);
    if (apiResult != null && apiResult.isNotEmpty) {
      return apiResult;
    }

    final diyanetResult = getFromDiyanetCalendar(year);
    if (diyanetResult.isNotEmpty) {
      return diyanetResult;
    }

    return calculateFromHijri(year);
  }

  Future<List<Holiday>> getReligiousHolidaysForRange(int fromYear, int toYear) async {
    final all = <Holiday>[];
    for (int year = fromYear; year <= toYear; year++) {
      final yearHolidays = await getReligiousHolidays(year);
      all.addAll(yearHolidays);
    }
    return all;
  }

  List<Holiday> _mergeMultiDayHolidays(List<Holiday> holidays) {
    final grouped = <String, List<Holiday>>{};
    for (final h in holidays) {
      final key = h.title;
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(h);
    }

    final merged = <Holiday>[];
    for (final entry in grouped.entries) {
      final sameType = entry.value;
      sameType.sort((a, b) => a.startDate.compareTo(b.startDate));
      if (sameType.length == 1) {
        merged.add(sameType.first);
      } else {
        merged.add(Holiday(
          title: entry.key,
          startDate: sameType.first.startDate,
          endDate: sameType.last.startDate,
          type: entry.value.first.type,
        ));
      }
    }
    return merged;
  }

  List<dynamic> _decodeJson(String body) {
    try {
      return _simpleJsonParse(body);
    } catch (e) {
      return [];
    }
  }

  List<dynamic> _simpleJsonParse(String json) {
    final trimmed = json.trim();
    if (!trimmed.startsWith('[')) return [];
    final items = <Map<String, dynamic>>[];
    final regex = RegExp(r'\{[^}]+\}');
    final matches = regex.allMatches(trimmed);
    for (final match in matches) {
      final obj = <String, dynamic>{};
      final str = match.group(0)!;
      final kvRegex = RegExp(r'"([^"]+)"\s*:\s*"([^"]*)"');
      for (final kv in kvRegex.allMatches(str)) {
        obj[kv.group(1)!] = kv.group(2)!;
      }
      if (obj.isNotEmpty) items.add(obj);
    }
    return items;
  }
}
