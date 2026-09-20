import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/network_models.dart';

class NetworkInfoService {
  NetworkInfoService({
    NetworkInfo? networkInfo,
    Connectivity? connectivity,
  })  : _info = networkInfo ?? NetworkInfo(),
        _connectivity = connectivity ?? Connectivity();

  final NetworkInfo _info;
  final Connectivity _connectivity;

  Future<bool> ensureLocationPermission() async {
    if (kIsWeb) return false;
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;
    status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<bool> isWifiConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }

  Future<WifiNetworkInfo> load() async {
    await ensureLocationPermission();

    final ssid = await _info.getWifiName();
    final bssid = await _info.getWifiBSSID();
    final wifiIp = await _info.getWifiIP();
    final subnet = await _info.getWifiSubmask();
    final gatewayIp = await _info.getWifiGatewayIP();
    final broadcast = await _info.getWifiBroadcast();

    String? cleanSsid = ssid;
    if (cleanSsid != null) {
      cleanSsid = cleanSsid.replaceAll('"', '');
      if (cleanSsid == '<unknown ssid>' || cleanSsid.isEmpty) {
        cleanSsid = null;
      }
    }

    return WifiNetworkInfo(
      ssid: cleanSsid,
      bssid: bssid,
      wifiIp: wifiIp,
      subnet: subnet,
      gatewayIp: gatewayIp,
      broadcast: broadcast,
    );
  }
}
