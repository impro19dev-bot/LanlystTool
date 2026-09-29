import 'package:flutter/foundation.dart';
import 'package:multiads/multiads.dart';

import '../utils/global.dart';

/// Shows a rewarded or interstitial ad, then always runs [action].
///
/// If ads are unavailable or fail, [action] still runs so core UX is never blocked.
abstract final class FullscreenAdGate {
  /// Rewarded ad, then [action] (also if ad missing / failed).
  static void withRewarded(VoidCallback action) {
    if (!gAdsReady || !gAds.hasRewarded) {
      action();
      return;
    }
    try {
      gAds.rewardInstance.showRewardAd(action);
    } catch (e, st) {
      debugPrint('Rewarded ad skipped: $e\n$st');
      action();
    }
  }

  /// Interstitial ad, then [action] on dismiss (or immediately if not loaded).
  static void withInterstitial(VoidCallback action) {
    if (!gAdsReady || !gAds.hasInterstitials) {
      action();
      return;
    }
    try {
      AdCallbacks.onInterstitialDismissed = () {
        AdCallbacks.onInterstitialDismissed = null;
        action();
      };
      gAds.interInstance.showInterstitialAd();
    } catch (e, st) {
      debugPrint('Interstitial ad skipped: $e\n$st');
      AdCallbacks.onInterstitialDismissed = null;
      action();
    }
  }
}
