class WifiNetworkInfo {
  const WifiNetworkInfo({
    this.ssid,
    this.bssid,
    this.wifiIp,
    this.subnet,
    this.gatewayIp,
    this.broadcast,
  });

  final String? ssid;
  final String? bssid;
  final String? wifiIp;
  final String? subnet;
  final String? gatewayIp;
  final String? broadcast;

  bool get hasWifi => wifiIp != null && wifiIp!.isNotEmpty;

  String get displayName {
    if (ssid != null && ssid!.isNotEmpty) return ssid!;
    return 'Unknown network';
  }
}

class LanDevice {
  const LanDevice({
    required this.ip,
    this.openPorts = const [],
    this.latencyMs,
  });

  final String ip;
  final List<int> openPorts;
  final int? latencyMs;
}
