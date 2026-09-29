import 'package:flutter/material.dart';

import '../../state/app_network_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/info_card.dart';

class WpsRiskSnapshotPage extends StatelessWidget {
  const WpsRiskSnapshotPage({super.key, required this.state});

  final AppNetworkState state;

  @override
  Widget build(BuildContext context) {
    final wifi = state.wifi;
    return Scaffold(
      appBar: AppBar(title: const Text('Router risk snapshot')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoCard(
            title: 'Current Wi-Fi',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('SSID', wifi?.ssid ?? 'Unavailable'),
                _row('IP', wifi?.wifiIp ?? '—'),
                _row('Gateway', wifi?.gatewayIp ?? '—'),
                _row('BSSID', wifi?.bssid ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InfoCard(
            title: 'Router setup tips',
            child: const Text(
              'iOS cannot report whether Wi‑Fi Protected Setup (WPS) is enabled on your access point. '
              'On a router you administer, open the admin page and turn WPS / QSS off if your vendor recommends it. '
              'Use WPA2 or WPA3 with a strong passphrase. WPSApp is a Wi‑Fi analyzer — it does not recover passwords.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          InfoCard(
            title: 'Best practices (educational)',
            child: Column(
              children: const [
                _RiskRow(
                  label: 'WPS / push-button setup',
                  level: 'Often best left off',
                  color: Color(0xFFE74C3C),
                ),
                _RiskRow(
                  label: 'WPA2-Personal (AES)',
                  level: 'Solid choice',
                  color: Color(0xFFF39C12),
                ),
                _RiskRow(
                  label: 'WPA3-Personal',
                  level: 'Preferred',
                  color: Color(0xFF27AE60),
                ),
                _RiskRow(
                  label: 'Open / WEP',
                  level: 'Avoid',
                  color: Color(0xFFE74C3C),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(k, style: const TextStyle(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskRow extends StatelessWidget {
  const _RiskRow({
    required this.label,
    required this.level,
    required this.color,
  });

  final String label;
  final String level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              level,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
