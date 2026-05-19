import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatil_sayaci/models/holiday.dart';
import 'package:tatil_sayaci/utils/constants.dart';

class HolidayCacheService {
  static final HolidayCacheService _instance = HolidayCacheService._internal();
  factory HolidayCacheService() => _instance;
  HolidayCacheService._internal();

  Future<void> saveCache(List<Holiday> holidays) async {
    final prefs = await SharedPreferences.getInstance();
    final holidayJson = holidays.map((h) => h.toJson()).toList();
    await prefs.setString(AppConstants.holidayCacheKey, jsonEncode(holidayJson));
    await prefs.setString(
      AppConstants.holidayCacheTimestampKey,
      DateTime.now().toIso8601String(),
    );
    await prefs.setInt(
      AppConstants.holidayCacheYearKey,
      DateTime.now().year,
    );
  }

  Future<List<Holiday>?> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(AppConstants.holidayCacheKey);
    if (cachedJson == null) return null;

    try {
      final List<dynamic> decoded = jsonDecode(cachedJson);
      return decoded.map((e) => Holiday.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Cache decode error: $e');
      return null;
    }
  }

  Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString(AppConstants.holidayCacheTimestampKey);
    final cachedYear = prefs.getInt(AppConstants.holidayCacheYearKey);
    final now = DateTime.now();

    if (timestampStr == null || cachedYear == null) return false;
    if (cachedYear != now.year) return false;

    final timestamp = DateTime.parse(timestampStr);
    final cacheMonth = timestamp.month;
    return cacheMonth == now.month;
  }

  Future<DateTime?> getLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString(AppConstants.holidayCacheTimestampKey);
    if (timestampStr == null) return null;
    return DateTime.parse(timestampStr);
  }

  Future<Duration?> getCacheAge() async {
    final lastUpdated = await getLastUpdated();
    if (lastUpdated == null) return null;
    return DateTime.now().difference(lastUpdated);
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.holidayCacheKey);
    await prefs.remove(AppConstants.holidayCacheTimestampKey);
    await prefs.remove(AppConstants.holidayCacheYearKey);
  }

  Future<String> getCacheStatusText() async {
    final lastUpdated = await getLastUpdated();
    if (lastUpdated == null) return 'Hiç güncellenmedi';

    final now = DateTime.now();
    final diff = now.difference(lastUpdated);

    if (diff.inMinutes < 1) return 'Az önce güncellendi';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dakika önce güncellendi';
    if (diff.inHours < 24) return '${diff.inHours} saat önce güncellendi';
    return '${diff.inDays} gün önce güncellendi';
  }
}
