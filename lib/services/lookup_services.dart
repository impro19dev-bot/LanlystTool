import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/ip_utils.dart';

class MacVendorResult {
  const MacVendorResult({
    required this.mac,
    this.vendor,
    this.error,
  });

  final String mac;
  final String? vendor;
  final String? error;

  bool get success => vendor != null && error == null;
}

class MacLookupService {
  static const _headers = {
    'User-Agent': 'LanlystTool/1.0 (iOS; Flutter)',
    'Accept': 'application/json, text/plain',
  };

  Future<MacVendorResult> lookup(String mac) async {
    final normalized = IpUtils.normalizeMac(mac);
    if (normalized == null) {
      return MacVendorResult(mac: mac, error: 'Enter a valid MAC address');
    }

    // Primary: maclookup.app (JSON)
    try {
      final uri = Uri.parse(
        'https://api.maclookup.app/v2/macs/${normalized.replaceAll(':', '')}',
      );
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map && body['found'] == true) {
          final company = (body['company'] ?? body['vendor'] ?? '').toString();
          if (company.isNotEmpty) {
            return MacVendorResult(mac: normalized, vendor: company);
          }
        }
        if (body is Map && body['found'] == false) {
          return MacVendorResult(mac: normalized, error: 'Vendor not found');
        }
      }
    } catch (_) {
      // fall through
    }

    // Fallback: macvendors.com
    try {
      final uri = Uri.parse('https://api.macvendors.com/$normalized');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        return MacVendorResult(mac: normalized, vendor: response.body.trim());
      }
      if (response.statusCode == 404) {
        return MacVendorResult(mac: normalized, error: 'Vendor not found');
      }
      return MacVendorResult(
        mac: normalized,
        error: 'Lookup failed (${response.statusCode})',
      );
    } catch (e) {
      return MacVendorResult(mac: normalized, error: e.toString());
    }
  }
}

class HttpHeadersResult {
  const HttpHeadersResult({
    required this.url,
    this.statusCode,
    this.headers = const {},
    this.error,
  });

  final String url;
  final int? statusCode;
  final Map<String, String> headers;
  final String? error;

  bool get success => error == null && statusCode != null;
}

class HttpHeadersService {
  Future<HttpHeadersResult> fetch(String rawUrl) async {
    var url = rawUrl.trim();
    if (url.isEmpty) {
      return const HttpHeadersResult(url: '', error: 'Enter a URL');
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAuthority) {
      return HttpHeadersResult(url: url, error: 'Invalid URL');
    }
    try {
      http.Response response;
      try {
        response = await http.head(uri).timeout(const Duration(seconds: 12));
        if (response.statusCode >= 400 || response.headers.isEmpty) {
          response = await http.get(uri).timeout(const Duration(seconds: 12));
        }
      } catch (_) {
        response = await http.get(uri).timeout(const Duration(seconds: 12));
      }
      return HttpHeadersResult(
        url: url,
        statusCode: response.statusCode,
        headers: Map<String, String>.from(response.headers),
      );
    } catch (e) {
      return HttpHeadersResult(url: url, error: e.toString());
    }
  }
}

class WhoisResult {
  const WhoisResult({
    required this.query,
    this.text,
    this.error,
  });

  final String query;
  final String? text;
  final String? error;

  bool get success => text != null && error == null;
}

class WhoisService {
  /// Uses public RDAP endpoints for domain registration data.
  Future<WhoisResult> lookup(String domain) async {
    final q = domain.trim().toLowerCase().replaceAll(RegExp(r'^https?://'), '');
    final host = q.split('/').first.replaceAll(RegExp(r'\.$'), '');
    if (host.isEmpty || !host.contains('.')) {
      return WhoisResult(query: domain, error: 'Enter a domain like example.com');
    }

    final endpoints = [
      Uri.parse('https://rdap.org/domain/$host'),
      Uri.parse('https://rdap.verisign.com/com/v1/domain/$host'),
    ];

    Object? lastError;
    for (final uri in endpoints) {
      try {
        final response = await http.get(
          uri,
          headers: {
            'Accept': 'application/rdap+json, application/json',
            'User-Agent': 'LanlystTool/1.0',
          },
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
          return WhoisResult(query: host, text: pretty);
        }
        lastError = 'HTTP ${response.statusCode}';
      } catch (e) {
        lastError = e;
      }
    }

    return WhoisResult(
      query: host,
      error: 'RDAP lookup failed (${lastError ?? 'unknown'})',
    );
  }
}
