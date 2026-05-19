import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatil_sayaci/models/custom_date.dart';
import 'package:tatil_sayaci/utils/constants.dart';

class CustomDateService {
  Future<List<CustomDate>> loadCustomDates() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(AppConstants.customDatesKey);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList
        .map((json) => CustomDate.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCustomDates(List<CustomDate> dates) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = dates.map((d) => d.toJson()).toList();
    await prefs.setString(AppConstants.customDatesKey, jsonEncode(jsonList));
  }

  Future<void> addCustomDate(CustomDate date) async {
    final dates = await loadCustomDates();
    dates.add(date);
    await saveCustomDates(dates);
  }

  Future<void> removeCustomDate(String id) async {
    final dates = await loadCustomDates();
    dates.removeWhere((d) => d.id == id);
    await saveCustomDates(dates);
  }

  Future<void> updateCustomDate(CustomDate updatedDate) async {
    final dates = await loadCustomDates();
    final index = dates.indexWhere((d) => d.id == updatedDate.id);
    if (index != -1) {
      dates[index] = updatedDate;
      await saveCustomDates(dates);
    }
  }

  CustomDate? getNextCustomDate(List<CustomDate> dates) {
    final upcoming = dates.where((d) => !d.isPast).toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }
}
