import 'package:flutter/material.dart';

import '../../services/dns_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/ip_utils.dart';

class DnsLookupPage extends StatefulWidget {
  const DnsLookupPage({super.key});

  @override
  State<DnsLookupPage> createState() => _DnsLookupPageState();
}

class _DnsLookupPageState extends State<DnsLookupPage> {
  final _host = TextEditingController(text: 'apple.com');
  final _service = DnsService();
  DnsLookupResult? _result;
  bool _loading = false;

  @override
  void dispose() {
    _host.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final host = _host.text.trim();
    if (!IpUtils.looksLikeHost(host)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a hostname or IP')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _result = null;
    });
    final result = await _service.lookup(host);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DNS Lookup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _host,
            decoration: const InputDecoration(
              labelText: 'Hostname',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _run(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _run,
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            child: Text(_loading ? 'Looking up…' : 'Resolve'),
          ),
          const SizedBox(height: 16),
          if (_result?.error != null)
            Text(
              _result!.error!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ...?_result?.addresses.map(
            (a) => ListTile(
              leading: const Icon(Icons.dns, color: AppColors.navy),
              title: Text(a),
              subtitle: Text(_result!.host),
            ),
          ),
        ],
      ),
    );
  }
}
