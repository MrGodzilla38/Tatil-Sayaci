import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:tatil_sayaci/providers/app_provider.dart';
import 'package:tatil_sayaci/models/holiday.dart';
import 'package:tatil_sayaci/models/custom_date.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tatil Takvimi'),
        centerTitle: true,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final holidayEvents = provider.holidayEvents;
          final customEvents = provider.customDateEvents;

          final allEvents = <DateTime, List<dynamic>>{};
          for (final entry in holidayEvents.entries) {
            allEvents[entry.key] = [...entry.value];
          }
          for (final entry in customEvents.entries) {
            allEvents.putIfAbsent(entry.key, () => []);
            allEvents[entry.key]!.addAll(entry.value);
          }

          return Column(
            children: [
              TableCalendar<dynamic>(
                firstDay: DateTime(2025, 1, 1),
                lastDay: DateTime(2027, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() => _calendarFormat = format);
                  }
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                eventLoader: (day) {
                  final key = DateTime(day.year, day.month, day.day);
                  return allEvents[key] ?? [];
                },
                calendarStyle: CalendarStyle(
                  markerDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  markersMaxCount: 3,
                  markerSize: 6,
                  markerSizeScale: 1,
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox();
                    return Positioned(
                      bottom: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: events.take(3).map((event) {
                          Color dotColor;
                          if (event is Holiday) {
                            switch (event.type) {
                              case HolidayType.school:
                                dotColor = Colors.blue;
                                break;
                              case HolidayType.national:
                                dotColor = Colors.red;
                                break;
                              case HolidayType.religious:
                                dotColor = Colors.green;
                                break;
                              case HolidayType.summer:
                                dotColor = Colors.orange;
                                break;
                            }
                          } else if (event is CustomDate) {
                            dotColor = Colors.purple;
                          } else {
                            dotColor = Colors.grey;
                          }
                          return Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                ),
              ),
              const Divider(),
              Expanded(
                child: _selectedDay != null
                    ? _buildEventsList(
                        allEvents,
                        DateTime(
                          _selectedDay!.year,
                          _selectedDay!.month,
                          _selectedDay!.day,
                        ),
                      )
                    : const Center(
                        child: Text('Detay görmek için bir gün seçin'),
                      ),
              ),
            ],
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend('Okul', Colors.blue),
            const SizedBox(width: 16),
            _buildLegend('Milli', Colors.red),
            const SizedBox(width: 16),
            _buildLegend('Dini', Colors.green),
            const SizedBox(width: 16),
            _buildLegend('Yaz', Colors.orange),
            const SizedBox(width: 16),
            _buildLegend('Özel', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(Map<DateTime, List<dynamic>> events, DateTime day) {
    final dayEvents = events[day] ?? [];

    if (dayEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMMM yyyy', 'tr_TR').format(day),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Bu gün için tatil yok',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        if (event is Holiday) {
          return _buildHolidayTile(event);
        } else if (event is CustomDate) {
          return _buildCustomDateTile(event);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildHolidayTile(Holiday holiday) {
    IconData icon;
    Color color;
    switch (holiday.type) {
      case HolidayType.school:
        icon = Icons.school;
        color = Colors.blue;
        break;
      case HolidayType.national:
        icon = Icons.flag;
        color = Colors.red;
        break;
      case HolidayType.religious:
        icon = Icons.mosque;
        color = Colors.green;
        break;
      case HolidayType.summer:
        icon = Icons.wb_sunny;
        color = Colors.orange;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(holiday.title),
        subtitle: Text(
          holiday.isMultiDay
              ? '${DateFormat('dd MMMM', 'tr_TR').format(holiday.startDate)} - ${DateFormat('dd MMMM yyyy', 'tr_TR').format(holiday.endDate!)}'
              : DateFormat('dd MMMM yyyy', 'tr_TR').format(holiday.startDate),
        ),
        trailing: holiday.isPast
            ? const Icon(Icons.check_circle, color: Colors.grey)
            : Text(
                '${holiday.daysRemaining} gün',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildCustomDateTile(CustomDate date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.2),
          child: const Icon(Icons.star, color: Colors.purple),
        ),
        title: Text(date.title),
        subtitle: Text(DateFormat('dd MMMM yyyy', 'tr_TR').format(date.date)),
        trailing: date.isPast
            ? const Icon(Icons.check_circle, color: Colors.grey)
            : Text(
                '${date.daysRemaining} gün',
                style: const TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
