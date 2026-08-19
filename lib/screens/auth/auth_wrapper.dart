import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/audio_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    AudioService.playLevelUp();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Run auth check and splash delay concurrently
    await Future.wait([
      authProvider.checkAuthStatus(),
      Future.delayed(const Duration(milliseconds: 2500)), // Show splash for 2.5s
    ]);
    
    if (!mounted) return;
    
    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGlow, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGlow.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack)
             .shimmer(delay: 800.ms, duration: 1200.ms, color: AppColors.textWhite),
            const SizedBox(height: 32),
            const Text(
              'SYSTEM INITIALIZING...',
              style: TextStyle(
                color: AppColors.primaryGlow,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5, end: 0),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: const LinearProgressIndicator(
                color: AppColors.primaryGlow,
                backgroundColor: AppColors.secondaryBackground,
              ).animate().fadeIn(delay: 1000.ms),
            ),
          ],
        ),
      ),
    );
  }
}
