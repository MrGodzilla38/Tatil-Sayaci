import 'package:tatil_sayaci/models/holiday.dart';

class SchoolHolidayCalculator {
  static List<Holiday> calculateForYear(int year) {
    final holidays = <Holiday>[];

    final araTatil1 = _findFirstAraTatil(year);
    if (araTatil1 != null) holidays.add(araTatil1);

    final somestr = _findSomestrTatili(year);
    if (somestr != null) holidays.add(somestr);

    final araTatil2 = _findSecondAraTatil(year);
    if (araTatil2 != null) holidays.add(araTatil2);

    final yazTatili = _findYazTatili(year);
    if (yazTatili != null) holidays.add(yazTatili);

    holidays.sort((a, b) => a.startDate.compareTo(b.startDate));
    return holidays;
  }

  static List<Holiday> calculateAll(int fromYear, int toYear) {
    final all = <Holiday>[];
    for (int year = fromYear; year <= toYear; year++) {
      all.addAll(calculateForYear(year));
    }
    return all;
  }

  static Holiday? _findFirstAraTatil(int year) {
    final november = DateTime(year, 11, 1);
    final secondMonday = _findNthWeekdayOfMonth(november.year, november.month, DateTime.monday, 2);
    if (secondMonday == null) return null;
    return Holiday(
      title: '1. Ara Tatil',
      startDate: secondMonday,
      endDate: secondMonday.add(const Duration(days: 4)),
      type: HolidayType.school,
    );
  }

  static Holiday? _findSomestrTatili(int year) {
    final january = DateTime(year, 1, 1);
    final thirdMonday = _findNthWeekdayOfMonth(january.year, january.month, DateTime.monday, 3);
    if (thirdMonday == null) return null;
    final endDate = thirdMonday.add(const Duration(days: 9));
    return Holiday(
      title: 'Sömestr Tatili',
      startDate: thirdMonday,
      endDate: endDate,
      type: HolidayType.school,
    );
  }

  static Holiday? _findSecondAraTatil(int year) {
    final april = DateTime(year, 4, 1);
    final secondMonday = _findNthWeekdayOfMonth(april.year, april.month, DateTime.monday, 2);
    if (secondMonday == null) return null;
    return Holiday(
      title: '2. Ara Tatil',
      startDate: secondMonday,
      endDate: secondMonday.add(const Duration(days: 4)),
      type: HolidayType.school,
    );
  }

  static Holiday? _findYazTatili(int year) {
    final june = DateTime(year, 6, 1);
    final lastFriday = _findLastWeekdayOfMonth(june.year, june.month, DateTime.friday);
    if (lastFriday == null) return null;
    return Holiday(
      title: 'Yaz Tatili',
      startDate: lastFriday,
      type: HolidayType.summer,
    );
  }

  static DateTime? _findNthWeekdayOfMonth(int year, int month, int weekday, int n) {
    var count = 0;
    var date = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0);
    while (!date.isAfter(endOfMonth)) {
      if (date.weekday == weekday) {
        count++;
        if (count == n) return date;
      }
      date = date.add(const Duration(days: 1));
    }
    return null;
  }

  static DateTime? _findLastWeekdayOfMonth(int year, int month, int weekday) {
    final endOfMonth = DateTime(year, month + 1, 0);
    var date = endOfMonth;
    final startOfMonth = DateTime(year, month, 1);
    while (!date.isBefore(startOfMonth)) {
      if (date.weekday == weekday) return date;
      date = date.subtract(const Duration(days: 1));
    }
    return null;
  }

  static bool isSchoolHolidayExtensionPossible(DateTime date) {
    final dayOfWeek = date.weekday;
    return dayOfWeek == DateTime.friday || dayOfWeek == DateTime.monday;
  }
}
