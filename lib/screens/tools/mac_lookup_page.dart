import 'package:flutter/material.dart';

import '../../services/lookup_services.dart';
import '../../theme/app_colors.dart';
import '../../utils/ip_utils.dart';

class MacLookupPage extends StatefulWidget {
  const MacLookupPage({super.key, this.initialMac});

  final String? initialMac;

  @override
  State<MacLookupPage> createState() => _MacLookupPageState();
}

class _MacLookupPageState extends State<MacLookupPage> {
  late final TextEditingController _mac;
  final _service = MacLookupService();
  MacVendorResult? _result;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialMac?.trim();
    _mac = TextEditingController(
      text: (initial != null && initial.isNotEmpty)
          ? initial
          : '00:1A:2B:3C:4D:5E',
    );
  }

  @override
  void dispose() {
    _mac.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (IpUtils.normalizeMac(_mac.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid MAC address')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _result = null;
    });
    final result = await _service.lookup(_mac.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MAC Vendor Lookup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _mac,
            decoration: const InputDecoration(
              labelText: 'MAC address',
              hintText: 'aa:bb:cc:dd:ee:ff',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _run(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _run,
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            child: Text(_loading ? 'Looking up…' : 'Lookup vendor'),
          ),
          const SizedBox(height: 16),
          if (_result?.success == true)
            ListTile(
              leading: const Icon(Icons.memory, color: AppColors.teal),
              title: Text(_result!.vendor!),
              subtitle: Text(_result!.mac),
            ),
          if (_result?.error != null)
            Text(
              _result!.error!,
              style: const TextStyle(color: Colors.redAccent),
            ),
        ],
      ),
    );
  }
}
