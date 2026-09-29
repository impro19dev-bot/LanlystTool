import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Soft circular LAN watermark used on empty / body screens.
class WpsWatermark extends StatelessWidget {
  const WpsWatermark({super.key, this.opacity = 0.22});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Center(
          child: Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.watermark.withValues(alpha: 0.55),
                  AppColors.watermark.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(color: AppColors.watermark, width: 2),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_rounded, size: 52, color: AppColors.navy),
                SizedBox(height: 2),
                Text(
                  'WPS',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
