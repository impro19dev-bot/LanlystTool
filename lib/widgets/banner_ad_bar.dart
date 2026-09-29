import 'package:flutter/material.dart';
import 'package:multiads/multiads.dart';

import '../theme/app_colors.dart';
import '../utils/global.dart';

/// Bottom AdMob banner via [multiads]. Hides itself until an ad is ready.
class BannerAdBar extends StatefulWidget {
  const BannerAdBar({super.key});

  @override
  State<BannerAdBar> createState() => _BannerAdBarState();
}

class _BannerAdBarState extends State<BannerAdBar> {
  final Key _adKey = UniqueKey();
  Ads? _network;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!gAdsReady || !gAds.hasBanners) return;
    // Capture once — [MultiAds.bannerInstance] rotates on each get.
    final network = gAds.bannerInstance;
    _network = network;
    await network.loadBannerAd(() {
      if (mounted) setState(() => _ready = true);
    }, _adKey);
  }

  @override
  void dispose() {
    _network?.disposeBanner(_adKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!gAdsReady || !gAds.hasBanners || !_ready || _network == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: AppColors.navy.withValues(alpha: 0.18),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: Center(child: _network!.getBannerAdWidget(_adKey)),
        ),
      ),
    );
  }
}
