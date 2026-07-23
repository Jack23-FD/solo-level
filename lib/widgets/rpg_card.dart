import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

class RpgCard extends StatelessWidget {
  final Widget child;
  final String? systemTitle;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final VoidCallback? onTap;

  const RpgCard({
    super.key,
    required this.child,
    this.systemTitle,
    this.padding = const EdgeInsets.all(16.0),
    this.borderColor = AppColors.primaryGlow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (systemTitle != null) ...[
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        color: borderColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        systemTitle!.toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: borderColor,
                              fontSize: 13,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        'SYSTEM // ACTIVE',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.glassBorder, height: 20),
                ],
                child,
              ],
            ),
          ),
          // Top Left Corner Accent
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                ),
              ),
            ),
          ),
          // Bottom Right Corner Accent
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
