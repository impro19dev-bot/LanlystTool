import 'package:flutter/material.dart';

import '../../state/app_network_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/section_header.dart';
import '../../widgets/tool_list_tile.dart';
import '../tools/dns_lookup_page.dart';
import '../tools/http_headers_page.dart';
import '../tools/mac_lookup_page.dart';
import '../tools/ping_page.dart';
import '../tools/port_scan_page.dart';
import '../tools/speed_test_page.dart';
import '../tools/subnet_calc_page.dart';
import '../tools/whois_page.dart';
import '../wps/router_setup_assistant_page.dart';
import '../wps/wps_risk_snapshot_page.dart';
import '../wps/wps_security_center_page.dart';

class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key, required this.state});

  final AppNetworkState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
      children: [
        const SectionHeader(
          icon: Icons.security,
          title: 'Router security',
        ),
        const SizedBox(height: 12),
        ToolListTile(
          icon: Icons.bar_chart,
          iconColor: AppColors.orange,
          title: 'Router risk snapshot',
          subtitle: 'Current Wi-Fi and hardening guidance',
          onTap: () => _open(context, WpsRiskSnapshotPage(state: state)),
        ),
        const SizedBox(height: 10),
        ToolListTile(
          icon: Icons.shield,
          iconColor: AppColors.navy,
          title: 'Security checklist',
          subtitle: 'Harden your router step by step',
          onTap: () => _open(context, const WpsSecurityCenterPage()),
        ),
        const SizedBox(height: 10),
        ToolListTile(
          icon: Icons.router,
          iconColor: AppColors.teal,
          title: 'Router Quick Setup Assistant',
          subtitle: 'Gateway, WPA2/WPA3, admin password',
          onTap: () => _open(context, RouterSetupAssistantPage(state: state)),
        ),
        const SizedBox(height: 22),
        const SectionHeader(
          icon: Icons.handyman_outlined,
          title: 'Network utilities',
        ),
        const SizedBox(height: 6),
        const Text(
          'Use only on networks you own or have permission to test.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 14),
        ToolListTile(
          icon: Icons.speed,
          iconColor: AppColors.teal,
          title: 'Speed Test',
          subtitle: 'Estimate download throughput',
          onTap: () => _open(context, const SpeedTestPage()),
        ),
        const SizedBox(height: 10),
        ToolListTile(
          icon: Icons.network_ping,
          iconColor: AppColors.navy,
          title: 'Ping Host',
          subtitle: 'TCP reachability & latency',
          onTap: () => _open(
            context,
            PingPage(initialHost: state.wifi?.gatewayIp ?? '1.1.1.1'),
          ),
        ),
        const SizedBox(height: 10),
        ToolListTile(
          icon: Icons.radar,
          iconColor: AppColors.orange,
          title: 'Port Scan',
          subtitle: 'Common ports on a host you administer',
          onTap: () => _open(
            context,
            PortScanPage(initialHost: state.wifi?.gatewayIp ?? '1.1.1.1'),
          ),
        ),
        const SizedBox(height: 10),
        ToolListTile(
          icon: Icons.dns,
          iconColor: const Color(0xFF5B6EE1),
          title: 'DNS Lookup',
          subtitle: 'Resolve hostnames to IP addresses',
          onTap: () => _open(context, const DnsLookupPage()),
        ),
        const SizedBox(height: 10),
        ToolListTile(
          icon: Icons.grid_on,
          iconColor: const Color(0xFF8E44AD),
          title: 'Subnet Calculator',
          subtitle: 'CIDR network, hosts, broadcast',
          onTap: () => _open(
            context,
            SubnetCalcPage(
              initial: state.wifi?.wifiIp != null
                  ? '${state.wifi!.wifiIp}/24'
                  : '192.168.1.0/24',
            ),
          ),
        ),
        const SizedBox(height: 10),
        ToolListTile(
          icon: Icons.memory,
          iconColor: const Color(0xFF16A085),
          title: 'MAC Vendor Lookup',
          subtitle: 'Identify manufacturer from MAC / OUI',
          onTap: () => _open(
            context,
            MacLookupPage(initialMac: state.wifi?.bssid),
          ),
        ),
        const SizedBox(height: 10),
        ToolListTile(
          icon: Icons.http,
          iconColor: const Color(0xFFC0392B),
          title: 'HTTP Headers',
          subtitle: 'Inspect response headers for a URL',
          onTap: () => _open(context, const HttpHeadersPage()),
        ),
        const SizedBox(height: 10),
        ToolListTile(
          icon: Icons.public,
          iconColor: const Color(0xFF2C3E50),
          title: 'Whois / RDAP',
          subtitle: 'Domain registration lookup',
          onTap: () => _open(context, const WhoisPage()),
        ),
      ],
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }
}
