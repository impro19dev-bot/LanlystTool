import 'package:fc_app3_wpswifianalyzer/services/subnet_calculator.dart';
import 'package:fc_app3_wpswifianalyzer/utils/ip_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IpUtils', () {
    test('validates IPv4', () {
      expect(IpUtils.isValidIpv4('192.168.1.1'), isTrue);
      expect(IpUtils.isValidIpv4('10.0.0.255'), isTrue);
      expect(IpUtils.isValidIpv4('256.1.1.1'), isFalse);
      expect(IpUtils.isValidIpv4('abc'), isFalse);
    });

    test('normalizes MAC', () {
      expect(IpUtils.normalizeMac('AA-BB-CC-DD-EE-FF'), 'aa:bb:cc:dd:ee:ff');
      expect(IpUtils.normalizeMac('aabbcc'), isNotNull);
      expect(IpUtils.normalizeMac('zz'), isNull);
    });
  });

  group('SubnetCalculator', () {
    test('calculates /24', () {
      final info = SubnetCalculator().calculate('192.168.1.50/24');
      expect(info, isNotNull);
      expect(info!.network, '192.168.1.0');
      expect(info.broadcast, '192.168.1.255');
      expect(info.firstHost, '192.168.1.1');
      expect(info.lastHost, '192.168.1.254');
      expect(info.hostCount, 254);
    });
  });
}
