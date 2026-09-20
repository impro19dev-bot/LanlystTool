import 'package:flutter/material.dart';

import '../../services/ping_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/ip_utils.dart';

class PingPage extends StatefulWidget {
  const PingPage({super.key, this.initialHost});

  final String? initialHost;

  @override
  State<PingPage> createState() => _PingPageState();
}

class _PingPageState extends State<PingPage> {
  late final TextEditingController _host;
  final _port = TextEditingController(text: '443');
  final _service = PingService();
  bool _running = false;
  List<PingResult> _results = [];

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
    _port.dispose();
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
    final port = int.tryParse(_port.text.trim());
    if (port == null || port < 1 || port > 65535) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Port must be 1–65535')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _running = true;
      _results = [];
    });
    final results = await _service.pingSeries(host, port: port);
    if (!mounted) return;
    setState(() {
      _running = false;
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ok = _results.where((r) => r.success).toList();
    final avg = ok.isEmpty
        ? null
        : ok.map((r) => r.latencyMs!).reduce((a, b) => a + b) / ok.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Ping Host')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'TCP connect timing (iOS-safe). Enter host and destination port.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _host,
            decoration: const InputDecoration(
              labelText: 'Host',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _port,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Port',
              helperText: 'Try 443 for HTTPS hosts, 80 for HTTP',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _run(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _running ? null : _run,
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            child: Text(_running ? 'Pinging…' : 'Ping ×4'),
          ),
          if (avg != null) ...[
            const SizedBox(height: 16),
            Text(
              'Avg ${avg.toStringAsFixed(0)} ms · ${ok.length}/${_results.length} ok',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 12),
          ..._results.asMap().entries.map((e) {
            final r = e.value;
            return ListTile(
              dense: true,
              leading: Icon(
                r.success ? Icons.check_circle : Icons.cancel,
                color: r.success ? Colors.green : Colors.redAccent,
              ),
              title: Text(
                r.success ? 'Reply ${r.latencyMs} ms' : (r.error ?? 'Failed'),
              ),
              subtitle: Text('#${e.key + 1} → ${_host.text.trim()}'),
            );
          }),
        ],
      ),
    );
  }
}
