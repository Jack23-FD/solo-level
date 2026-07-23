import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Artificial minimum delay for energetic splash feel
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    if (!mounted) return;
    if (authProvider.isLoggedIn) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Stack(
        children: [
          // Background energy glow circles
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGlow.withValues(alpha: 0.15),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // RPG Icon Emblem
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondaryBackground,
                    border: Border.all(color: AppColors.primaryGlow, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGlow.withValues(alpha: 0.6),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 64,
                    color: AppColors.primaryGlow,
                  ),
                )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.elasticOut)
                    .then()
                    .shake(duration: 400.ms),

                const SizedBox(height: 24),

                // Logo Title
                Text(
                  'SOLO-LEVEL',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.textWhite,
                        letterSpacing: 4.0,
                      ),
                ).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0),

                const SizedBox(height: 8),

                Text(
                  'SYSTEM LEVELING INITIALIZING...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryGlow,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 48),

                // Loading Indicator
                SizedBox(
                  width: 160,
                  child: const LinearProgressIndicator(
                    backgroundColor: AppColors.secondaryBackground,
                    color: AppColors.primaryGlow,
                    minHeight: 4,
                  ),
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
