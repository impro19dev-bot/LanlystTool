import 'package:flutter/foundation.dart';

import '../models/network_models.dart';
import '../services/device_scan_service.dart';
import '../services/network_info_service.dart';
import '../utils/ip_utils.dart';

class AppNetworkState extends ChangeNotifier {
  AppNetworkState({
    NetworkInfoService? networkInfoService,
    DeviceScanService? deviceScanService,
  })  : _networkInfo = networkInfoService ?? NetworkInfoService(),
        _deviceScan = deviceScanService ?? DeviceScanService();

  final NetworkInfoService _networkInfo;
  final DeviceScanService _deviceScan;

  WifiNetworkInfo? wifi;
  String? loadError;
  bool loadingWifi = false;
  bool showWpsTips = true;

  /// Manual override when iOS/simulator cannot expose Wi-Fi details.
  String? manualScanIp;

  List<LanDevice> devices = [];
  bool scanningDevices = false;
  String? scanError;
  int scanProgress = 0;
  int scanTotal = 0;

  String? get effectiveScanIp {
    if (manualScanIp != null && IpUtils.isValidIpv4(manualScanIp)) {
      return manualScanIp;
    }
    final ip = wifi?.wifiIp;
    if (IpUtils.isValidIpv4(ip)) return ip;
    return null;
  }

  bool get canScan => effectiveScanIp != null && !scanningDevices;

  Future<void> refreshWifi() async {
    loadingWifi = true;
    loadError = null;
    notifyListeners();
    try {
      final onWifi = await _networkInfo
          .isWifiConnected()
          .timeout(const Duration(seconds: 4), onTimeout: () => false);
      wifi = await _networkInfo
          .load()
          .timeout(const Duration(seconds: 6));
      if (!onWifi && !(wifi?.hasWifi ?? false)) {
        loadError =
            'Could not read your Wi-Fi name. Connect to Wi-Fi (not cellular only), ensure Location is allowed, and on a real device try Settings → Privacy → Location Services → Lanlyst Tool.';
      } else if (wifi?.ssid == null) {
        loadError =
            'Could not read your Wi-Fi name. Connect to Wi-Fi (not cellular only), ensure Location is allowed, and on a real device try Settings → Privacy → Location Services → Lanlyst Tool.';
      }
    } catch (e) {
      loadError = e.toString();
    } finally {
      loadingWifi = false;
      notifyListeners();
    }
  }

  void setShowWpsTips(bool value) {
    showWpsTips = value;
    notifyListeners();
  }

  void setManualScanIp(String? ip) {
    final trimmed = ip?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      manualScanIp = null;
    } else if (IpUtils.isValidIpv4(trimmed)) {
      manualScanIp = trimmed;
      // Seed a lightweight wifi object so other screens have an IP/gateway hint.
      final parts = trimmed.split('.');
      final gatewayGuess = '${parts[0]}.${parts[1]}.${parts[2]}.1';
      wifi = WifiNetworkInfo(
        ssid: wifi?.ssid ?? 'Manual network',
        bssid: wifi?.bssid,
        wifiIp: trimmed,
        subnet: wifi?.subnet ?? '255.255.255.0',
        gatewayIp: wifi?.gatewayIp ?? gatewayGuess,
        broadcast: wifi?.broadcast,
      );
      loadError = null;
    }
    notifyListeners();
  }

  Future<bool> scanDevices() async {
    final ip = effectiveScanIp;
    if (ip == null) {
      scanError = 'Set a local IP first (NETWORK tab or Enter IP).';
      notifyListeners();
      return false;
    }

    scanningDevices = true;
    scanError = null;
    devices = [];
    scanProgress = 0;
    scanTotal = 254;
    notifyListeners();

    try {
      devices = await _deviceScan.scanSubnet(
        ip,
        onProgress: (done, total) {
          scanProgress = done;
          scanTotal = total;
          notifyListeners();
        },
      );
      if (devices.isEmpty) {
        scanError =
            'No reachable hosts on ${ip.split('.').take(3).join('.')}.0/24. '
            'Try another local IP, or run on a real device on Wi-Fi.';
      }
      return true;
    } catch (e) {
      scanError = e.toString();
      return false;
    } finally {
      scanningDevices = false;
      notifyListeners();
    }
  }
}
