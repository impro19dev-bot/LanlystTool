import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multiads/multiads.dart';

import '../theme/app_colors.dart';
import '../utils/global.dart';
import 'ads_config.dart';

/// Initializes [gAds] from the remote Drive config (with local fallback).
Future<void> bootstrapAds() async {
  if (gAdsReady) return;
  try {
    final json = await loadAdsConfigJson();
    gAds = MultiAds(
      json,
      config: MultiAdsConfig(
        enableLogs: kDebugMode,
        facebookiOSTrackingEnabled: false,
        admobTestDeviceIds: const [
          '79738754EC81FA5F64972928128B2FFF',
        ],
        facebookTestingId: 'd1a0df1f-2528-4e41-a4d3-1b401ba14f7d',
        admobNativeBackgroundColor: Colors.white,
        admobNativePrimaryColor: AppColors.navy,
        admobNativeSecondaryColor: AppColors.teal,
        admobNativeActionColor: AppColors.orange,
      ),
    );
    await gAds.init();
    await gAds.loadAds();
    gAdsReady = true;
  } catch (e, st) {
    gAdsReady = false;
    debugPrint('Ads bootstrap failed: $e\n$st');
  }
}
