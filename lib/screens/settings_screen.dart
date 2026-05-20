import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  @override
  Widget build(BuildContext context) {
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
}
