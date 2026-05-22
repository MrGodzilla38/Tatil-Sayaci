import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:tatil_sayaci/providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'Tatil Sayacı v${info.version}';
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _checkUpdate() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Güncelleme kontrol ediliyor...'),
          ],
        ),
      ),
    );

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/MrGodzilla38/Tatil-Sayaci/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (!context.mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final latestTag = data['tag_name'] as String? ?? '';
        final versionMatch = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(latestTag);
        final latestVersion = versionMatch?.group(1) ?? '';

        final info = await PackageInfo.fromPlatform();
        final currentVersion = info.version;

        final isUpToDate = _compareVersions(currentVersion, latestVersion) >= 0;

        if (!context.mounted) return;

        if (isUpToDate) {
          _showResultDialog('Güncelleme Kontrolü', '✅ Sürüm güncel', null);
        } else {
          _showResultDialog(
            'Güncelleme Kontrolü',
            'Yeni sürüm bulundu $latestTag',
            'Güncelle',
          );
        }
      } else {
        if (!context.mounted) return;
        Navigator.pop(context);
        _showResultDialog('Güncelleme Kontrolü', '❌ Sürüm bilgisi alınamadı', null);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      _showResultDialog('Güncelleme Kontrolü', '❌ Bağlantı hatası', null);
    }
  }

  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 != p2) return p1 - p2;
    }
    return 0;
  }

  void _showResultDialog(String title, String message, String? buttonText) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (buttonText != null)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _launchUrl('https://github.com/MrGodzilla38/Tatil-Sayaci/releases');
              },
              child: Text(buttonText),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Uygulama Hakkında'),
            subtitle: Text(_version.isEmpty ? 'Yükleniyor...' : _version),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text('Güncelleme Kontrolü'),
            subtitle: const Text('Yeni sürüm var mı kontrol et'),
            onTap: _checkUpdate,
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Bildirimler'),
            subtitle: const Text('Arka planda tatil sayısını göster'),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              settings.setNotificationsEnabled(value);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Tema'),
            subtitle: Text(
              settings.themeMode == ThemeMode.system
                  ? 'Sistem varsayılanı'
                  : settings.themeMode == ThemeMode.light
                      ? 'Açık'
                      : 'Koyu',
            ),
            onTap: () => _showThemeDialog(context, settings),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Kaynak Kodu'),
            subtitle: const Text('GitHub'),
            onTap: () => _launchUrl('https://github.com/MrGodzilla38/Tatil-Sayaci'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Hata Bildir'),
            onTap: () => _launchUrl('https://github.com/MrGodzilla38/Tatil-Sayaci/issues'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tema Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Sistem Varsayılanı'),
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (value) {
                settings.setThemeMode(value!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Açık'),
              value: ThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (value) {
                settings.setThemeMode(value!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Koyu'),
              value: ThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (value) {
                settings.setThemeMode(value!);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
