import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NotificationForegroundService {
  static const _channel = MethodChannel('tatil_sayaci/foreground_service');

  static Future<void> start({
    required String summerLabel,
    required String summerDays,
    required bool summerVisible,
    required String holidayLabel,
    required String holidayDays,
    required bool holidayVisible,
    required String customLabel,
    required String customDays,
    required bool customVisible,
    required bool emptyVisible,
  }) async {
    try {
      await _channel.invokeMethod('startForegroundService', {
        'summerLabel': summerLabel,
        'summerDays': summerDays,
        'summerVisible': summerVisible,
        'holidayLabel': holidayLabel,
        'holidayDays': holidayDays,
        'holidayVisible': holidayVisible,
        'customLabel': customLabel,
        'customDays': customDays,
        'customVisible': customVisible,
        'emptyVisible': emptyVisible,
      });
    } catch (e) {
      debugPrint('Foreground service start failed: $e');
    }
  }

  static Future<void> update({
    required String summerLabel,
    required String summerDays,
    required bool summerVisible,
    required String holidayLabel,
    required String holidayDays,
    required bool holidayVisible,
    required String customLabel,
    required String customDays,
    required bool customVisible,
    required bool emptyVisible,
  }) async {
    try {
      await _channel.invokeMethod('updateForegroundService', {
        'summerLabel': summerLabel,
        'summerDays': summerDays,
        'summerVisible': summerVisible,
        'holidayLabel': holidayLabel,
        'holidayDays': holidayDays,
        'holidayVisible': holidayVisible,
        'customLabel': customLabel,
        'customDays': customDays,
        'customVisible': customVisible,
        'emptyVisible': emptyVisible,
      });
    } catch (e) {
      debugPrint('Foreground service update failed: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stopForegroundService');
    } catch (e) {
      debugPrint('Foreground service stop failed: $e');
    }
  }
}
