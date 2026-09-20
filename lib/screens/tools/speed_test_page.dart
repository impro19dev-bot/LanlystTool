import 'package:flutter/material.dart';

import '../../services/speed_test_service.dart';
import '../../theme/app_colors.dart';

class SpeedTestPage extends StatefulWidget {
  const SpeedTestPage({super.key});

  @override
  State<SpeedTestPage> createState() => _SpeedTestPageState();
}

class _SpeedTestPageState extends State<SpeedTestPage> {
  final _service = SpeedTestService();
  bool _running = false;
  SpeedTestResult? _result;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _result = null;
    });
    final result = await _service.runDownloadTest();
    if (!mounted) return;
    setState(() {
      _running = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speed Test')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Measures a short HTTPS download to estimate download Mbps. '
              'Results vary with CDN path and Wi-Fi conditions.',
              style: TextStyle(color: AppColors.textMuted, height: 1.35),
            ),
            const Spacer(),
            if (_running)
              const CircularProgressIndicator(color: AppColors.navy)
            else if (_result != null && _result!.success)
              Column(
                children: [
                  Text(
                    _result!.downloadMbps.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                  const Text(
                    'Mbps down',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_result!.bytes / 1e6).toStringAsFixed(2)} MB in ${_result!.elapsedMs} ms',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              )
            else if (_result?.error != null)
              Text(
                _result!.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              )
            else
              const Icon(Icons.speed, size: 72, color: AppColors.watermark),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _running ? null : _run,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_running ? 'Testing…' : 'Start test'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
