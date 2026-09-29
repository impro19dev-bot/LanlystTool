import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../utils/global.dart';

/// Shows App Open ads without blocking navigation or core features.
///
/// - Cold start: [showOnColdStartIfReady] after splash (skips if not loaded).
/// - Resume: [AppOpenLifecycleObserver] after the app was backgrounded briefly.
class AppOpenAdService {
  AppOpenAdService._();

  static DateTime? _lastShownAt;
  static bool _coldStartAttempted = false;

  /// Minimum time between App Open impressions (resume spam guard).
  static const Duration minInterval = Duration(seconds: 60);

  /// How long the app must have been backgrounded before a resume ad.
  static const Duration minBackground = Duration(seconds: 30);

  static bool get isConfigured =>
      gAdsReady && gAds.hasAppOpen;

  static bool get _intervalOk {
    final last = _lastShownAt;
    if (last == null) return true;
    return DateTime.now().difference(last) >= minInterval;
  }

  /// Shows an App Open ad once after splash if ads are ready.
  /// Never throws; never delays the splash beyond a no-op call.
  static Future<void> showOnColdStartIfReady() async {
    if (_coldStartAttempted) return;
    _coldStartAttempted = true;
    _tryShow(reason: 'cold_start');
  }

  static void showOnResumeIfEligible() {
    _tryShow(reason: 'resume');
  }

  static void _tryShow({required String reason}) {
    if (!isConfigured || !_intervalOk) return;
    try {
      gAds.openAdsInstance.showAdIfAvailableOpenAds();
      // Record attempt time to avoid rapid re-shows; multiads reloads after dismiss.
      _lastShownAt = DateTime.now();
      if (kDebugMode) {
        debugPrint('App Open show attempted ($reason)');
      }
    } catch (e, st) {
      debugPrint('App Open skipped ($reason): $e\n$st');
    }
  }
}

/// Listens for app resume and optionally shows an App Open ad.
class AppOpenLifecycleObserver extends StatefulWidget {
  const AppOpenLifecycleObserver({super.key, required this.child});

  final Widget child;

  @override
  State<AppOpenLifecycleObserver> createState() =>
      _AppOpenLifecycleObserverState();
}

class _AppOpenLifecycleObserverState extends State<AppOpenLifecycleObserver>
    with WidgetsBindingObserver {
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _pausedAt = DateTime.now();
      case AppLifecycleState.resumed:
        final pausedAt = _pausedAt;
        _pausedAt = null;
        if (pausedAt == null) return;
        if (DateTime.now().difference(pausedAt) <
            AppOpenAdService.minBackground) {
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppOpenAdService.showOnResumeIfEligible();
        });
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
