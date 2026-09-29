import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Remote MultiAds JSON (Google Drive direct download).
const kAdsConfigUrl =
    'https://drive.google.com/uc?export=download&id=1vOzjbbU2oP_kYxU0wCm6maDcK3EdknUf';

/// AdMob unit IDs used only as a local fallback if the remote config fails.
///
/// Replace with your production AdMob IDs (and update Info.plist /
/// AndroidManifest App IDs) before release.
class AdsIds {
  AdsIds._();

  static const admobAppIdIos = 'ca-app-pub-3940256099942544~1458002511';
  static const admobAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713';

  static const bannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const bannerAndroid = 'ca-app-pub-3940256099942544/6300978111';

  // Google sample App Open units (local fallback only)
  static const openAdIos = 'ca-app-pub-3940256099942544/5575463023';
  static const openAdAndroid = 'ca-app-pub-3940256099942544/9257395921';

  // Google sample interstitial units
  static const interstitialIos = 'ca-app-pub-3940256099942544/4411468910';
  static const interstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';

  // Google sample rewarded units
  static const rewardedIos = 'ca-app-pub-3940256099942544/1712485313';
  static const rewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
}

/// Built-in fallback JSON for [MultiAds] when [kAdsConfigUrl] is unreachable.
String buildLocalAdsConfigJson() {
  final bannerId = Platform.isIOS ? AdsIds.bannerIos : AdsIds.bannerAndroid;
  final openAdId = Platform.isIOS ? AdsIds.openAdIos : AdsIds.openAdAndroid;
  final interId =
      Platform.isIOS ? AdsIds.interstitialIos : AdsIds.interstitialAndroid;
  final rewardId =
      Platform.isIOS ? AdsIds.rewardedIos : AdsIds.rewardedAndroid;
  return jsonEncode({
    'ads': {
      'admob': {
        'bannerIds': [bannerId],
        'interIds': [interId],
        'rewardIds': [rewardId],
        'nativeIds': <String>[],
        'openAdsIds': openAdId,
      },
      'settings': {
        'banners': ['admob'],
        'inters': ['admob'],
        'natives': <String>[],
        'rewards': ['admob'],
        'openads': 'admob',
      },
    },
  });
}

/// Fetches remote ads JSON, or returns [buildLocalAdsConfigJson] on failure.
Future<String> loadAdsConfigJson() async {
  try {
    final response = await http
        .get(Uri.parse(kAdsConfigUrl))
        .timeout(const Duration(seconds: 12));
    if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
      // Basic sanity: must look like JSON with an ads / admob root.
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return response.body;
      }
    }
  } catch (_) {
    // Fall through to local config.
  }
  return buildLocalAdsConfigJson();
}
