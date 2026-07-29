import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme/app_colors.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;

  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.message,
    this.cancelText = 'ABORT',
    this.confirmText = 'DELETE',
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String cancelText = 'ABORT',
    String confirmText = 'DELETE',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.primaryBackground.withValues(alpha: 0.85),
      builder: (context) => ConfirmDeleteDialog(
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
      ),
    );
    return result ?? false;
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
          border: Border.all(color: AppColors.systemWarningRed, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.systemWarningRed.withValues(alpha: 0.4),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // System Warning Tag
            Text(
              '[ SYSTEM WARNING ]',
              style: const TextStyle(
                color: AppColors.systemWarningRed,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ).animate().fadeIn().scale(),

            const SizedBox(height: 16),

            // Warning Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.systemWarningRed.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.systemWarningRed, width: 1.5),
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                size: 40,
                color: AppColors.systemWarningRed,
              ),
            ).animate().scale(delay: 100.ms),

            const SizedBox(height: 16),

            // Title
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Message
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.glassBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.systemWarningRed,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
