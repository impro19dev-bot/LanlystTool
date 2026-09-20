import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class SpeedTestResult {
  const SpeedTestResult({
    required this.downloadMbps,
    required this.bytes,
    required this.elapsedMs,
    this.error,
  });

  final double downloadMbps;
  final int bytes;
  final int elapsedMs;
  final String? error;

  bool get success => error == null;
}

class SpeedTestService {
  /// Downloads a public sample file and estimates Mbps.
  Future<SpeedTestResult> runDownloadTest({
    Uri? url,
  }) async {
    final target = url ??
        Uri.parse(
          'https://speed.cloudflare.com/__down?bytes=2000000',
        );

    final sw = Stopwatch()..start();
    try {
      final response = await http.get(target).timeout(
            const Duration(seconds: 30),
          );
      sw.stop();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return SpeedTestResult(
          downloadMbps: 0,
          bytes: 0,
          elapsedMs: sw.elapsedMilliseconds,
          error: 'HTTP ${response.statusCode}',
        );
      }
      final bytes = response.bodyBytes.length;
      final seconds = sw.elapsedMilliseconds / 1000.0;
      final mbps = seconds > 0 ? (bytes * 8) / seconds / 1e6 : 0.0;
      return SpeedTestResult(
        downloadMbps: mbps,
        bytes: bytes,
        elapsedMs: sw.elapsedMilliseconds,
      );
    } on TimeoutException {
      sw.stop();
      return SpeedTestResult(
        downloadMbps: 0,
        bytes: 0,
        elapsedMs: sw.elapsedMilliseconds,
        error: 'Timed out',
      );
    } catch (e) {
      sw.stop();
      return SpeedTestResult(
        downloadMbps: 0,
        bytes: 0,
        elapsedMs: sw.elapsedMilliseconds,
        error: e.toString(),
      );
    }
  }

  // Keep analyzer happy if we later stream.
  Uint8List empty() => Uint8List(0);
}
