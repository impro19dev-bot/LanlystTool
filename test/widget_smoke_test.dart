import 'package:fc_app3_wpswifianalyzer/screens/home_shell.dart';
import 'package:fc_app3_wpswifianalyzer/state/app_network_state.dart';
import 'package:fc_app3_wpswifianalyzer/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('tabs and tool buttons open real screens', (tester) async {
    final state = AppNetworkState();
    state.setManualScanIp('192.168.1.10');

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: HomeShell(state: state, autoRefreshWifi: false),
      ),
    );
    await tester.pump();

    expect(find.text('Lanlyst Tool'), findsOneWidget);

    await tester.tap(find.text('TOOLS'));
    await tester.pumpAndSettle();
    expect(find.text('Network utilities'), findsOneWidget);

    await tester.tap(find.text('Router risk snapshot'));
    await tester.pumpAndSettle();
    expect(find.text('Hardening guidance'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Speed Test'));
    await tester.pumpAndSettle();
    expect(find.text('Start test'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('DEVICES'));
    await tester.pumpAndSettle();
    expect(find.text('SCAN'), findsOneWidget);
    expect(find.textContaining('192.168.1.10'), findsOneWidget);

    await tester.tap(find.text('CHANNEL'));
    await tester.pumpAndSettle();
    expect(find.text('2.4 GHz'), findsOneWidget);
  });
}
