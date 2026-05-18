import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:tatil_sayaci/models/holiday.dart';
import 'package:tatil_sayaci/utils/constants.dart';

class HolidayService {
  static const List<String> _scrapeUrls = [
    'https://www.ntv.com.tr/galeri/egitim/2026-tatil-tarihleri-yeni-egitim-ogretim-yilinda-ilk-ara-tatil-ne-zaman-15-tatil-ikinci-ara-tatil-ve-yaz-tatili-baslangic-tarihi,WQRgFRwHeUun71Lq484UzQ',
    'https://go-inc.org/2025-2026-egitim-yili-baslama-ara-tatil-ve-soemestr-tarihleri',
  ];

  Future<List<Holiday>> getHolidays() async {
    try {
      final scraped = await _tryScrape();
      if (scraped.isNotEmpty) {
        return _mergeWithFallback(scraped);
      }
    } catch (e) {
      print('Scraping failed: $e');
    }
    return AppConstants.fallbackHolidays;
  }

  Future<List<Holiday>> _tryScrape() async {
    for (final url in _scrapeUrls) {
      try {
        final holidays = await _scrapeUrl(url);
        if (holidays.isNotEmpty) return holidays;
      } catch (e) {
        print('Failed to scrape $url: $e');
      }
    }
    return [];
  }

  Future<List<Holiday>> _scrapeUrl(String url) async {
    final response = await http.get(Uri.parse(url)).timeout(
      const Duration(seconds: 10),
    );
    if (response.statusCode != 200) return [];

    final document = html_parser.parse(response.body);
    final text = document.body?.text ?? '';
    return _parseHolidaysFromText(text);
  }

  List<Holiday> _parseHolidaysFromText(String text) {
    final holidays = <Holiday>[];

    final araTatil1 = _extractDateRange(
      text,
      RegExp(r'(\d{1,2})\s*[-–]\s*(\d{1,2})\s*(Kasım)'),
      HolidayType.school,
      '1. Ara Tatil',
    );
    if (araTatil1 != null) holidays.add(araTatil1);

    final somestr = _extractDateRange(
      text,
      RegExp(r'(\d{1,2})\s*[-–]\s*(\d{1,2})\s*(Ocak)'),
      HolidayType.school,
      'Sömestr Tatili',
    );
    if (somestr != null) holidays.add(somestr);

    final araTatil2 = _extractDateRange(
      text,
      RegExp(r'(\d{1,2})\s*[-–]\s*(\d{1,2})\s*(Mart)'),
      HolidayType.school,
      '2. Ara Tatil',
    );
    if (araTatil2 != null) holidays.add(araTatil2);

    _extractDateRange(
      text,
      RegExp(r'(\d{1,2})\s*[-–]\s*(\d{1,2})\s*(Mart)'),
      HolidayType.religious,
      'Ramazan Bayramı',
    );

    final kurban = _extractDateRange(
      text,
      RegExp(r'(\d{1,2})\s*[-–]\s*(\d{1,2})\s*(Mayıs)'),
      HolidayType.religious,
      'Kurban Bayramı',
    );
    if (kurban != null) holidays.add(kurban);

    final yaz = _extractSummerStart(text);
    if (yaz != null) holidays.add(yaz);

    return holidays;
  }

  Holiday? _extractDateRange(
    String text,
    RegExp pattern,
    HolidayType type,
    String title,
  ) {
    final match = pattern.firstMatch(text);
    if (match == null) return null;

    final monthStr = match.group(3)!;
    final month = _monthToInt(monthStr);
    final startDay = int.tryParse(match.group(1)!) ?? 0;
    final endDay = int.tryParse(match.group(2)!) ?? startDay;

    final year = text.contains('2025') && month < 6 ? 2025 : 2026;

    return Holiday(
      title: title,
      startDate: DateTime(year, month, startDay),
      endDate: DateTime(year, month, endDay),
      type: type,
    );
  }

  Holiday? _extractSummerStart(String text) {
    final match = RegExp(r'(\d{1,2})\s*(Haziran)\s*2026').firstMatch(text);
    if (match == null) return null;
    return Holiday(
      title: 'Yaz Tatili',
      startDate: DateTime(2026, 6, int.parse(match.group(1)!)),
      type: HolidayType.summer,
    );
  }

  int _monthToInt(String month) {
    switch (month) {
      case 'Ocak': return 1;
      case 'Şubat': return 2;
      case 'Mart': return 3;
      case 'Nisan': return 4;
      case 'Mayıs': return 5;
      case 'Haziran': return 6;
      case 'Temmuz': return 7;
      case 'Ağustos': return 8;
      case 'Eylül': return 9;
      case 'Ekim': return 10;
      case 'Kasım': return 11;
      case 'Aralık': return 12;
      default: return 1;
    }
  }

  List<Holiday> _mergeWithFallback(List<Holiday> scraped) {
    final merged = <Holiday>[];
    for (final fallback in AppConstants.fallbackHolidays) {
      final scrapedMatch = scraped.where(
        (s) => s.type == fallback.type &&
            s.startDate.month == fallback.startDate.month,
      );
      if (scrapedMatch.isNotEmpty) {
        merged.add(scrapedMatch.first);
      } else {
        merged.add(fallback);
      }
    }
    for (final s in scraped) {
      if (!merged.any(
        (m) => m.type == s.type && m.startDate.month == s.startDate.month,
      )) {
        merged.add(s);
      }
    }
    merged.sort((a, b) => a.startDate.compareTo(b.startDate));
    return merged;
  }

  Holiday? getNextHoliday(List<Holiday> holidays) {
    final upcoming = holidays.where((h) => !h.isPast).toList();
    upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  Holiday? getSummerHoliday(List<Holiday> holidays) {
    return holidays.where((h) => h.type == HolidayType.summer).firstOrNull;
  }
}
