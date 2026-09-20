class IpUtils {
  static final _v4 = RegExp(
    r'^(?:(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(?:25[0-5]|2[0-4]\d|[01]?\d\d?)$',
  );

  static bool isValidIpv4(String? value) {
    if (value == null) return false;
    return _v4.hasMatch(value.trim());
  }

  static bool looksLikeHost(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return false;
    if (isValidIpv4(v)) return true;
    // hostname: labels with dots, no spaces
    if (v.contains(' ') || v.length > 253) return false;
    return RegExp(r'^[A-Za-z0-9][A-Za-z0-9.\-]*[A-Za-z0-9]$').hasMatch(v) ||
        RegExp(r'^[A-Za-z0-9]+$').hasMatch(v);
  }

  static String? normalizeMac(String raw) {
    final cleaned = raw.trim().replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
    if (cleaned.length < 6) return null;
    final padded = cleaned.length >= 12
        ? cleaned.substring(0, 12)
        : cleaned.padRight(12, '0').substring(0, 12);
    final b = <String>[];
    for (var i = 0; i < 12; i += 2) {
      b.add(padded.substring(i, i + 2));
    }
    return b.join(':').toLowerCase();
  }
}
