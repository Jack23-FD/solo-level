import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/audio_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  String _systemStatus = '[ SYSTEM ] SHADOW AURA GATHERING...';

  @override
  void initState() {
    super.initState();

    // Start splash screen loading sound immediately for instant audio sync
    AudioService.playSplashLoading();

    // 1. Initialize 2.8-second loading animation controller (shortened by 0.2s as requested)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _progressController.addListener(() {
      final progress = _progressAnimation.value;
      if (progress < 0.25 && _systemStatus != '[ SYSTEM ] SHADOW AURA GATHERING...') {
        setState(() => _systemStatus = '[ SYSTEM ] SHADOW AURA GATHERING...');
      } else if (progress >= 0.25 &&
          progress < 0.50 &&
          _systemStatus != '[ SYSTEM ] EXECUTING COMMAND: "ARISE"') {
        setState(() => _systemStatus = '[ SYSTEM ] EXECUTING COMMAND: "ARISE"');
      } else if (progress >= 0.50 &&
          progress < 0.75 &&
          _systemStatus != '[ SYSTEM ] VERIFYING HUNTER PERMISSIONS...') {
        setState(() => _systemStatus = '[ SYSTEM ] VERIFYING HUNTER PERMISSIONS...');
      } else if (progress >= 0.75 &&
          progress < 0.99 &&
          _systemStatus != '[ SYSTEM ] SHADOW MONARCH AWAKENED') {
        setState(() => _systemStatus = '[ SYSTEM ] SHADOW MONARCH AWAKENED');
      }
    });

    _initializeApp();
  }

  @override
  void dispose() {
    _progressController.dispose();
    AudioService.stopSplashLoading();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Start 2.8-second animation and auth check in parallel
    _progressController.forward();

    await Future.wait([
      authProvider.checkAuthStatus().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('Auth check timed out, proceeding with saved session');
        },
      ),
      // Guarantee exactly 2.8 seconds total splash time (shortened by 0.2s)
      Future.delayed(const Duration(milliseconds: 2800)),
    ]);

    if (!mounted) return;

    AudioService.stopSplashLoading();

    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      if (mounted) {
        setState(() => _systemStatus = '[ SYSTEM ] DOMAIN EXPANDED. WELCOME MY KING!');
      }
      await Future.delayed(const Duration(milliseconds: 250));
      if (mounted) context.go('/dashboard');
    } else {
      if (mounted) {
        setState(() => _systemStatus = '[ SYSTEM ] REDIRECTING TO HUNTER GATE...');
      }
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);
    final hunterName = (authProvider.currentUser?.username.isNotEmpty == true)
        ? authProvider.currentUser!.username.toUpperCase()
        : 'SUNG JIN-WOO';

    const shadowPurple = Color(0xFF8B5CF6);
    const electricCyan = Color(0xFF00C8FF);
    const deepAbyss = Color(0xFF030712);

    return Scaffold(
      backgroundColor: deepAbyss,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Deep Shadow Monarch Radial Energy Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.25,
                  colors: [
                    shadowPurple.withValues(alpha: 0.28),
                    electricCyan.withValues(alpha: 0.12),
                    deepAbyss,
                  ],
                ),
              ),
            ),
          ),

          // 2. Pulsing Shadow Energy Orbit Ring
          Center(
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: shadowPurple.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowPurple.withValues(alpha: 0.3),
                    blurRadius: 100,
                    spreadRadius: 25,
                  ),
                  BoxShadow(
                    color: electricCyan.withValues(alpha: 0.2),
                    blurRadius: 70,
                    spreadRadius: 10,
                  ),
                ],
              ),
            )
                .animate(onComplete: (c) => c.repeat(reverse: true))
                .scale(
                  duration: 2.5.seconds,
                  begin: const Offset(0.90, 0.90),
                  end: const Offset(1.10, 1.10),
                ),
          ),

          // 3. Sung Jin-Woo Shadow Monarch Window HUD
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: size.width > 420 ? 390 : size.width * 0.92,
                  padding: const EdgeInsets.all(26.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090D1F).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: shadowPurple,
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowPurple.withValues(alpha: 0.45),
                        blurRadius: 35,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: electricCyan.withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Badge: SHADOW MONARCH SYSTEM
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: deepAbyss,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: shadowPurple,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: shadowPurple.withValues(alpha: 0.5),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.auto_awesome,
                              color: shadowPurple,
                              size: 15,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'SHADOW MONARCH SYSTEM',
                              style: TextStyle(
                                color: electricCyan,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.2,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).moveY(begin: -10, end: 0),

                      const SizedBox(height: 24),

                      // Sung Jin-Woo Emblem / Logo Container
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Rotating Shadow Rune Ring
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: electricCyan.withValues(alpha: 0.6),
                                width: 2,
                              ),
                            ),
                          ).animate(onComplete: (c) => c.repeat()).rotate(duration: 7.seconds),

                          // Inner Frame Avatar
                          Container(
                            width: 110,
                            height: 110,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: deepAbyss,
                              border: Border.all(
                                color: electricCyan,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: shadowPurple.withValues(alpha: 0.8),
                                  blurRadius: 25,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .scale(duration: 800.ms, curve: Curves.elasticOut)
                          .then()
                          .shake(duration: 400.ms),

                      const SizedBox(height: 22),

                      // Iconic "A R I S E" Title
                      Text(
                        'A R I S E',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8.0,
                          shadows: [
                            Shadow(
                              color: shadowPurple,
                              blurRadius: 24,
                            ),
                            Shadow(
                              color: electricCyan,
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),

                      const SizedBox(height: 4),

                      // Dynamic Logged-in Username Readout
                      Text(
                        'PLAYER: $hunterName  •  S-RANK',
                        style: TextStyle(
                          color: electricCyan.withValues(alpha: 0.95),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.2,
                        ),
                      ).animate().fadeIn(delay: 350.ms),

                      const SizedBox(height: 24),

                      // System Command Terminal Dialog Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: deepAbyss,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: shadowPurple.withValues(alpha: 0.6),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: shadowPurple.withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Text(
                              _systemStatus,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: electricCyan,
                                fontSize: 11.5,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 4. ANIMATED SHADOW RUNNER & 2.8-SECOND LOADING BAR GAUGE
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          final value = _progressAnimation.value.clamp(0.0, 1.0);
                          final percentInt = (value * 100).toInt();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Label & Percentage Counter (10%, 25%, 50%, 75%, 100%)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.bolt,
                                        color: shadowPurple,
                                        size: 13,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'SYSTEM INITIALIZING',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$percentInt%',
                                    style: TextStyle(
                                      color: percentInt == 100
                                          ? AppColors.sRankGold
                                          : electricCyan,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Progress Track Container with Running Shadow Hunter Avatar
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final trackWidth = constraints.maxWidth;
                                  final runnerWidth = 32.0;
                                  final maxTranslate = trackWidth - runnerWidth;
                                  final currentPos = value * maxTranslate;

                                  // Leg/arm running motion simulation (bounce effect)
                                  final bounce = math.sin(value * 24 * math.pi) * 3.5;

                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Loading Bar Track
                                      Container(
                                        height: 8,
                                        width: trackWidth,
                                        decoration: BoxDecoration(
                                          color: deepAbyss,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: shadowPurple.withValues(alpha: 0.4),
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              width: trackWidth * value,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    shadowPurple,
                                                    electricCyan,
                                                    if (value >= 0.95) AppColors.sRankGold,
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: electricCyan.withValues(alpha: 0.8),
                                                    blurRadius: 10,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Animated Running Shadow Monarch Character Avatar
                                      Positioned(
                                        left: currentPos,
                                        top: -24 + bounce,
                                        child: Container(
                                          width: runnerWidth,
                                          height: 28,
                                          alignment: Alignment.center,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Trailing Shadow Particle Aura
                                              Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: shadowPurple.withValues(alpha: 0.5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: electricCyan,
                                                      blurRadius: 12,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Running Hunter Icon
                                              const Icon(
                                                Icons.directions_run,
                                                color: AppColors.textWhite,
                                                size: 22,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
