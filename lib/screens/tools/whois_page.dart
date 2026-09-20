import 'package:flutter/material.dart';

import '../../services/lookup_services.dart';
import '../../theme/app_colors.dart';

class WhoisPage extends StatefulWidget {
  const WhoisPage({super.key});

  @override
  State<WhoisPage> createState() => _WhoisPageState();
}

class _WhoisPageState extends State<WhoisPage> {
  final _domain = TextEditingController(text: 'example.com');
  final _service = WhoisService();
  WhoisResult? _result;
  bool _loading = false;

  @override
  void dispose() {
    _domain.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (_domain.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a domain')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _result = null;
    });
    final result = await _service.lookup(_domain.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Whois / RDAP')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _domain,
            decoration: const InputDecoration(
              labelText: 'Domain',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _run(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _run,
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            child: Text(_loading ? 'Looking up…' : 'Lookup'),
          ),
          const SizedBox(height: 16),
          if (_result?.error != null)
            Text(
              _result!.error!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          if (_result?.text != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: SelectableText(
                _result!.text!,
                style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
              ),
            ),
        ],
      ),
    );
  }
}
