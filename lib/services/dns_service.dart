import 'dart:io';

class DnsLookupResult {
  const DnsLookupResult({
    required this.host,
    required this.addresses,
    this.error,
  });

  final String host;
  final List<String> addresses;
  final String? error;

  bool get success => error == null && addresses.isNotEmpty;
}

class DnsService {
  Future<DnsLookupResult> lookup(String host) async {
    try {
      final list = await InternetAddress.lookup(host);
      return DnsLookupResult(
        host: host,
        addresses: list.map((a) => a.address).toList(),
      );
    } catch (e) {
      return DnsLookupResult(
        host: host,
        addresses: const [],
        error: e.toString(),
      );
    }
  }
}
