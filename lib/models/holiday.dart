enum HolidayType { school, national, religious, summer }

class Holiday {
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final HolidayType type;

  Holiday({
    required this.title,
    required this.startDate,
    this.endDate,
    required this.type,
  });

  bool get isMultiDay => endDate != null;

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (startDate.isBefore(today)) return 0;
    return startDate.difference(today).inDays;
  }

  bool get isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return endDate != null
        ? endDate!.isBefore(today)
        : startDate.isBefore(today);
  }

  bool isOnDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    if (isMultiDay) {
      return !d.isBefore(startDate) && !d.isAfter(endDate!);
    }
    return d.year == startDate.year &&
        d.month == startDate.month &&
        d.day == startDate.day;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'type': type.name,
    };
  }

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      title: json['title'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      type: HolidayType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HolidayType.school,
      ),
    );
  }
}
