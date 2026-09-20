import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../state/app_network_state.dart';
import '../../theme/app_colors.dart';
import '../../utils/ip_utils.dart';
import '../../widgets/info_card.dart';

class RouterSetupAssistantPage extends StatefulWidget {
  const RouterSetupAssistantPage({super.key, required this.state});

  final AppNetworkState state;

  @override
  State<RouterSetupAssistantPage> createState() =>
      _RouterSetupAssistantPageState();
}

class _RouterSetupAssistantPageState extends State<RouterSetupAssistantPage> {
  late final TextEditingController _gateway;

  @override
  void initState() {
    super.initState();
    _gateway = TextEditingController(
      text: widget.state.wifi?.gatewayIp ?? '192.168.1.1',
    );
  }

  @override
  void dispose() {
    _gateway.dispose();
    super.dispose();
  }

  Future<void> _openGateway() async {
    final gw = _gateway.text.trim();
    if (!IpUtils.isValidIpv4(gw)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid gateway IPv4 address')),
      );
      return;
    }
    final uri = Uri.parse('http://$gw');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $uri')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open router admin: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Router Quick Setup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoCard(
            title: 'Gateway address',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _gateway,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Router IP',
                    border: OutlineInputBorder(),
                    hintText: '192.168.1.1',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _openGateway,
                  style:
                      FilledButton.styleFrom(backgroundColor: AppColors.navy),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open router admin'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InfoCard(
            title: 'Suggested steps',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Step(
                  '1',
                  'Sign in with your admin credentials (not the Wi-Fi password).',
                ),
                _Step('2', 'Find Wireless / Wi-Fi → WPS and turn it Off.'),
                _Step(
                  '3',
                  'Set security to WPA2-Personal (AES) or WPA3-Personal.',
                ),
                _Step('4', 'Change the default admin password.'),
                _Step('5', 'Check for firmware updates and reboot if needed.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.n, this.text);

  final String n;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.navy,
            child: Text(
              n,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
