import 'package:flutter/material.dart';

import 'ads/ads_bootstrap.dart';
import 'ads/app_open_ad_service.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ads init failures never prevent launch (handled inside bootstrapAds).
  await bootstrapAds();
  runApp(const WpsApp());
}

class WpsApp extends StatelessWidget {
  const WpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppOpenLifecycleObserver(
      child: MaterialApp(
        title: 'WPSApp: WiFi Analyzer & Scanner',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
