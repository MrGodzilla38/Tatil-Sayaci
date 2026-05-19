import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tatil_sayaci/providers/app_provider.dart';
import 'package:tatil_sayaci/widgets/countdown_card.dart';
import 'package:tatil_sayaci/screens/calendar_screen.dart';
import 'package:tatil_sayaci/screens/custom_dates_screen.dart';
import 'package:tatil_sayaci/screens/add_date_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tatil Sayacı'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final summer = provider.summerHoliday;
          final next = provider.nextHoliday;
          final custom = provider.nextCustomDate;

          return RefreshIndicator(
            onRefresh: () => provider.refreshHolidays(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          provider.cacheStatusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (provider.isRefreshing)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                  if (summer != null)
                    _buildSummerCard(context, summer),
                  const SizedBox(height: 16),
                  if (next != null)
                    _buildNextHolidayCard(context, next),
                  const SizedBox(height: 16),
                  if (custom != null)
                    _buildCustomDateCard(context, provider, custom),
                  if (custom == null && provider.customDates.isEmpty)
                    _buildAddCustomHint(context),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomDatesScreen()),
            ),
            child: const Icon(Icons.star),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'calendar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            ),
            child: const Icon(Icons.calendar_today),
          ),
        ],
      ),
    );
  }

  Widget _buildSummerCard(BuildContext context, holiday) {
    final days = holiday.daysRemaining;
    final formattedDate = DateFormat('dd MMMM yyyy', 'tr_TR').format(holiday.startDate);

    return CountdownCard(
      title: 'Yaz Tatiline',
      daysRemaining: days,
      subtitle: days > 0 ? '$formattedDate tarihinde başlıyor' : 'Yaz tatili başladı!',
      icon: Icons.wb_sunny,
      gradientStart: const Color(0xFFFF9800),
      gradientEnd: const Color(0xFFFF5722),
    );
  }

  Widget _buildNextHolidayCard(BuildContext context, holiday) {
    final days = holiday.daysRemaining;
    String formattedDate;
    if (holiday.isMultiDay) {
      final start = DateFormat('dd MMMM', 'tr_TR').format(holiday.startDate);
      final end = DateFormat('dd MMMM yyyy', 'tr_TR').format(holiday.endDate!);
      formattedDate = '$start - $end';
    } else {
      formattedDate = DateFormat('dd MMMM yyyy', 'tr_TR').format(holiday.startDate);
    }

    return CountdownCard(
      title: 'Sıradaki Tatil',
      daysRemaining: days,
      subtitle: '${holiday.title}\n$formattedDate',
      icon: Icons.celebration,
      gradientStart: const Color(0xFF4CAF50),
      gradientEnd: const Color(0xFF009688),
    );
  }

  Widget _buildCustomDateCard(
      BuildContext context, AppProvider provider, custom) {
    final days = custom.daysRemaining;
    final formattedDate = DateFormat('dd MMMM yyyy', 'tr_TR').format(custom.date);

    return GestureDetector(
      onLongPress: () => _showCustomDateMenu(context, provider, custom),
      child: CountdownCard(
        title: '${custom.title}',
        daysRemaining: days,
        subtitle: formattedDate,
        icon: Icons.star,
        gradientStart: const Color(0xFF9C27B0),
        gradientEnd: const Color(0xFF673AB7),
        onDelete: () => _confirmDelete(context, provider, custom.id),
        onEdit: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddDateScreen(existingDate: custom),
          ),
        ),
      ),
    );
  }

  void _showCustomDateMenu(
      BuildContext context, AppProvider provider, custom) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Düzenle'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddDateScreen(existingDate: custom),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Sil'),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, provider, custom.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCustomHint(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomDatesScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.add_circle_outline,
                  size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'Özel günlerinizi yönetmek için + butonuna tıklayın',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sil'),
        content: const Text('Bu özel günü silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              provider.removeCustomDate(id);
              Navigator.pop(ctx);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
