class CustomDate {
  final String id;
  final String title;
  final DateTime date;

  CustomDate({
    required this.id,
    required this.title,
    required this.date,
  });

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target.isBefore(today)) return 0;
    return target.difference(today).inDays;
  }

  bool get isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
    };
  }

  factory CustomDate.fromJson(Map<String, dynamic> json) {
    return CustomDate(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  CustomDate copyWith({String? id, String? title, DateTime? date}) {
    return CustomDate(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
    );
  }
}
