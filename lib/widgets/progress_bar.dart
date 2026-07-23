import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

class ProgressBar extends StatelessWidget {
  final int currentXp;
  final int maxXp;
  final String label;
  final double height;

  const ProgressBar({
    super.key,
    required this.currentXp,
    required this.maxXp,
    this.label = 'XP',
    this.height = 18,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = maxXp > 0 ? (currentXp / maxXp).clamp(0.0, 1.0) : 0.0;
    final int percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryGlow,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            Text(
              '$currentXp / $maxXp XP ($percentage%)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(color: AppColors.glassBorder, width: 1),
          ),
          child: Stack(
            children: [
              // Energy Fill Bar
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height / 2),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.accent,
                        AppColors.primaryGlow,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGlow.withValues(alpha: 0.8),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              // Glowing tip highlight
              if (progress > 0.05)
                Align(
                  alignment: Alignment(progress * 2 - 1, 0),
                  child: Container(
                    width: 4,
                    height: height,
                    decoration: const BoxDecoration(
                      color: AppColors.textWhite,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGlow,
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
