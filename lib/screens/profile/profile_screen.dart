import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/glassmorphism_container.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/rpg_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final user = authProvider.currentUser;

    final DateFormat formatter = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('HUNTER PROFILE'),
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGlow))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Avatar & Name Section
                  GlassmorphismContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avatar Badge
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.secondaryBackground,
                                border: Border.all(color: AppColors.primaryGlow, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGlow.withValues(alpha: 0.5),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  user.username.isNotEmpty ? user.username[0].toUpperCase() : 'H',
                                  style: const TextStyle(
                                    color: AppColors.primaryGlow,
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Text(
                          user.username.toUpperCase(),
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 22,
                                letterSpacing: 1.5,
                              ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'ID: ${user.id}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGlow.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryGlow),
                          ),
                          child: Text(
                            'LEVEL ${user.level} HUNTER',
                            style: const TextStyle(
                              color: AppColors.primaryGlow,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().scale(),

                  const SizedBox(height: 20),

                  // Hunter Stats Breakdown Card
                  RpgCard(
                    systemTitle: 'HUNTER STATS & METRICS',
                    child: Column(
                      children: [
                        ProgressBar(
                          currentXp: user.experience,
                          maxXp: user.maxExperienceForCurrentLevel,
                          label: 'CURRENT LEVEL EXP',
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                context,
                                label: 'COMPLETED QUESTS',
                                value: '${taskProvider.completedTasksCount}',
                                icon: Icons.verified_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatItem(
                                context,
                                label: 'AWAKENED SINCE',
                                value: formatter.format(user.createdAt),
                                icon: Icons.calendar_today_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).moveY(begin: 15, end: 0),

                  const SizedBox(height: 28),

                  // Logout Button
                  GlowingButton(
                    text: 'LOGOUT SYSTEM',
                    glowColor: AppColors.systemWarningRed,
                    buttonColor: AppColors.secondaryBackground,
                    icon: Icons.logout,
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGlow, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
