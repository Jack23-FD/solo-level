import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme/app_colors.dart';
import 'glowing_button.dart';

class LevelUpDialog extends StatelessWidget {
  final int newLevel;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
  });

  static void show(BuildContext context, int newLevel) {
    showDialog(
      context: context,
      barrierColor: AppColors.primaryBackground.withValues(alpha: 0.85),
      builder: (context) => LevelUpDialog(newLevel: newLevel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryGlow, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGlow.withValues(alpha: 0.5),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing System Alert Header
            Text(
              '[ SYSTEM NOTIFICATION ]',
              style: TextStyle(
                color: AppColors.primaryGlow,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ).animate().fadeIn().scale(),

            const SizedBox(height: 16),

            // Icon energy badge
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [AppColors.primaryGlow, AppColors.accent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGlow.withValues(alpha: 0.8),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.electric_bolt,
                size: 48,
                color: AppColors.primaryBackground,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.1, 1.1),
                  duration: const Duration(seconds: 1),
                ),

            const SizedBox(height: 16),

            // Title
            Text(
              'LEVEL UP ACHIEVED!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.sRankGold,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
            ).animate().fadeIn().moveY(begin: 10, end: 0),

            const SizedBox(height: 8),

            Text(
              'You have reached Level $newLevel!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: 20),

            // Stat Boost Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                children: [
                  _buildStatRow('SHADOW CAPACITY', '+100 XP Max'),
                  const SizedBox(height: 8),
                  _buildStatRow('HUNTER PERCEPTION', '+5 Stat Points'),
                  const SizedBox(height: 8),
                  _buildStatRow('QUEST REWARD BONUS', '+10% Multiplier'),
                ],
              ),
            ).animate().fadeIn().scale(delay: 200.ms),

            const SizedBox(height: 24),

            GlowingButton(
              text: 'CLAIM REWARDS',
              glowColor: AppColors.sRankGold,
              buttonColor: AppColors.accent,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String statName, String boost) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          statName,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          boost,
          style: const TextStyle(
            color: AppColors.primaryGlow,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
