import 'dart:async';
import 'dart:io';

class PingResult {
  const PingResult({
    required this.host,
    required this.success,
    this.latencyMs,
    this.error,
  });

  final String host;
  final bool success;
  final int? latencyMs;
  final String? error;
}

/// TCP-based reachability check (iOS-safe alternative to ICMP ping).
class PingService {
  Future<PingResult> ping(
    String host, {
    int port = 80,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final sw = Stopwatch()..start();
    try {
      final addresses = await InternetAddress.lookup(host);
      if (addresses.isEmpty) {
        return PingResult(host: host, success: false, error: 'No address');
      }
      final socket = await Socket.connect(
        addresses.first,
        port,
        timeout: timeout,
      );
      sw.stop();
      await socket.close();
      return PingResult(
        host: host,
        success: true,
        latencyMs: sw.elapsedMilliseconds,
      );
    } on SocketException catch (e) {
      sw.stop();
      return PingResult(host: host, success: false, error: e.message);
    } on TimeoutException {
      sw.stop();
      return PingResult(host: host, success: false, error: 'Timed out');
    } catch (e) {
      sw.stop();
      return PingResult(host: host, success: false, error: e.toString());
    }
  }

  Future<List<PingResult>> pingSeries(
    String host, {
    int count = 4,
    int port = 80,
  }) async {
    final results = <PingResult>[];
    for (var i = 0; i < count; i++) {
      results.add(await ping(host, port: port));
      if (i < count - 1) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    }
    return results;
  }
}
