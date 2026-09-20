import 'package:flutter/material.dart';

import '../../state/app_network_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/info_card.dart';
import '../../widgets/status_strip.dart';
import '../../widgets/wps_watermark.dart';

class ChannelTab extends StatefulWidget {
  const ChannelTab({super.key, required this.state});

  final AppNetworkState state;

  @override
  State<ChannelTab> createState() => _ChannelTabState();
}

class _ChannelTabState extends State<ChannelTab> {
  bool _is24 = true;

  @override
  Widget build(BuildContext context) {
    final hasWifi = widget.state.wifi?.hasWifi ?? false;

    return Column(
      children: [
        StatusStrip(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _bandChip(
                    label: '2.4 GHz',
                    selected: _is24,
                    onTap: () => setState(() => _is24 = true),
                  ),
                  const SizedBox(width: 8),
                  _bandChip(
                    label: '5 GHz',
                    selected: !_is24,
                    onTap: () => setState(() => _is24 = false),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                hasWifi
                    ? (widget.state.wifi?.ssid ?? 'Connected')
                    : 'Not connected — load NETWORK tab',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Channel / congestion data requires your router admin UI or Apple Wireless Diagnostics on Mac — not exposed here.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              const WpsWatermark(opacity: 0.22),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_is24) ...[
                    InfoCard(
                      title: '2.4 GHz reference channels (1–14)',
                      child: Text(
                        'Typical home routers use channels 1, 6, or 11 to reduce overlap. '
                        'Check your router gateway settings to see the active channel and switch if neighbors congest yours.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InfoCard(
                      title: 'Reduce interference (checklist)',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _Bullet(
                            'Pick a fixed channel or reliable auto-channel on the router.',
                          ),
                          _Bullet(
                            'Avoid overlapping 2.4 GHz networks on the same channel.',
                          ),
                          _Bullet(
                            'Prefer wired Ethernet for stationary devices when possible.',
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    InfoCard(
                      title: '5 GHz reference',
                      child: Text(
                        '5 GHz offers more non-overlapping channels and usually less interference, '
                        'with shorter range than 2.4 GHz. Prefer WPA2/WPA3 and keep firmware updated.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InfoCard(
                      title: '5 GHz tips',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _Bullet(
                            'Place the router centrally and elevated for better coverage.',
                          ),
                          _Bullet(
                            'Use separate SSIDs for 2.4 / 5 GHz if devices stick to a slow band.',
                          ),
                          _Bullet(
                            'Prefer WPA2/WPA3 and keep firmware updated. Turn off extra setup features you do not use.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bandChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.navy : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
