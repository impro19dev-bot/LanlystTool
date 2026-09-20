import 'package:flutter/material.dart';

import '../../services/lookup_services.dart';
import '../../theme/app_colors.dart';

class HttpHeadersPage extends StatefulWidget {
  const HttpHeadersPage({super.key});

  @override
  State<HttpHeadersPage> createState() => _HttpHeadersPageState();
}

class _HttpHeadersPageState extends State<HttpHeadersPage> {
  final _url = TextEditingController(text: 'https://example.com');
  final _service = HttpHeadersService();
  HttpHeadersResult? _result;
  bool _loading = false;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (_url.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a URL')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _result = null;
    });
    final result = await _service.fetch(_url.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final headers = _result?.headers.entries.toList() ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('HTTP Headers')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _url,
            decoration: const InputDecoration(
              labelText: 'URL',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _run(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _run,
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            child: Text(_loading ? 'Fetching…' : 'Fetch headers'),
          ),
          if (_result?.statusCode != null) ...[
            const SizedBox(height: 16),
            Text(
              'HTTP ${_result!.statusCode}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
          if (_result?.error != null) ...[
            const SizedBox(height: 12),
            Text(
              _result!.error!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
          const SizedBox(height: 8),
          ...headers.map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(e.value, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
