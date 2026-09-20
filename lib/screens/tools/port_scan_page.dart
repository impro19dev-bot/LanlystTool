import 'package:flutter/material.dart';

import '../../services/port_scan_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/ip_utils.dart';

class PortScanPage extends StatefulWidget {
  const PortScanPage({super.key, this.initialHost});

  final String? initialHost;

  @override
  State<PortScanPage> createState() => _PortScanPageState();
}

class _PortScanPageState extends State<PortScanPage> {
  late final TextEditingController _host;
  final _service = PortScanService();
  bool _running = false;
  bool _hasRun = false;
  int _done = 0;
  int _total = 0;
  List<PortScanResult> _open = [];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialHost?.trim();
    _host = TextEditingController(
      text: (initial != null && initial.isNotEmpty) ? initial : '1.1.1.1',
    );
  }

  @override
  void dispose() {
    _host.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final host = _host.text.trim();
    if (!IpUtils.looksLikeHost(host)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid host or IPv4 address')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _running = true;
      _hasRun = true;
      _open = [];
      _done = 0;
      _total = PortScanService.commonPorts.length;
    });
    final results = await _service.scan(
      host,
      onProgress: (d, t) {
        if (!mounted) return;
        setState(() {
          _done = d;
          _total = t;
        });
      },
    );
    if (!mounted) return;
    setState(() {
      _running = false;
      _open = results.where((r) => r.open).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Port Scan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Scans common TCP ports on a host you own or administer.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _host,
            decoration: const InputDecoration(
              labelText: 'Host / IP',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _run(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _running ? null : _run,
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            child: Text(
              _running ? 'Scanning $_done/$_total…' : 'Scan common ports',
            ),
          ),
          if (_running) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _total == 0 ? null : _done / _total,
              color: AppColors.navy,
            ),
          ],
          const SizedBox(height: 16),
          if (!_running && _hasRun && _open.isEmpty)
            const Text(
              'No open ports among the common set (or all filtered).',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ..._open.map(
            (r) => ListTile(
              leading: const Icon(Icons.lock_open, color: AppColors.teal),
              title: Text('Port ${r.port} open'),
              subtitle:
                  r.latencyMs != null ? Text('${r.latencyMs} ms') : null,
            ),
          ),
        ],
      ),
    );
  }
}
