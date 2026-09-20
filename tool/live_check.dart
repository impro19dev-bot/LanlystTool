import 'package:fc_app3_wpswifianalyzer/services/dns_service.dart';
import 'package:fc_app3_wpswifianalyzer/services/lookup_services.dart';
import 'package:fc_app3_wpswifianalyzer/services/ping_service.dart';
import 'package:fc_app3_wpswifianalyzer/services/subnet_calculator.dart';

Future<void> main() async {
  final dns = await DnsService().lookup('apple.com');
  print('DNS: ${dns.success} ${dns.addresses}');
  final ping = await PingService().ping('1.1.1.1', port: 443);
  print('PING: ${ping.success} ${ping.latencyMs}ms err=${ping.error}');
  final whois = await WhoisService().lookup('example.com');
  print('WHOIS: ${whois.success} len=${whois.text?.length} err=${whois.error}');
  final headers = await HttpHeadersService().fetch('https://example.com');
  print(
    'HEADERS: ${headers.success} ${headers.statusCode} count=${headers.headers.length}',
  );
  final mac = await MacLookupService().lookup('00:50:56:00:00:01');
  print('MAC: ${mac.success} vendor=${mac.vendor} err=${mac.error}');
  final sub = SubnetCalculator().calculate('10.0.0.5/24');
  print('SUBNET: ${sub?.network} hosts=${sub?.hostCount}');
}
