import 'package:tatil_sayaci/models/holiday.dart';
import 'package:tatil_sayaci/utils/constants.dart';

class NationalHolidayGenerator {
  static List<Holiday> generateForYear(int year) {
    final holidays = <Holiday>[];

    for (final entry in AppConstants.fixedNationalHolidays.entries) {
      final parts = entry.key.split('-');
      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);
      final days = entry.value;
      final name = AppConstants.fixedNationalHolidayNames[entry.key] ?? 'Bayram';

      if (days == 1) {
        holidays.add(Holiday(
          title: name,
          startDate: DateTime(year, month, day),
          type: HolidayType.national,
        ));
      } else {
        holidays.add(Holiday(
          title: name,
          startDate: DateTime(year, month, day),
          endDate: DateTime(year, month, day + days - 1),
          type: HolidayType.national,
        ));
      }
    }

    holidays.sort((a, b) => a.startDate.compareTo(b.startDate));
    return holidays;
  }

  static List<Holiday> generateAll(int fromYear, int toYear) {
    final all = <Holiday>[];
    for (int year = fromYear; year <= toYear; year++) {
      all.addAll(generateForYear(year));
    }
    return all;
  }
}
