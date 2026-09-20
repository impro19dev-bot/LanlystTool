class SubnetInfo {
  const SubnetInfo({
    required this.network,
    required this.broadcast,
    required this.firstHost,
    required this.lastHost,
    required this.hostCount,
    required this.mask,
    required this.wildcard,
    required this.cidr,
  });

  final String network;
  final String broadcast;
  final String firstHost;
  final String lastHost;
  final int hostCount;
  final String mask;
  final String wildcard;
  final int cidr;
}

class SubnetCalculator {
  SubnetInfo? calculate(String ipCidr) {
    final trimmed = ipCidr.trim();
    final parts = trimmed.split('/');
    if (parts.length != 2) return null;

    final ip = _parseIp(parts[0]);
    final cidr = int.tryParse(parts[1]);
    if (ip == null || cidr == null || cidr < 0 || cidr > 32) return null;

    final maskInt = cidr == 0 ? 0 : (0xFFFFFFFF << (32 - cidr)) & 0xFFFFFFFF;
    final networkInt = ip & maskInt;
    final broadcastInt = networkInt | (~maskInt & 0xFFFFFFFF);
    final hostCount = cidr >= 31 ? (cidr == 32 ? 1 : 2) : (broadcastInt - networkInt - 1);
    final first = cidr >= 31 ? networkInt : networkInt + 1;
    final last = cidr >= 31 ? broadcastInt : broadcastInt - 1;

    return SubnetInfo(
      network: _fmt(networkInt),
      broadcast: _fmt(broadcastInt),
      firstHost: _fmt(first),
      lastHost: _fmt(last),
      hostCount: hostCount < 0 ? 0 : hostCount,
      mask: _fmt(maskInt),
      wildcard: _fmt(~maskInt & 0xFFFFFFFF),
      cidr: cidr,
    );
  }

  int? _parseIp(String s) {
    final p = s.split('.');
    if (p.length != 4) return null;
    var v = 0;
    for (final part in p) {
      final n = int.tryParse(part);
      if (n == null || n < 0 || n > 255) return null;
      v = (v << 8) | n;
    }
    return v;
  }

  String _fmt(int v) {
    return '${(v >> 24) & 0xFF}.${(v >> 16) & 0xFF}.${(v >> 8) & 0xFF}.${v & 0xFF}';
  }
}
