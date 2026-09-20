import 'dart:async';
import 'dart:io';

import '../models/network_models.dart';

/// Discovers reachable hosts on the local /24 via TCP probes.
/// Uses common ports — ICMP is restricted on iOS App Store builds.
class DeviceScanService {
  static const _probePorts = [80, 443, 22, 8080, 53, 445, 139, 548];

  Future<List<LanDevice>> scanSubnet(
    String localIp, {
    void Function(int scanned, int total)? onProgress,
    Duration timeout = const Duration(milliseconds: 350),
    int concurrency = 32,
  }) async {
    final parts = localIp.split('.');
    if (parts.length != 4) return [];

    final prefix = '${parts[0]}.${parts[1]}.${parts[2]}';
    final hosts = <String>[];
    for (var i = 1; i <= 254; i++) {
      hosts.add('$prefix.$i');
    }

    final found = <LanDevice>[];
    var scanned = 0;

    for (var i = 0; i < hosts.length; i += concurrency) {
      final batch = hosts.skip(i).take(concurrency);
      final results = await Future.wait(
        batch.map((ip) => _probeHost(ip, timeout)),
      );
      for (final device in results) {
        if (device != null) found.add(device);
      }
      scanned = (i + batch.length).clamp(0, hosts.length);
      onProgress?.call(scanned, hosts.length);
    }

    found.sort((a, b) => _ipKey(a.ip).compareTo(_ipKey(b.ip)));
    return found;
  }

  Future<LanDevice?> _probeHost(String ip, Duration timeout) async {
    final open = <int>[];
    int? bestLatency;

    for (final port in _probePorts) {
      final sw = Stopwatch()..start();
      try {
        final socket = await Socket.connect(ip, port, timeout: timeout);
        sw.stop();
        await socket.close();
        open.add(port);
        bestLatency ??= sw.elapsedMilliseconds;
      } on SocketException {
        // closed / filtered
      } on TimeoutException {
        // ignore
      } catch (_) {
        // ignore
      }
    }

    if (open.isEmpty) return null;
    return LanDevice(ip: ip, openPorts: open, latencyMs: bestLatency);
  }

  int _ipKey(String ip) {
    final p = ip.split('.').map(int.parse).toList();
    return (p[0] << 24) | (p[1] << 16) | (p[2] << 8) | p[3];
  }
}
