import 'dart:async';
import 'dart:io';

class PortScanResult {
  const PortScanResult({
    required this.port,
    required this.open,
    this.latencyMs,
  });

  final int port;
  final bool open;
  final int? latencyMs;
}

class PortScanService {
  static const commonPorts = [
    21, 22, 23, 25, 53, 80, 110, 143, 443, 445, 548, 993, 995,
    3306, 3389, 5432, 5900, 8080, 8443,
  ];

  Future<List<PortScanResult>> scan(
    String host, {
    List<int>? ports,
    Duration timeout = const Duration(milliseconds: 800),
    void Function(int done, int total)? onProgress,
  }) async {
    final list = ports ?? commonPorts;
    final results = <PortScanResult>[];

    for (var i = 0; i < list.length; i++) {
      final port = list[i];
      results.add(await _check(host, port, timeout));
      onProgress?.call(i + 1, list.length);
    }
    return results;
  }

  Future<PortScanResult> _check(
    String host,
    int port,
    Duration timeout,
  ) async {
    final sw = Stopwatch()..start();
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      sw.stop();
      await socket.close();
      return PortScanResult(
        port: port,
        open: true,
        latencyMs: sw.elapsedMilliseconds,
      );
    } catch (_) {
      sw.stop();
      return PortScanResult(port: port, open: false);
    }
  }
}
