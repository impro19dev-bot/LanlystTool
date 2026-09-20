import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded inset strip used under the app header on each tab.
class StatusStrip extends StatelessWidget {
  const StatusStrip({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.fromLTRB(12, 10, 12, 0),
  });

  final Widget child;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.headerGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
