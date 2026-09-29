import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_colors.dart';
import '../../widgets/info_card.dart';

class WpsSecurityCenterPage extends StatefulWidget {
  const WpsSecurityCenterPage({super.key});

  @override
  State<WpsSecurityCenterPage> createState() => _WpsSecurityCenterPageState();
}

class _WpsSecurityCenterPageState extends State<WpsSecurityCenterPage> {
  static const _prefKey = 'wps_security_checklist_v1';

  final _checks = <String, bool>{
    'Disabled WPS / QSS / Wi-Fi Protected Setup': false,
    'Using WPA2-AES or WPA3 (not WEP / TKIP-only)': false,
    'Changed default router admin password': false,
    'Firmware updated within the last 6 months': false,
    'Guest network isolated from LAN (if used)': false,
    'Remote admin / WAN management disabled': false,
    'Strong Wi-Fi passphrase (12+ random chars)': false,
  };

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefKey) ?? [];
    for (final key in _checks.keys) {
      _checks[key] = saved.contains(key);
    }
    if (mounted) {
      setState(() => _loaded = true);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final done = _checks.entries.where((e) => e.value).map((e) => e.key).toList();
    await prefs.setStringList(_prefKey, done);
  }

  @override
  Widget build(BuildContext context) {
    final done = _checks.values.where((v) => v).length;
    final total = _checks.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Security checklist')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                InfoCard(
                  title: 'Harden your router',
                  child: Text(
                    'Complete this checklist on networks you administer. '
                    'Progress: $done / $total (saved on this device)',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._checks.entries.map((e) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: CheckboxListTile(
                      value: e.value,
                      onChanged: (v) async {
                        setState(() => _checks[e.key] = v ?? false);
                        await _save();
                      },
                      title: Text(
                        e.key,
                        style: const TextStyle(fontSize: 14, height: 1.3),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.navy,
                    ),
                  );
                }),
                const SizedBox(height: 8),
                InfoCard(
                  title: 'Recommended setup',
                  child: const Text(
                    'Wi‑Fi Protected Setup (WPS / QSS) is a convenience feature that many router makers '
                    'advise turning off for everyday use. Prefer WPA2 or WPA3 with a strong passphrase '
                    'on networks you administer. This app does not connect to or reconfigure your router for you.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
