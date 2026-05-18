import 'package:tatil_sayaci/models/holiday.dart';

class AppConstants {
  static const String appName = 'TatilSayacı';
  static const String customDatesKey = 'custom_dates';

  static List<Holiday> get fallbackHolidays => [
        Holiday(
          title: 'Cumhuriyet Bayramı',
          startDate: DateTime(2025, 10, 29),
          type: HolidayType.national,
        ),
        Holiday(
          title: '1. Ara Tatil',
          startDate: DateTime(2025, 11, 10),
          endDate: DateTime(2025, 11, 14),
          type: HolidayType.school,
        ),
        Holiday(
          title: 'Yılbaşı',
          startDate: DateTime(2026, 1, 1),
          type: HolidayType.national,
        ),
        Holiday(
          title: 'Sömestr Tatili (15 Tatil)',
          startDate: DateTime(2026, 1, 19),
          endDate: DateTime(2026, 1, 30),
          type: HolidayType.school,
        ),
        Holiday(
          title: 'Ramazan Bayramı',
          startDate: DateTime(2026, 3, 19),
          endDate: DateTime(2026, 3, 22),
          type: HolidayType.religious,
        ),
        Holiday(
          title: '2. Ara Tatil',
          startDate: DateTime(2026, 3, 16),
          endDate: DateTime(2026, 3, 20),
          type: HolidayType.school,
        ),
        Holiday(
          title: '23 Nisan Ulusal Egemenlik ve Çocuk Bayramı',
          startDate: DateTime(2026, 4, 23),
          type: HolidayType.national,
        ),
        Holiday(
          title: '1 Mayıs Emek ve Dayanışma Günü',
          startDate: DateTime(2026, 5, 1),
          type: HolidayType.national,
        ),
        Holiday(
          title: '19 Mayıs Atatürk\'ü Anma, Gençlik ve Spor Bayramı',
          startDate: DateTime(2026, 5, 19),
          type: HolidayType.national,
        ),
        Holiday(
          title: 'Kurban Bayramı',
          startDate: DateTime(2026, 5, 26),
          endDate: DateTime(2026, 5, 30),
          type: HolidayType.religious,
        ),
        Holiday(
          title: '15 Temmuz Demokrasi ve Milli Birlik Günü',
          startDate: DateTime(2026, 7, 15),
          type: HolidayType.national,
        ),
        Holiday(
          title: '30 Ağustos Zafer Bayramı',
          startDate: DateTime(2026, 8, 30),
          type: HolidayType.national,
        ),
        Holiday(
          title: 'Cumhuriyet Bayramı',
          startDate: DateTime(2026, 10, 29),
          type: HolidayType.national,
        ),
        Holiday(
          title: 'Yaz Tatili',
          startDate: DateTime(2026, 6, 26),
          type: HolidayType.summer,
        ),
      ];
}
