import 'package:flutter/material.dart';

import '../../state/app_network_state.dart';
import '../../theme/app_colors.dart';
import '../../utils/ip_utils.dart';
import '../../widgets/status_strip.dart';
import '../../widgets/wps_watermark.dart';
import '../tools/ping_page.dart';
import '../tools/port_scan_page.dart';

class DevicesTab extends StatelessWidget {
  const DevicesTab({super.key, required this.state});

  final AppNetworkState state;

  Future<void> _promptForIp(BuildContext context) async {
    final controller = TextEditingController(
      text: state.effectiveScanIp ?? '192.168.1.10',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Local IP for scan'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Your device IP on Wi-Fi',
              hintText: '192.168.1.10',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
              child: const Text('Save'),
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
  }

  Future<void> _onScan(BuildContext context) async {
    if (state.effectiveScanIp == null) {
      await _promptForIp(context);
      if (state.effectiveScanIp == null) return;
    }
    final ok = await state.scanDevices();
    if (!ok && context.mounted && state.scanError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.scanError!)),
      );
    }
  }

  void _openDeviceActions(BuildContext context, String ip) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(ip, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Choose an action'),
              ),
              ListTile(
                leading: const Icon(Icons.network_ping),
                title: const Text('Ping host'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PingPage(initialHost: ip),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.radar),
                title: const Text('Port scan'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PortScanPage(initialHost: ip),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wifi = state.wifi;
    final scanIp = state.effectiveScanIp;
    final count = state.devices.length;

    return Column(
      children: [
        StatusStrip(
          child: Row(
            children: [
              const Icon(Icons.wifi_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scanIp != null
                          ? (wifi?.ssid ?? 'Ready to scan')
                          : 'No Wi-Fi details',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.scanningDevices
                          ? 'Scanning… ${state.scanProgress}/${state.scanTotal}'
                          : scanIp != null
                              ? 'Reachable hosts: $count · base $scanIp'
                              : 'Tap SCAN and enter a local IP',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (scanIp == null)
                TextButton(
                  onPressed: state.scanningDevices
                      ? null
                      : () => _promptForIp(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                  ),
                  child: const Text('IP'),
                ),
              FilledButton.icon(
                onPressed:
                    state.scanningDevices ? null : () => _onScan(context),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.navy,
                  disabledBackgroundColor: Colors.white24,
                  disabledForegroundColor: Colors.white70,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  visualDensity: VisualDensity.compact,
                ),
                icon: state.scanningDevices
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.navy,
                        ),
                      )
                    : const Icon(Icons.search_rounded, size: 18),
                label: Text(
                  state.scanningDevices ? '…' : 'SCAN',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              const WpsWatermark(opacity: 0.28),
              if (scanIp == null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Load Wi-Fi on the NETWORK tab, or enter a local IP to scan your /24 subnet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => _promptForIp(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.navy,
                          ),
                          child: const Text('Enter local IP'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state.devices.isEmpty && !state.scanningDevices)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.scanError ??
                              'Tap SCAN to discover reachable hosts on your /24 subnet.\nUses TCP probes (ICMP is restricted on iOS).',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => _promptForIp(context),
                          child: const Text('Change scan IP'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state.scanningDevices)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.navy),
                      const SizedBox(height: 16),
                      Text(
                        'Scanning ${state.scanProgress}/${state.scanTotal}',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.devices.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final d = state.devices[index];
                    final isGateway = d.ip == wifi?.gatewayIp;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openDeviceActions(context, d.ip),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isGateway
                                    ? AppColors.teal
                                    : AppColors.navy,
                                child: Icon(
                                  isGateway
                                      ? Icons.router_rounded
                                      : Icons.devices_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.ip,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    Text(
                                      [
                                        if (isGateway) 'Gateway',
                                        if (d.latencyMs != null)
                                          '${d.latencyMs} ms',
                                        if (d.openPorts.isNotEmpty)
                                          'ports ${d.openPorts.join(", ")}',
                                        'Tap for actions',
                                      ].join(' · '),
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
