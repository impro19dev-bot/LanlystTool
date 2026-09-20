import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../state/app_network_state.dart';
import '../../theme/app_colors.dart';
import '../../utils/ip_utils.dart';
import '../../widgets/section_header.dart';
import '../../widgets/soft_card.dart';
import '../../widgets/status_strip.dart';
import '../../widgets/tool_list_tile.dart';
import '../../widgets/wps_watermark.dart';
import '../wps/router_setup_assistant_page.dart';
import '../wps/wps_risk_snapshot_page.dart';
import '../wps/wps_security_center_page.dart';

class NetworkTab extends StatelessWidget {
  const NetworkTab({super.key, required this.state});

  final AppNetworkState state;

  Future<void> _setManualIp(BuildContext context) async {
    final controller = TextEditingController(
      text: state.effectiveScanIp ?? '192.168.1.10',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Set local Wi-Fi IP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'On Simulator or when SSID is hidden, enter your phone’s LAN IP so device scan and gateway tools can run.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'IPv4'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
    if (result == null) return;
    if (!IpUtils.isValidIpv4(result)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid IPv4 address')),
        );
      }
      return;
    }
    state.setManualScanIp(result);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Using $result for LAN tools')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wifi = state.wifi;
    final hasName = wifi?.ssid != null && wifi!.ssid != 'Manual network';
    final hasAnyNetwork = state.effectiveScanIp != null;

    return Column(
      children: [
        StatusStrip(
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: state.showWpsTips,
                  onChanged: (v) => state.setShowWpsTips(v ?? true),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Security tips',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _setManualIp(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Set IP'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              const WpsWatermark(),
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                children: [
                  if (!hasName) ...[
                    Text(
                      kDebugMode
                          ? 'Simulator. Use a real iPhone on Wi-Fi.'
                          : 'Wi-Fi details unavailable',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (state.loadError != null && !hasName)
                    Text(
                      state.loadError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  if (hasAnyNetwork) ...[
                    const SizedBox(height: 8),
                    _WifiSummaryCard(state: state),
                    const SizedBox(height: 20),
                  ] else
                    const SizedBox(height: 20),
                  if (state.showWpsTips) ...[
                    SoftCard(
                      color: AppColors.orange.withValues(alpha: 0.08),
                      padding: const EdgeInsets.all(14),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: AppColors.orange, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tip: Harden routers you own (strong Wi‑Fi password, current firmware). This app does not recover or crack Wi‑Fi passwords.',
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.35,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SectionHeader(
                    icon: Icons.build_circle_outlined,
                    title: 'Lanlyst tools',
                  ),
                  const SizedBox(height: 12),
                  ToolListTile(
                    icon: Icons.bar_chart_rounded,
                    iconColor: AppColors.orange,
                    title: 'Router risk snapshot',
                    subtitle: 'Current Wi-Fi and hardening guidance',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => WpsRiskSnapshotPage(state: state),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ToolListTile(
                    icon: Icons.shield_rounded,
                    iconColor: AppColors.navy,
                    title: 'Security checklist',
                    subtitle: 'Harden your router step by step',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const WpsSecurityCenterPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ToolListTile(
                    icon: Icons.router_rounded,
                    iconColor: AppColors.teal,
                    title: 'Router Quick Setup Assistant',
                    subtitle: 'Gateway, WPA2/WPA3, admin password',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              RouterSetupAssistantPage(state: state),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WifiSummaryCard extends StatelessWidget {
  const _WifiSummaryCard({required this.state});

  final AppNetworkState state;

  @override
  Widget build(BuildContext context) {
    final w = state.wifi!;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.wifi_rounded, color: AppColors.navy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  w.displayName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _kv('IP', w.wifiIp ?? '—'),
          _kv('Gateway', w.gatewayIp ?? '—'),
          _kv('Subnet', w.subnet ?? '—'),
          _kv('BSSID', w.bssid ?? '—'),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              k,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
